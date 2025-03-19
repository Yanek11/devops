ANSIBLE

Facts gathering and analyzing overview using ansible

Overview
- collect system data of each host -clients
- pull the data to the control - control host
- view the data by hostname and/or date - control host


What is collected 
- os: distro
- cpu: speed/cores number
- ram: amount
- disk: number and size
- net: names of NICs, IPs,default gw 









2. crontab runs the script  as job  every  minute or  10 minutes (custom)

  
Scripts executed on ansible control

1. script that runs a playbook 

run_ansible_playbook.sh
    #!/bin/bash

    # Script Name: run_ansible_playbook.sh
    # Description: Runs the Ansible playbook for gathering system facts.
    #              Handles environment setup and logging.

    # --- Configuration ---

    PLAYBOOK_PATH="/home/admin/ansible/facts_gathering/facts_gathering_scripts/playbook.yaml"  # <-- CHANGE THIS
    INVENTORY_PATH="/home/admin/ansible/facts_gathering/facts_gathering_scripts/inventory.yaml" # <-- CHANGE THIS
    LOG_DIR="/home/admin/ansible/facts_gathering/facts_gathering_scripts/ansible_logs"  # <-- CHANGE THIS (optional)

    # --- Setup ---

    mkdir -p "$LOG_DIR"
    LOG_FILE="$LOG_DIR/ansible_run_$(date +%Y%m%d_%H%M%S).log"

    # --- Environment Setup (CRITICAL for Cron) ---

    # Set up the environment *explicitly*.
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"  # <-- ***CHANGE THIS***

    # --- Run the Ansible Playbook ---

    # Message indicating playbook execution is starting
    echo "Starting execution of Ansible playbook at $(date)" >&2

    /usr/bin/ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH" >> "$LOG_FILE" 2>&1

    # Check the exit status of ansible-playbook.
    if [ $? -ne 0 ]; then
    echo "Error: Ansible playbook failed.  See $LOG_FILE for details." >&2
    exit 1
    fi

    # Message indicating successful completion
    echo "Ansible playbook completed successfully at $(date)" >&2

    exit 0
end  dadcsd


1. creating and testing of SSH key-based passwordless connectivity







ansible-playbook -i inventory.yaml playbook.yaml 

playbook.yaml
                
    ---
    - name: Manage Monitoring User and SSH Key
    hosts: all
    become: true
    vars:
        source_key_file: "{{ hostvars['localhost']['source_key_file'] | default('/home/kk/.ssh/monitoring_user.pub') }}"
        target_user: "{{ hostvars['localhost']['target_user'] | default('monitoring') }}"
        monitoring_groups: "{{ hostvars['localhost']['monitoring_groups'] | default(['sudo','adm']) }}"
        target_key_file: "/home/{{ target_user }}/.ssh/authorized_keys"

    tasks:
        - name: Check if target user (monitoring) exists
        command: id {{ target_user }}
        register: user_check
        ignore_errors: true
        changed_when: false
        become: true  # Use become, handled by inventory

        - name: Create monitoring user (if it doesn't exist)
        user:
            name: "{{ target_user }}"
            shell: /bin/bash
            create_home: yes
            groups: "{{ monitoring_groups | join(',') }}"
            append: yes
            state: present
        when: user_check.rc != 0
        become: true

        - name: Ensure monitoring user's home directory has correct permissions
        file:
            path: "/home/{{ target_user }}"
            owner: "{{ target_user }}"
            group: "{{ target_user }}"
            mode: '0755'
        when: user_check.rc != 0
        become: true

        - name: Ensure .ssh directory exists for target user
        file:
            path: "/home/{{ target_user }}/.ssh"
            state: directory
            owner: "{{ target_user }}"
            group: "{{ target_user }}"
            mode: '0700'
        become: true
        when: user_check.rc != 0

        - name: Copy SSH public key to authorized_keys
        copy:
            src: "{{ source_key_file }}"
            dest: "{{ target_key_file }}"
            owner: "{{ target_user }}"
            group: "{{ target_user }}"
            mode: '0600'
        become: true
        when: user_check.rc != 0
        register: copy_result

        - name: Report key copy status
        debug:
            msg: "Key copied successfully to {{ inventory_hostname }}"
        when: copy_result.changed

        - name: Report key copy failure (user existed, but copy failed)
        debug:
            msg: "Failed to copy key to {{ inventory_hostname }}. User already existed."
        when: not copy_result.changed and user_check.rc == 0

        - name: Report user creation and key copy
        debug:
            msg: "User '{{ target_user }}' created and key copied to {{ inventory_hostname }}."
        when: user_check.rc != 0

        - name: test ssh
        command: ssh -o StrictHostKeyChecking=no -i "{{ hostvars['localhost']['source_key_file'] | regex_replace('.pub$', '') }}" {{ target_user }}@{{ inventory_hostname }} "echo 'Connection successful'"
        register: ssh_result
        delegate_to: localhost
        changed_when: false
        when: copy_result.changed == true

        - name: Show ssh test result
        debug:
            msg: "ssh test: {{ ssh_result.stdout }}"
        when: ssh_result.stdout is defined
end

inventory.yaml
    all:
    hosts:
        ubu01:
        ansible_host: 1.1.1.1  # Replace with ubu01's actual IP or hostname
        deb01:
        ansible_host: 1.1.1.3  # Replace with deb01's actual IP or hostname
    vars:
        ansible_user: admin  # Connect as the 'admin' user
        ansible_ssh_private_key_file: /home/admin/.ssh/id_rsa  # Path to admin's *private* key on CONT>
        # ansible_become_pass: ...  # REMOVE THIS LINE.  Use --ask-become-pass or passwordless sudo.

    # Playbook variables (can be here or in the playbook, but inventory is better)
        source_key_file: /home/admin/.ssh/id_rsa.pub  # Path to monitoring's *public* key on CONTROL N>
        target_user: monitoring
        monitoring_groups:
        - sudo
        - adm


end

2. pushing  'gather_facts_all.sh' script to hosts
