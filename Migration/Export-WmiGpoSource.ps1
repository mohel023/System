#Requires -Modules ActiveDirectory,GroupPolicy
[CmdletBinding()]
param(
 [Parameter(Mandatory)][string]$OutputFolder,
 [string]$Domain = (Get-ADDomain).DNSRoot
)
$ErrorActionPreference='Stop'
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
$domainInfo=Get-ADDomain -Identity $Domain
$base="CN=SOM,CN=WMIPolicy,CN=System,$($domainInfo.DistinguishedName)"
$props=@('msWMI-ID','msWMI-Name','msWMI-Parm1','msWMI-Parm2','msWMI-Author','msWMI-CreationDate','msWMI-ChangeDate')
$filters=@(Get-ADObject -Server $Domain -SearchBase $base -LDAPFilter '(objectClass=msWMI-Som)' -Properties $props | ForEach-Object {
 [pscustomobject]@{
  DistinguishedName=$_.DistinguishedName
  Id=$_.'msWMI-ID'
  Name=$_.'msWMI-Name'
  Description=$_.'msWMI-Parm1'
  QueryData=$_.'msWMI-Parm2'
  Author=$_.'msWMI-Author'
  CreationDate=$_.'msWMI-CreationDate'
  ChangeDate=$_.'msWMI-ChangeDate'
 }
})
$filters | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputFolder 'WmiFilters.json') -Encoding UTF8
$filters | Export-Csv -LiteralPath (Join-Path $OutputFolder 'WmiFilters.csv') -NoTypeInformation -Encoding UTF8
$links=@(Get-GPO -All -Domain $Domain | ForEach-Object {
 $gpo=$_
 [pscustomobject]@{
  GpoId=$gpo.Id.ToString()
  GpoName=$gpo.DisplayName
  WmiFilterId=if($gpo.WmiFilter){$gpo.WmiFilter.Id.ToString()}else{''}
  WmiFilterName=if($gpo.WmiFilter){$gpo.WmiFilter.Name}else{''}
 }
})
$links | Export-Csv -LiteralPath (Join-Path $OutputFolder 'GpoWmiAssociations.csv') -NoTypeInformation -Encoding UTF8
Write-Host "Export termine : $($filters.Count) filtres WMI, $($links.Count) GPO. Dossier : $OutputFolder"
