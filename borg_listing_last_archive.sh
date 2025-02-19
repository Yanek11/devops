# LISTING OF the last archive name and files in it
# ./backup_last_created_detailed.sh 

#!/bin/bash

# Read Borg passphrase from file
export BORG_PASSPHRASE=$(cat ~/.borg_passphrase)
# Read SSH password from file
export SSH_PASSWORD=$(cat ~/.ssh_password)

# Set Borg repository
export BORG_REPO='ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders_02'

# Retrieve the name of the last created archive
LAST_ARCHIVE=$(borg list $BORG_REPO --last 1 --format "{archive}")

# Debugging: Show the last archive name
echo "Last archive: $LAST_ARCHIVE"

# List all files in the last created archive
borg list $BORG_REPO::$LAST_ARCHIVE
borg list $BORG_REPO |tail   -n 1
