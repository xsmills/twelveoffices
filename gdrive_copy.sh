#!/bin/bash

# Google Drive Folder ID from which to copy files
SOURCE_FOLDER_NAME="Offices Project"

# Local directory to copy files into
DESTINATION_DIR="Denomination"

# Function to recursively copy files from Google Drive folder
copy_files() {
    local folder_id=$1
    local destination_id=$2

    echo "This is folder id: $folder_id"
    
    # Retrieve files and folders from the specified folder
    files=$(gdrive files list --query "'$folder_id' in parents" --skip-header --field-separator ",")
    
    # Iterate over files and folders
    while IFS=$',' read -r id name filepath; do
        # Check if it's a file or a folder
        echo "This is file id: $id"
        echo "This is file path: $filepath"

        echo "This is file name: $name"
        if [ -z "$(echo "$filepath" | grep "folder")" ]; then
            # If it's a file, copy it
            echo "Copying file: $name"
            gdrive files copy "$id" "$destination_id" 
        else
            # If it's a folder, create a corresponding folder locally and recursively copy its contents
            echo "Creating folder: $name"
            gdrive files mkdir --parent "$destination_id" "$name"
            new_folder_id=$(gdrive files list --query "'$folder_id' in parents and name = '$name'" --skip-header --field-separator '|' | awk '{split($0,a,"|"); print a[1]}')
            new_destination_id=$(gdrive files list --query "'$destination_id' in parents and name = '$name'" --skip-header --field-separator '|' | awk '{split($0,a,"|"); print a[1]}')
            copy_files "$new_folder_id" "$new_destination_id"
        fi
    done <<< "$files"
}


# Start copying files
echo "Copying files from Google Drive..."
SOURCE_FOLDER_ID=$(gdrive files list --query "name = '$SOURCE_FOLDER_NAME'" --skip-header --field-separator '|' | awk '{split($0,a,"|"); print a[1]}')
DESTINATION_FOLDER_ID=$(gdrive files list --query "name = '$DESTINATION_DIR'" --skip-header --field-separator '|' | awk '{split($0,a,"|"); print a[1]}')
copy_files "$SOURCE_FOLDER_ID" "$DESTINATION_FOLDER_ID"
echo "Copying complete."
