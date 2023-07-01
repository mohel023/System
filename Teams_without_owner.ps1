Install-Module -Name PowerShellGet -Force -AllowClobber
Install-Module -Name MicrosoftTeams -Force -AllowClobber
Connect-MicrosoftTeams
$teams = Get-Team
foreach ($team in $teams) {
    $owners = Get-TeamUser -GroupId $team.GroupId -Role Owner
    if ($owners.Count -eq 0) {
        Write-Output "Team without owner: $($team.DisplayName)"
    }
}
