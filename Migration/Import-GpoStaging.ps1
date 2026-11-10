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
$backups=@(Get-GPOBackup -All -Path $BackupPath)
$results=@()
foreach($row in $rows){
 if(([string]$row.'Final Action').Trim() -ine 'To keep'){continue}
 $sourceId=([string]$row.'GPO ID').Trim().Trim('{}')
 $name=([string]$row.'GPO Name').Trim()
 $status='Skipped';$targetId='';$detail=''
 try {
  $parsed=[guid]::Empty
  if(![guid]::TryParse($sourceId,[ref]$parsed)){throw "GUID source invalide : $sourceId"}
  if(!$name){throw 'Colonne GPO Name vide'}
  $match=@($backups | Where-Object { $_.GpoId -eq $parsed } | Sort-Object CreationTime -Descending)
  if(!$match.Count){throw 'Aucune sauvegarde pour ce GUID source'}
  $existing=@(Get-GPO -All -Domain $TargetDomain | Where-Object DisplayName -eq $name)
  if($existing.Count){throw 'Une GPO porte deja ce nom dans le domaine cible : import bloque'}
  if($PSCmdlet.ShouldProcess("$TargetDomain / $name",'Creer GPO non liee et importer parametres')){
   $p=@{BackupId=$match[0].Id;Path=$BackupPath;TargetName=$name;Domain=$TargetDomain;CreateIfNeeded=$true;Confirm=$false;ErrorAction='Stop'}
   if($MigrationTable){$p.MigrationTable=$MigrationTable}
   $created=Import-GPO @p
   $targetId=$created.Id.ToString()
   $status='Imported'
   $detail='GPO non liee creee; verifier references et securite avant activation'
  } else {$status='Simulation'}
 } catch {$status='Error';$detail=$_.Exception.Message}
 $results += [pscustomobject]@{SourceGpoId=$sourceId;Name=$name;TargetGpoId=$targetId;Status=$status;Detail=$detail}
}
$results | Export-Csv -LiteralPath $ReportPath -NoTypeInformation -Encoding UTF8
$results | Format-Table -AutoSize
Write-Host "Rapport : $ReportPath"
