***  Process ***

1. 'monitor_cpu.sh' - creates a log file and  crontab runs it  as job  every  minute or  10 minutes (custom). the log file is getting updated

2. 'stress-ng' -  generates values in "sy" and "us" columns

3. 'find_cpu_sy_us_values.sh'-  shows records containing  values in 'sy' or 'us' columns    
  

*** Details / scripts ***

1. monitor CPU, adding full date and time (hours/seconds)  
'monitor_cpu.sh'


        #!/bin/bash

        # Directory where log files will be saved
        LOG_DIR="/home/kk/ansible/monitoring/"

        # Create log directory if it doesn't exist
        mkdir -p "$LOG_DIR"

        # Get hostname
        HOSTNAME=$(hostname)

        # Log file name based on the current date and hostname
        LOG_FILE="$LOG_DIR/cpu_usage_$(date +%Y-%m-%d)_host_$HOSTNAME.log"

        # Append date and time with seconds to the log file in 24 hour notation
        echo "===== $(date +'%a %b %e %H:%M:%S %Z %Y') =====" >> "$LOG_FILE"

        # Run top command in batch mode and filter the required lines and sort them
        top -b -n 1 -o +%CPU | awk '
            NR <= 8 { print } # Print the first 8 lines (header)
            NR == 9 {
                header_line = $0;
            }
            NR > 9 { # Process the remaining lines (process list)
                if ($1 ~ /^[0-9]+$/ && $9 != "0.0") { # Check if line starts with PID and %CPU is not 0.0
                    lines[NR] = $0;
                    cpu_values[NR] = $9 + 0; #store cpu values for sorting
                }
            }
            END {
                print header_line; #print the header line
                for (i = 1; i <= NR; i++) {
                    if (cpu_values[i] != "") {
                        max_cpu = -1;
                        max_index = 0;
                        for(j = 1; j <= NR; j++) {
                            if(cpu_values[j] > max_cpu) {
                                max_cpu = cpu_values[j];
                                max_index = j;
                            }
                        }
                        if (max_index > 0){
                            print lines[max_index];
                            cpu_values[max_index] = -1; #mark as printed
                        }
                    }
                }
            }
        ' >> "$LOG_FILE"

end



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
5. getting cpu_usage_current.log
5.a


ansible control:


