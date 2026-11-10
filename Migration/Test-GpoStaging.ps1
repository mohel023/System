#Requires -Modules GroupPolicy
[CmdletBinding()]
param([Parameter(Mandatory)][string]$TargetDomain,[Parameter(Mandatory)][string]$ReportPath,[string]$OutputPath='.')
$ErrorActionPreference='Stop'
$rows=@(Import-Csv -LiteralPath $ReportPath | Where-Object { $_.Status -eq 'ImportedDisabled' })
$results=foreach($row in $rows){
 $id=[string]$row.TargetGpoId
 if(-not $id){Write-Warning 'GUID cible absent du rapport';continue}
 $gpo=Get-GPO -Guid ([guid]$id) -Domain $TargetDomain
 $xml=[xml](Get-GPOReport -Guid $gpo.Id -Domain $TargetDomain -ReportType Xml)
 $links=@($xml.GPO.LinksTo | Where-Object { $_ -and $_.SOMPath })
 [pscustomobject]@{Name=$gpo.DisplayName;Id=$gpo.Id;LinkCount=$links.Count;GpoStatus=$gpo.GpoStatus;Safe=($links.Count -eq 0 -and $gpo.GpoStatus -eq 'AllSettingsDisabled')}
}
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
$results | Export-Csv -LiteralPath (Join-Path $OutputPath 'GpoStagingValidation.csv') -NoTypeInformation -Encoding UTF8
$results | Format-Table -AutoSize
if(@($results | Where-Object {-not $_.Safe}).Count){throw 'GPO liee ou non desactivee : controle manuel requis'}
