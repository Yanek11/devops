#!/bin/bash

# Backup source and destination
SOURCE_DIR="/tmp/backup/"  # Replace with your actual source directory
DESTINATION="u447269@u447269.your-storagebox.de:backup"

# Create date/time subdirectory on the destination
DATE_DIR=$(date +%Y%m%d)
TIME_DIR=$(date +%H%M%S)
DESTINATION_PATH="$DESTINATION/$DATE_DIR/$TIME_DIR"

# rsync options (Using --rsh and a VERY simple ssh command)
RSYNC_OPTIONS="--progress -avzHAX --delete --recursive"  # No -e here

# Create the remote directory structure (important!)
ssh -p 23 -i ~/.ssh/id_rsa u447269@u447269.your-storagebox.de "mkdir -p \"$DATE_DIR/$TIME_DIR\""  # Quote variables

# Perform the backup (using --rsh and the simplified SSH command)
rsync "$RSYNC_OPTIONS" -e "ssh -p 23 -i ~/.ssh/id_rsa" "$SOURCE_DIR" "u447269@u447269.your-storagebox.de:$DESTINATION_PATH"

# Create a symbolic link on the remote server (optional)
# ssh -p 23 -i ~/.ssh/id_rsa u447269@u447269.your-storagebox.de "ln -sf \"$DATE_DIR/$TIME_DIR\" latest" # Quote variables

echo "Backup completed to $DESTINATION_PATH"