# RSYNC ONE LINER # SIMPLE BACKUP # END        # this version works OK #

        sudo rsync --progress -e 'ssh -p23' --recursive / \
            u447269@u447269.your-storagebox.de:backup/proxmox.vanilla.13022025  \
            --exclude='*/tmp/systemd-private-*' \
            --exclude='*/tmp/.ICE-unix/*' \
            --exclude='*/tmp/.X11-unix/*' \
            --exclude='*/tmp/.XIM-unix/*' \
            --exclude='*/tmp/.font-unix/*' \
            --exclude='/proc/*'\
            --exclude='/sys/*' \
            --exclude='/var/*'



        # ssh -p23  u447269@u447269.your-storagebox.de

        #!/bin/bash

        # Store the sudo password securely (in a separate file with restricted permissions)
        PASSWORD_FILE="$HOME/.rsync_password"  # Or another secure location
        # Create the password file if it doesn't exist (only do this ONCE):
        # echo "your_ssh_password" > "$PASSWORD_FILE"  # Replace with your actual password
        # chmod 600 "$PASSWORD_FILE"

        # rsync command with exclusions
        rsync --progress -avzHAX --delete --recursive \
            -e "ssh -p23 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \ # Suppress SSH warnings (careful!)
            /tmp \
            u447269@u447269.your-storagebox.de:backup \
            --exclude='*/tmp/*' \
            --exclude='*/cache/*' \
            --exclude='*/.cache/*' \
            --exclude='*.tmp' \
            --exclude='*.swp' \
            --exclude='*~' \
            --exclude='.git' \
            --exclude='*/.thumbnails/*' \
            --exclude='*/lost+found/*' \
            --password-file="$PASSWORD_FILE"   # Provide the password file

        # Check the exit status
        if [[ $? -eq 0 ]]; then
            echo "rsync completed successfully."
        else
            echo "rsync failed."
        fi

        #!/bin/bash

        # Backup source and destination
        SOURCE_DIR="/"  # Replace with your actual source directory
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

# RSYNC ONE LINER # SIMPLE BACKUP # END