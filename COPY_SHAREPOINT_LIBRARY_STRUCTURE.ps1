# Set the source and destination document library URLs
$sourceLibraryUrl = "https://yourdomain.sharepoint.com/sites/yourSite/Document"
$destinationLibraryUrl = "https://yourdomain.sharepoint.com/sites/yourSite/old_document"

# Connect to SharePoint Online
Connect-SPOService -Url "https://yourdomain-admin.sharepoint.com"

# Get the source document library and all its folders
$sourceLibrary = Get-SPOList -Identity $sourceLibraryUrl
$sourceFolders = Get-SPOFolder -List $sourceLibrary

# Create the destination document library if it doesn't exist
$destinationLibrary = Get-SPOList -Identity $destinationLibraryUrl
if (!$destinationLibrary) {
    $destinationLibrary = New-SPOList -Title "old_document" -Url $destinationLibraryUrl -Template DocumentLibrary
}

# Copy the folder structure to the destination library
foreach ($folder in $sourceFolders) {
    $folderName = $folder.Name
    $destinationFolderUrl = "$destinationLibraryUrl/$folderName"

    # Create the destination folder if it doesn't exist
    $destinationFolder = Get-SPOFolder -List $destinationLibrary -Name $folderName
    if (!$destinationFolder) {
        $destinationFolder = New-SPOFolder -List $destinationLibrary -Name $folderName
    }

    # Get all files in the source folder
    $files = Get-SPOFile -Folder $folder

    # Copy each file to the destination folder
    foreach ($file in $files) {
        $fileName = $file.Name
        $fileUrl = "$folderName/$fileName"
        $destinationFileUrl = "$destinationFolderUrl/$fileName"

        Copy-SPOFile -SourceUrl $fileUrl -TargetUrl $destinationFileUrl -Force
    }
}

Write-Output "Folder structure copied successfully."
