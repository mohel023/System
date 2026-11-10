#Requires -Modules GroupPolicy,ImportExcel
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
 [Parameter(Mandatory)][string]$ExcelPath,
 [Parameter(Mandatory)][string]$BackupPath,
 [Parameter(Mandatory)][string]$TargetDomain,
 [string]$MigrationTable,
 [string]$ReportPath = '.\GpoImportReport.csv'
)
$ErrorActionPreference='Stop'
if(!(Test-Path -LiteralPath $ExcelPath)){throw "Excel introuvable : $ExcelPath"}
if(!(Test-Path -LiteralPath $BackupPath)){throw "Dossier backup introuvable : $BackupPath"}
if($MigrationTable -and !(Test-Path -LiteralPath $MigrationTable)){throw 'Table de migration introuvable'}
$rows=@(Import-Excel -Path $ExcelPath)
if(!$rows.Count){throw 'Fichier Excel vide'}
$columns=@($rows[0].PSObject.Properties.Name)
foreach($required in @('Name','Final Action','ID')){
 if($columns -notcontains $required){throw "Colonne Excel manquante : $required"}
}
$backups = @(Get-ChildItem -LiteralPath $BackupPath -Filter 'bkupInfo.xml' -Recurse -File | ForEach-Object {
    [xml]$x = Get-Content -LiteralPath $_.FullName
    [pscustomobject]@{
        GpoId        = [guid]$x.BackupInst.GPOGuid
        Id           = [guid]$_.Directory.Name.Trim('{}')
        CreationTime = [datetime]$x.BackupInst.BackupTime
    }
})
$results=@()
foreach($row in $rows){
 if(([string]$row.'Final Action').Trim() -ine 'To keep'){continue}
 $sourceId=([string]$row.'ID').Trim().Trim('{}')
 $name=([string]$row.'Name').Trim()
 $status='Skipped';$targetId='';$detail=''
 try {
  $parsed=[guid]::Empty
  if(![guid]::TryParse($sourceId,[ref]$parsed)){throw "GUID source invalide : $sourceId"}
  if(!$name){throw 'Colonne Name vide'}
  $match=@($backups | Where-Object { $_.GpoId -eq $parsed } | Sort-Object CreationTime -Descending)
  if(!$match.Count){throw 'Aucune sauvegarde pour ce GUID source'}
  $existing=@(Get-GPO -All -Domain $TargetDomain | Where-Object DisplayName -eq $name)
  if($existing.Count){throw 'Une GPO porte deja ce nom dans le domaine cible : import bloque'}
  if($PSCmdlet.ShouldProcess("$TargetDomain / $name",'Creer GPO non liee et importer parametres')){
   # Creer une GPO neuve et la desactiver AVANT d'importer les parametres.
   $created=New-GPO -Name $name -Domain $TargetDomain -ErrorAction Stop
   $targetId=$created.Id.ToString()
   try {
    Set-GPO -Guid $created.Id -Domain $TargetDomain -GpoStatus AllSettingsDisabled -ErrorAction Stop
    $p=@{BackupId=$match[0].Id;Path=$BackupPath;TargetGuid=$created.Id;Domain=$TargetDomain;ErrorAction='Stop'}
    if($MigrationTable){$p.MigrationTable=$MigrationTable}
    Import-GPO @p | Out-Null
   } finally {
    # En cas d'echec d'import, tenter quand meme de maintenir la GPO desactivee.
    Set-GPO -Guid $created.Id -Domain $TargetDomain -GpoStatus AllSettingsDisabled -ErrorAction Stop
   }
   $verified=Get-GPO -Guid $created.Id -Domain $TargetDomain -ErrorAction Stop
   if($verified.GpoStatus -ne 'AllSettingsDisabled'){throw "CRITIQUE: GPO $targetId non desactivee"}
   $report=[xml](Get-GPOReport -Guid $created.Id -Domain $TargetDomain -ReportType Xml -ErrorAction Stop)
   $links=@($report.GPO.LinksTo | Where-Object { $_ -and $_.SOMPath })
   if($links.Count -gt 0){throw "CRITIQUE: GPO $targetId contient $($links.Count) lien(s)"}
   $status='ImportedDisabled'
   $detail='AllSettingsDisabled confirme; aucun lien GPO'
  } else {$status='Simulation'}
 } catch {$status='Error';$detail=$_.Exception.Message; if($targetId){$detail += ' | VERIFIER IMMEDIATEMENT GPO cible '+$targetId}}
 $results += [pscustomobject]@{SourceGpoId=$sourceId;Name=$name;TargetGpoId=$targetId;Status=$status;Detail=$detail}
}
$results | Export-Csv -LiteralPath $ReportPath -NoTypeInformation -Encoding UTF8
$results | Format-Table -AutoSize
Write-Host "Rapport : $ReportPath"
