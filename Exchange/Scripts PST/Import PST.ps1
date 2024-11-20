Add-Type -AssemblyName System.Windows.Forms

#Preventions
write-host -ForegroundColor Yellow "En cas d'import volumineux, merci de vérifier la taille des bases à l'aide de l'autre script auparavant"

#Explorateur pour aller récupérer les PST en questions
$FichierPST = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = '\\192.168.1.150\PST' ################# !!!!!!!!!!!!!! #####################
Multiselect = 'True' 
Filter = "PST (*.pst)|*.pst";            
}
$null = $FichierPST.ShowDialog()

#Copie de la variable pour gérer la liste plus tard
$FichierListe = $FichierPST

#Récupération du chemin du partage
$UNC = $FichierPST.FileName
$FichierPST = $FichierPST.SafeFileName
$UNC = $UNC -replace "$FichierPST"

#Controle du partage
if($UNC -notlike "*\\*")
{write-host -ForegroundColor Yellow "Les fichiers doivent être choisis dans le chemin du partage"
& '.\Exchange.ps1'
}

#Récupération de la liste des fichiers à importer
$FileList = $FichierListe.SafeFileNames

#Boucle sur chaque fichier pour envoyer l'import
$FileList | %{

    #Récupération de l'adresse smtp cible
    $Mailbox = $_ -replace ".pst"

    #Limitation du nombre d'imports parallèles // Pause si trop d'import en même temps
    do{$try = Get-MailboxImportRequest -Status InProgress
    start-sleep 5}
    until($try.count -lt "6")       ################# !!!!!!!!!!!!!! #####################

    #Vérification qu'une boite existe bien avec cette adresse SMTP
    $try = Get-ChildItem $UNC | ?{$_.Name -eq "$Mailbox.pst"} | select -ExpandProperty name
	start-sleep 1

    #Vérification que la boite a déjà été configuré (pour que les dossiers soient bien en francais)
    $lastlogon = get-mailbox $Mailbox | get-mailboxstatistics | select -ExpandProperty LastLogonTime
	start-sleep 1
    if($lastlogon -eq $null){write-host "La boite $Mailbox n'a jamais été configurée"}

    #Si les controles sont OK -> Import
    if($try -ne $null -and $lastlogon -ne $null){

    New-mailboximportrequest -Mailbox $Mailbox -filepath $UNC$_ -acceptlargedataloss -baditemlimit 100 -LargeItemLimit 100 -batchname Import -WarningAction SilentlyContinue  ################# !!!!!!!!!!!!!! #####################
	
    write-host -ForegroundColor Green "Import vers la boite $mailbox avec le fichier $UNC$_"

    }

}

& '.\Exchange.ps1'