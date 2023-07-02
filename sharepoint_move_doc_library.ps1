# Set the source and destination document library URLs
$sourceLibraryUrl = "https://yourdomain.sharepoint.com/sites/yourSite/Documents"
$destinationLibraryUrl = "https://yourdomain.sharepoint.com/sites/yourSite/Old_document"

# Set the cutoff date for file modification
$cutoffDate = Get-Date -Year 2022 -Month 5 -Day 1

# Connect to SharePoint Online
Connect-SPOService -Url "https://yourdomain-admin.sharepoint.com"

# Get the source and destination libraries
$sourceLibrary = Get-SPOList -Identity $sourceLibraryUrl
$destinationLibrary = Get-SPOList -Identity $destinationLibraryUrl

# Get all files in the source library
$files = Get-SPOFile -List $sourceLibrary

# Iterate through each file and move if not modified since cutoff date
foreach ($file in $files) {
    $fileUrl = $file.ServerRelativeUrl
    $lastModified = $file.TimeLastModified

    # Check if file modification date is earlier than cutoff date
    if ($lastModified -lt $cutoffDate) {
        # Get the folder path within the source library
        $folderPath = $fileUrl.Substring($sourceLibraryUrl.Length + 1)
        $destinationFolderPath = "$destinationLibraryUrl/$folderPath"

        # Create the destination folder path if it doesn't exist
        $destinationFolder = Get-SPOFolder -List $destinationLibrary -Name $folderPath
        if (!$destinationFolder) {
            $destinationFolder = New-SPOFolder -List $destinationLibrary -Name $folderPath
        }

        # Move the file to the destination folder
        Move-SPOFile -SiteRelativeUrl $fileUrl -DestinationUrl "$destinationFolderPath/$($file.Name)"
    }
}

Write-Output "Files moved successfully."
