ANSIBLE

Facts gathering and analyzing overview

- collect system data of each host -clients
- pull the data to the control - control
- view the data by hostname and/or date - control


What is collected 
- os: distro
- cpu: speed/cores number
- ram: amount
- disk: number and size
- net: number nad type of NICs 



Scripts executed on ansible clients:

1. 'gather_facts_all.sh'
user: monitoring
script location: /home/monitoring/scripts
log file location: /home/monitoring/logs
creates/updates a log file. filename format: hostname_gathered_facts_all_timestamp.log  
collects system data (cpu/ram/disk/os/network). 
adds timestamp of the scan.

---- log file data layout and content ----
rows:
    os: os,distro,codename 
    cpu: cores number/cpu speed
    ram: amount
    disk: number_of_disks,total_disks_size:disk01_size,disk02_size (etc) 
    network: nic01_name,IP_address/netmask,nic02_name,IP_address/netmask (etc),default gateway

example of the output log:
host01:01/02/2025,0616PM
os: Linux,Debian12,bookworm
ram: 2GB
disks: 2,100GB,sda01,50GB,sda02,50GB
nics: 2, ens18,1.1.1.1/24,ens19,2.1.1.1/24,1.1.1.254/24


2. crontab runs the script  as job  every  minute or  10 minutes (custom)

  
Scripts executed on ansible control

1. pull_logs.sh
getting logs

2. generate CPU load ---  'stress-ng' --- 
'random_cpu_load.sh' 
        #!/bin/bash

        # Function to generate random CPU load
        generate_load() {
        local load=$(shuf -i 10-90 -n 1)  # Generate a random load percentage between 10 and 90
        stress-ng --cpu 1 --cpu-method matrixprod --iomix 2 --cpu-load $load --timeout 2m &
        }

        # Generate random load on all available CPUs
        while true; do
        for ((i=1; i<=$(nproc); i++)); do
            generate_load
        done
        sleep 15  # Wait for 15 seconds before generating the next random load
        done
end


3. finding rows with values <> 0.0 in 'sy'  (%SYSTEM) and 'us' (%USER)
'find_cpu_sy_us_values.sh' 

3a
filtering out sy and us values that are not 0.0. sections are numbered. table output

        #!/bin/bash
        # export/add to a $LOG_FILE=cpu_usage_$CURRENT_DATE.log
        # Version newest and working 09/03/2025

        # Check if a file argument was passed
        if [ -z "$1" ]; then
            echo "Usage: $0 <log_file>"
            exit 1
        fi

        # Log file is passed as the first argument
        LOG_FILE="$1"

        # Process the log file
        awk '
        BEGIN {
            header_count = 1  # Index counter
            printed_header = 0  # Ensure header prints only once
            header = ""  # Initialize timestamp variable
        }

        # Detect timestamp header (=====> lines)
        (/^=====/) {
            header = $0  # Store timestamp
        }

        # Process CPU usage lines
        /%Cpu\(s\):/ {
            # Ensure we skip column headers (lines containing "us," "sy," etc.)
            if ($2 == "us,") {
                next
            }

            # Extract %User and %System CPU usage values
            user_cpu = $2 + 0  # Convert to number
            system_cpu = $4 + 0  # Convert to number

            # Skip rows where both %User and %System are 0.0
            if (user_cpu == 0.0 && system_cpu == 0.0) {
                next
            }

            # Print table header once
            if (printed_header == 0) {
                print "Index | Timestamp                      | %User  | %System | %Nice | %Idle | %Wait | %Hi | %Si | %St"
                print "------------------------------------------------------------------------------------------------"
                printed_header = 1
            }

            # Print the timestamp before the CPU data
            if (header != "") {
                printf "%-5d | %-30s |", header_count, header  # Print index and timestamp
                header_count++  # Increment index
                header = ""  # Clear timestamp
            }

            # Print CPU usage values
            printf " %-6.1f | %-7.1f | %-5.1f | %-5.1f | %-5.1f | %-5.1f | %-3.1f | %-3.1f | %-3.1f\n",
                user_cpu, system_cpu, $6, $8, $10, $12, $14, $16, $18
        }
        ' "$LOG_FILE"
end


output example 
kk@ansible:~/ansible/monitoring$ ./find_cpu_sy_us_values.sh cpu_usage_2025-03-08.log |head
Index | Timestamp                      | %User  | %System | %Nice | %Idle | %Wait | %Hi | %Si | %St
------------------------------------------------------------------------------------------------
1     | ===== Sat Mar  8 12:00:01 AM CET 2025 ===== | 50.0   | 0.0     | 0.0   | 50.0  | 0.0   | 0.0   | 0.0 | 0.0 | 0.0
2     | ===== Sat Mar  8 12:35:01 AM CET 2025 ===== | 0.0    | 50.0    | 0.0   | 50.0  | 0.0   | 0.0   | 0.0 | 0.0 | 0.0
3     | ===== Sat Mar  8 12:49:01 AM CET 2025 ===== | 50.0   | 0.0     | 0.0   | 50.0  | 0.0   | 0.0   | 0.0 | 0.0 | 0.0
4     | ===== Sat Mar  8 12:54:01 AM CET 2025 ===== | 0.0    | 50.0    | 0.0   | 50.0  | 0.0   | 0.0   | 0.0 | 0.0 | 0.0













*** Implementation via Ansible ***

ansible targets:

1. installation: stress-ng 
2. add user monitor
2. creating folder /home/monitor/ansible/monitoring
3. uploading 'monitor_cpu.sh','random_cpu_load.sh', 'find_cpu_sy_us_values.sh' to /home/monitor/ansible/monitoring
4. updating crontab    
*/1 * * * * /home/monitor/ansible/monitoring/monitor_cpu.sh
5. 'find_cpu_sy_us_values.sh' creates a logfile cpu_sy_us_values_$HOSTNAME.log

ansible control:

1.  download find_cpu_sy_us_values_$HOSTNAME.shfrom each host 
2.  
