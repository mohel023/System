#Test pour si nouvelle PSSession
$tryPS = Get-PSSession | ?{$_.State -eq "Opened"}
if($tryPS -eq $null){
$UserCredential = Get-Credential labexchange\administrator  ################# !!!!!!!!!!!!!! #####################
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://mail.comiky.fr/PowerShell/ -Authentication Basic -Credential $UserCredential  ################# !!!!!!!!!!!!!! #####################
Import-PSSession $Session
}

cd C:\Scripts

Function information{
do {
    do {

    	write-host ""
        write-host -ForegroundColor white "1 - Lancer un import de PST"
        write-host -ForegroundColor white "2 - Visualiser l'état des imports PST"
        write-host -ForegroundColor white "3 - Exporter la taille des mailbox"
        write-host -ForegroundColor white "4 - Exporter des PST"
	    write-host ""
        write-host -ForegroundColor Cyan -nonewline "Faites votre choix: "
        
        $choice = read-host
        
        write-host ""
        
        $ok = $choice -match '^[1234]+$'
        
        if ( -not $ok) { write-host "Choix non valide" }
    } until ( $ok )
    
    switch -Regex ( $choice ) {  
    
         "1"        { & '.\import PST.ps1';break}
         "2"        { & '.\Rapport PST.ps1';break}
         "3"        { & '.\Exporter taille mailbox.ps1';break}
         "4"        { & '.\Export PST.ps1';break}
    }
} until ( $choice -notmatch "X" )}
$Information = information
$Information
