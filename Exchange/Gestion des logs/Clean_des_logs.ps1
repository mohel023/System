### Variables a modifier ###
$servers = "192.168.1.151","192.168.1.152"
$Days = 1 #Tous les logs antérieurs au X derniers jours seront zippés
$DaysOldZip = 7 # X derniers jours de fichier zippés à garder
$LogsPath = "E:\logs"

### Variables
$date = get-date -UFormat %d-%m-%y

### Logs Exchange
foreach($_ in $servers){
$Server = $_

### Creation dossier pour destination zip Exchange
if((Get-ChildItem "$LogsPath\$Server\Exchange - $date" -ErrorAction SilentlyContinue) -eq $null){New-item "$LogsPath\$Server\Exchange - $date" -ItemType directory}

### Boucles et compressions
Get-ChildItem -Path "\\$_\c$\Program Files\Microsoft\Exchange Server\V15\Logging\" | %{
    $NameZip = $_
    Get-ChildItem $_.FullName -Recurse |?{$_.LastWriteTime -lt (get-date).AddDays(-$Days) -and $_.LastAccessTime -lt (get-date).AddDays(-$Days) -and $_.Name -like "*.log" -or $_.Name -like "*.blg" -or $_.Name -like "*.etl" }
    } | %{
        Try
          {
             Compress-Archive -path $_.FullName -DestinationPath "$LogsPath\$Server\Exchange - $date\$NameZip.zip" -Update
             remove-item $_.FullName
           }
        Catch
           {
    write-host $_.Exception.Message
           }
}}

### Logs IIS
foreach($_ in $servers){
$Server = $_

### Creation dossier pour destination zip IIS
if((Get-ChildItem "$LogsPath\$Server\IIS - $date" -ErrorAction SilentlyContinue) -eq $null){New-item "$LogsPath\$Server\IIS - $date" -ItemType directory}

### Boucles et compressions
Get-ChildItem -Path "\\$_\c$\inetpub\logs\LogFiles" | %{
    $NameZip = $_
    Get-ChildItem $_.FullName -Recurse |?{$_.LastWriteTime -lt (get-date).AddDays(-$Days)}
    } | %{
    if((Get-ChildItem "$LogsPath\$Server" -ErrorAction SilentlyContinue) -eq $null){New-item "$LogsPath\$Server" -ItemType directory}
       Try
         {
           Compress-Archive -path $_.FullName -DestinationPath "$LogsPath\$Server\IIS - $date\$NameZip.zip" -Update
           remove-item $_.FullName
           }
        Catch
           {
    write-host $_.Exception.Message
           }
}}

### Remove vieux ZIP
Get-ChildItem $LogsPath\ -Recurse |?{$_.LastWriteTime -lt (get-date).AddDays(-$DaysOldZip)} | Remove-Item -Confirm:$false