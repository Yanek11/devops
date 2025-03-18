

# BORG BACKUP # WORKING CONFIG 17.03.2025

#1 creating and copying ssh pubkey to borg
        
        ssh-keygen 
        Generating public/private rsa key pair.
        Enter file in which to save the key (/home/kk/.ssh/id_rsa): /home/kk/scripts/borg/security/id_rsa_borg
        
        ssh-copy-id -i /home/kk/scripts/borg/security/id_rsa_borg.pub -p 23 u447269@u447269.your-storagebox.de

#2 Repo password
export BORG_PASSPHRASE='Factoid0-Plating8-Untracked9-Lullaby8'

# REPO - "repo_01"
#3-borg repo initialization
# Borg automatically looks for the BORG_PASSHPRASE environment variable.

#3A -creating repo folders
ssh u447269@u447269.your-storagebox.de -p23
mkdir backup/backup_borg/borg_repository/repo_01


#3B 
borg init --encryption=repokey ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_01


#4 - first backup
 sudo borg create --stats  ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_01::2025_02_17_HOME_KK /home/kk

#5 viewing backup repo content
borg list  ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_01::2025_02_16_HOME_KK 

#6 mounting whole repo
borg mount  ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_01 /mnt/borg


# REPO - "repo_main_folders"
### WORKING SCRIPT ###  

#3-borg repo initialization
# Borg automatically looks for the BORG_PASSHPRASE environment variable.
export BORG_PASSPHRASE='pass]'

#3A -creating repo folders
ssh u447269@u447269.your-storagebox.de -p23
mkdir backup/backup_borg/borg_repository/repo_main_folders_02
exit

#3B 
borg init --encryption=repokey ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders_02


#4 - first backup
#!/bin/bash
 sudo borg create --stats  ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders_02::job_05_SSH-OK_8006-OK /bin /boot /etc /home /lib /lib64 /sbin /usr /var/
        ### second job
        ----------------------------------------------------------------------
            kk@px:~$ sudo borg create --stats  ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders_02::job_07_VMsBackupIncluded /bin /boot /etc /home /lib /lib64 /sbin /usr  /var/local /var/log /var/lib/vz 


#5 viewing backup repo content
borg list  ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders_02::job_04 

#6 mounting whole repo
borg mount  ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders /mnt/borg



# borg backup script : borg passprase and ssh password are read from text files

# creating text files with passwords
# SSH
echo 'your_ssh_password' > ~/.ssh_password
chmod 600 ~/.ssh_password
# BORG PASSPHRASE
echo 'your_borgpassphrase_password' > ~/.borg_passphrase
chmod 600 ~/.borg_passphrase

#!/bin/bash

# Read Borg passphrase from file
export BORG_PASSPHRASE=$(cat ~/.borg_passphrase)

# Read SSH password from file
SSH_PASSWORD=$(cat ~/.ssh_password)

# Set Borg repository
export BORG_REPO='ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders_02'

# Run Borg backup with sshpass to handle SSH password
sshpass -p $SSH_PASSWORD borg create --stats $BORG_REPO::whole_system_{hostname}-{now}' /bin /boot /etc /home /lib /lib64 /sbin /usr  /var/local /var/log /var/lib/vz 


### Version 03 - WORKING :)

#
#  works without prompting for a sudo password #
# ssh password and borg  passphrase stored in a file #
# not sure if it copies all files??? TO CHECK 

#!/bin/bash

# Read Borg passphrase from file
export BORG_PASSPHRASE=$(cat ~/.borg_passphrase)

# Read SSH password from file
SSH_PASSWORD=$(cat ~/.ssh_password)

# Set Borg repository
export BORG_REPO='ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders_02'

# Run Borg backup with sshpass to handle SSH password
sshpass -p $SSH_PASSWORD sudo borg create --stats $BORG_REPO::'whole_system_{hostname}-{now}' /bin /boot /etc /home /lib /opt /root /sbin /srv /usr /var /var/lib/vz




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

