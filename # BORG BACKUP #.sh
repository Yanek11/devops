# BORG BACKUP # WORKING CONFIG 18.02.2025

#1 SSH public  keys 
cat ~/.ssh/id_rsa.pub | ssh -p23 u447269@u447269.your-storagebox.de install-ssh-key

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
            kk@px:~$ sudo borg create --stats  ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders_02::job_06_fail2banOK /bin /boot /etc /home /lib /lib64 /sbin /usr  /var/local /var/log 


#5 viewing backup repo content
borg list  ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders_02::job_06_fail2banOK
#6 mounting whole repo
borg mount  ssh://u447269@u447269.your-storagebox.de:23/./backup/backup_borg/borg_repository/repo_main_folders /mnt/borg




$ borg create ssh://u123456@u123456.your-storagebox.de:23/./backups/server1::2017_11_11_initial ~/src ~/built



//u447269@u447269.your-storagebox.de

/home/backup/backup_borg/borg_repository/proxmox






borg create --stats --info --compression auto,zstd,8 --exclude-caches --one-file-system --progress \
    "$REPOSITORY::{hostname}-{now:%Y-%m-%d_%H:%M:%S}" / /boot/efi /srv/vm

borg prune --stats --list --info $REPOSITORY --prefix "{hostname}-" --keep-hourly=4 --keep-daily=28 --keep-weekly=8 --keep-monthly=24 --keep-yearly=10