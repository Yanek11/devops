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

  
### Scripts executed on ansible control - tested and working 19/03/2025 ###

*** creating ssh connectivity between ansible control and ansible clients ***
*** usermonitoring added, copying ssh keys, testing ssh ***
*** FINISHED / WORKING ***

1. inventory.yml 
    all:
    hosts:
        ubu01:
        ansible_host: 1.1.1.3  # Replace with ubu01's actual IP or hostname
        deb01:
        ansible_host: 1.1.1.1  # Replace with deb01's actual IP or hostname
    vars:
        ansible_user: admin  # Connect as the 'admin' user
        ansible_ssh_private_key_file: /home/admin/.ssh/id_rsa  # Path to admin's *private* key on CONTROL NODE
        # ansible_become_pass: ...  # REMOVE THIS LINE.  Use --ask-become-pass or passwordless sudo.

    # Playbook variables (can be here or in the playbook, but inventory is better)
        source_key_file: /home/admin/.ssh/id_rsa.pub  # Path to monitoring's *public* key on CONTROL NODE
        target_user: monitoring
        monitoring_groups:
        - sudo
        - adm
end

2. playbook.yaml
    ---
    - name: Manage Monitoring User and SSH Key
    hosts: all  # Target all hosts in the inventory.
    become: true  # Run tasks with elevated privileges (sudo).
    vars:
        # Variables defined here are available to all tasks in the play.
        source_key_file: "{{ hostvars['localhost']['source_key_file'] | default('/home/kk/.ssh/monitoring_user.pub') }}"  # Path to the *public* key on the Ansible *control node*.
        target_user: "{{ hostvars['localhost']['target_user'] | default('monitoring') }}"  # Username for the monitoring user on the *target* hosts.
        monitoring_groups: "{{ hostvars['localhost']['monitoring_groups'] | default(['sudo','adm']) }}"  # Groups to add the monitoring user to.
        target_key_file: "/home/{{ target_user }}/.ssh/authorized_keys"  # Path to the authorized_keys file for the monitoring user.

    tasks:
        - name: Check if target user (monitoring) exists
        command: id {{ target_user }}  # Use the 'id' command to check if the user exists.
        register: user_check  # Save the result of the command to the 'user_check' variable.
        ignore_errors: true  # Don't fail the playbook if the user doesn't exist (we'll handle that later).
        changed_when: false  # This task doesn't change anything on the system.
        become: true  # Run this task with elevated privileges (needed to check for any user).

        - name: Create monitoring user (if it doesn't exist)
        user:  # Use the Ansible 'user' module to manage users.
            name: "{{ target_user }}"  # The username.
            shell: /bin/bash  # Set the user's shell.
            create_home: yes  # Create the user's home directory.
            groups: "{{ monitoring_groups | join(',') }}"  # Add the user to the specified groups.
            append: yes  # Append to existing groups, don't replace them.
            state: present  # Ensure the user exists.
        when: user_check.rc != 0  # Only run this task if the 'user_check' task failed (user doesn't exist).
        become: true

        - name: Ensure monitoring user's home directory has correct permissions
        file:  # Use the Ansible 'file' module to manage files/directories.
            path: "/home/{{ target_user }}"  # The path to the user's home directory.
            owner: "{{ target_user }}"  # Set the owner.
            group: "{{ target_user }}"  # Set the group.
            mode: '0755'  # Set the permissions (read/write/execute for owner, read/execute for group and others).
        when: user_check.rc != 0 # Only when user did not exists
        become: true

        - name: Ensure .ssh directory exists for target user
        file:
            path: "/home/{{ target_user }}/.ssh"
            state: directory  # Ensure it's a directory.
            owner: "{{ target_user }}"
            group: "{{ target_user }}"
            mode: '0700'  # Permissions: read/write/execute *only* for the owner.
        become: true
        when: user_check.rc != 0 # Only when user did not exists

        - name: Copy SSH public key to authorized_keys
        copy:  # Use the Ansible 'copy' module to copy the public key.
            src: "{{ source_key_file }}"  # Source file (on the Ansible control node).
            dest: "{{ target_key_file }}"  # Destination file (on the remote host).
            owner: "{{ target_user }}"
            group: "{{ target_user }}"
            mode: '0600'  # Permissions: read/write *only* for the owner.
        become: true
        when: user_check.rc != 0 # Only when user did not exists
        register: copy_result  # Register the result of the copy operation.

        - name: Report key copy status
        debug:  # Use the Ansible 'debug' module to print information.
            msg: "Key copied successfully to {{ inventory_hostname }}"
        when: copy_result.changed  # Only print if the 'copy' task actually changed something.

        - name: Report key copy failure (user existed, but copy failed)
        debug:
            msg: "Failed to copy key to {{ inventory_hostname }}. User already existed."
        when: not copy_result.changed and user_check.rc == 0 # Only when copy fails

        - name: Report user creation and key copy
        debug:
            msg: "User '{{ target_user }}' created and key copied to {{ inventory_hostname }}."
        when: user_check.rc != 0 # Only when user was created.

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

3. script running playbook

    #!/bin/bash

    # Script Name: run_ssh_setup_playbook.sh
    # Description: Runs the Ansible playbook to set up the monitoring user and SSH key.
    #              Handles environment setup and logging.

    # --- Configuration ---

    PLAYBOOK_PATH="/home/admin/ansible/facts_gathering/ssh_connectivity/playbook.yaml"  # <-- CHANGE THIS to the absolute path to your playbook
    INVENTORY_PATH="/home/admin/ansible/facts_gathering/ssh_connectivity/inventory.yaml"  # <-- CHANGE THIS to the absolute path
    LOG_DIR="/home/admin/ansible/facts_gathering/ssh_connectivity/ansible_logs"  # <-- CHANGE THIS (optional, but highly recommended)

    # --- Setup ---

    # Create the log directory if it doesn't exist
    mkdir -p "$LOG_DIR"

    # Create a log file with a timestamp
    LOG_FILE="$LOG_DIR/ansible_run_$(date +%Y%m%d_%H%M%S).log"

    # --- Environment Setup (CRITICAL for Cron and General Best Practice) ---

    # Set up the environment *explicitly*. Cron jobs (and even manual runs from
    # different shells) might not have the same environment as your interactive
    # shell.

    # 1. Find the correct PATH (from your interactive shell):
    #    - Log in as the user that will run this script.
    #    - Run `echo $PATH` in your interactive shell.
    #    - Copy the *entire* output and paste it below.
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"  # <-- ***CHANGE THIS*** to your actual PATH

    # 2. Set any other *required* environment variables:
    #    - If your playbook relies on any other environment variables, set them here.
    #      For example, if you use Ansible Vault and need ANSIBLE_VAULT_PASSWORD_FILE:
    # export ANSIBLE_VAULT_PASSWORD_FILE="/path/to/your/vault/password/file"

    # --- Run the Ansible Playbook ---

    # Informational message (redirected to standard error, so it goes to the log)
    echo "Starting execution of Ansible playbook at $(date)" >&2

    # Run the Ansible playbook, redirecting both standard output and standard error
    # to the log file.
    /usr/bin/ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH" >> "$LOG_FILE" 2>&1

    # Check the exit status of ansible-playbook
    EXIT_STATUS=$?

    # Informational message (redirected to standard error)
    if [ $EXIT_STATUS -eq 0 ]; then
    echo "Ansible playbook completed successfully at $(date)" >&2
    else
    echo "Error: Ansible playbook failed (exit status $EXIT_STATUS).  See $LOG_FILE for details." >&2
    fi

    # Exit with the same exit status as ansible-playbook
    exit $EXIT_STATUS

end


### Scripts executed on ansible control and clients - tested and working 19/03/2025 ###
*** gathering facts ***
*** - os: distro - cpu: speed/cores number - ram: amount - disk: number and size - net: names of NICs, IPs,default gw ***

4. script that runs a playbook 

run_ansible_playbook.sh
    #!/bin/bash

    # Script Name: run_ansible_playbook.sh
    # Description: Runs the Ansible playbook for gathering system facts.
    #              Handles environment setup and logging.

    # --- Configuration ---

    PLAYBOOK_PATH="/home/admin/ansible/facts_gathering/facts_gathering_script/playbook.yaml"  # <-- CHANGE THIS
    INVENTORY_PATH="/home/admin/ansible/facts_gathering/facts_gathering_script/inventory.yaml" # <-- CHANGE THIS
    LOG_DIR="/home/admin/ansible/facts_gathering/facts_gathering_script/ansible_logs"  # <-- CHANGE THIS (optional)

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
end

5. playbook.yaml

playbook.yaml


 
        ---
        - name: Gather System Facts and Analyze (Ansible Modules)
        hosts: all

        tasks:
            - name: Ensure log directory exists on clients
            file:
                path: /home/monitoring/logs
                state: directory
                owner: monitoring
                group: admin
                mode: '0775'
            become: true

            - name: Gather facts (using setup module)
            setup:
            register: ansible_facts_result

            - name: Get CPU info from /proc/cpuinfo  # *** MODIFIED TASK ***
            shell: |
                awk '/^processor/{proc=$NF}; /model name/{model=$0; sub(/.*: */, "", model)}; /cpu MHz/{mhz=$NF}; END{
                if (mhz ~ /^[0-9.]+$/) { # Check if mhz is a number
                    ghz = sprintf("%.2f", mhz / 1000);  # Convert MHz to GHz, round to 2 decimal places
                    print proc+1 "/" ghz "GHz" # Output with unit
                } else {
                    print proc+1 "/N/A GHz"  # Fallback if mhz is not a number
                }
                }' /proc/cpuinfo
            register: cpu_info_result
            delegate_to: "{{ inventory_hostname }}"
            run_once: false
            changed_when: false

            - name: Prepare log file data
            set_fact:
                os_info: "Linux,{{ ansible_distribution }}{{ ansible_distribution_version }},{{ ansible_distribution_release }}"
                cpu_info: "{{ cpu_info_result.stdout | default('N/A') }}"
                ram_info: "{{ (ansible_memtotal_mb / 1024) | round(1) }}GB"
                disk_info: []
                network_info: []
            delegate_to: "{{ inventory_hostname }}"
            run_once: false

            - name: Gather disk information (including device name, mount point, and sizes)
            set_fact:
                disk_info: "{{ disk_info + [item.device ~ ',' ~ item.mount ~ ',' ~ total_gb ~ 'GB,' ~ free_gb ~ 'GB,' ~ used_gb ~ 'GB,' ~ used_pct ~ '%'] }}"
            loop: "{{ ansible_facts.mounts }}"
            vars:
                total_gb: "{{ (item.size_total / 1024 / 1024 / 1024) | round(1) }}"
                free_gb: "{{ (item.size_available / 1024 / 1024 / 1024) | round(1) }}"
                used_gb: "{{ ((item.size_total - item.size_available) / 1024 / 1024 /1024) | round(1)}}" #Correct Rounding
                used_pct: "{{ ((item.size_total - item.size_available) / item.size_total * 100) | round(1) if item.size_total > 0 else 0 }}"
            when: item.fstype not in ['squashfs', 'tmpfs', 'devtmpfs']
            delegate_to: "{{ inventory_hostname }}"
            run_once: false

            - name: Gather network information
            set_fact:
                network_info: "{{ network_info + [item.device ~ ',' ~ item.ipv4.address ~ '/' ~ (item.ipv4.netmask | ansible.utils.ipv4('prefix') | string)] }}"
            loop: "{{ ansible_facts.interfaces | map('extract', ansible_facts) | list }}"
            when: item.ipv4 is defined and item.ipv4.address is defined and item.device != 'lo'
            delegate_to: "{{ inventory_hostname }}"
            run_once: false

            - name: Get default gateway
            set_fact:
                default_gateway: "{{ ansible_default_ipv4.gateway | default('N/A') }}"
            delegate_to: "{{ inventory_hostname }}"
            run_once: false

            - name: Construct log content (with updated timestamp format)
            set_fact:
                log_content: |
                {{ inventory_hostname }}:{{ lookup('pipe', 'date +%Y-%m-%d_%H%M%S') }}
                os: {{ os_info }}
                cpu: {{ cpu_info }}
                ram: {{ ram_info }}
                disks: {{ disk_info | join(',') }}
                nics: {{ (network_info + [default_gateway]) | join(',') }}
            delegate_to: "{{ inventory_hostname }}"
            run_once: false

            - name: Create logs directory on controller
            file:
                path: ./logs
                state: directory
            delegate_to: localhost
            run_once: true

            - name: Save log content to file ON CONTROLLER (with updated timestamp format)
            copy:
                content: "{{ log_content }}"
                dest: "./logs/{{ inventory_hostname }}_gathered_facts_all_{{ lookup('pipe', 'date +%Y%m%d_%H%M%S') }}.log"
            delegate_to: localhost
            run_once: false

            - name: Debug Print facts
            debug:
                msg:
                - "OS: {{ os_info }}"
                - "CPU: {{ cpu_info }}"
                - "RAM: {{ ram_info }}"
                - "Disks: {{ disk_info }}"
                - "Network: {{ network_info }}"
                - "Default Gateway: {{default_gateway}}"
            delegate_to: localhost
            run_once: true

end

6. inventory

inventory.yaml
    all:
    hosts:
        ubu01:
        ansible_host: 1.1.1.3  # Replace with ubu01's actual IP or hostname
        deb01:
        ansible_host: 1.1.1.1  # Replace with deb01's actual IP or hostname
    vars:
        ansible_user: admin  # Connect as the 'admin' user
        ansible_ssh_private_key_file: /home/admin/.ssh/id_rsa  # Path to admin's *private* key on CONTROL NODE
        # ansible_become_pass: ...  # REMOVE THIS LINE.  Use --ask-become-pass or passwordless sudo.

    # Playbook variables (can be here or in the playbook, but inventory is better)
        source_key_file: /home/admin/.ssh/id_rsa.pub  # Path to monitoring's *public* key on CONTROL NODE
        target_user: monitoring
        monitoring_groups:
        - sudo
        - adm

end

