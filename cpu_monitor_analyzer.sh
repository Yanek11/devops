    echo "Usage:"
    echo "  $0 --monitor       # Run CPU monitoring and log CPU usage"
    echo "  $0 --analyze <log_file>  # Analyze an existing CPU log file"


'cpu_monitor_analizer.sh'



#!/bin/bash

# Directory where log files will be saved
LOG_DIR="/home/kk/ansible/monitoring/"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Get hostname
HOSTNAME=$(hostname)

# Log file name based on the current date and hostname
LOG_FILE="$LOG_DIR/cpu_usage_$(date +%Y-%m-%d)_host_$HOSTNAME.log"

# Function to monitor CPU and log only relevant data
monitor_cpu() {
    # Capture top output in batch mode
    TOP_OUTPUT=$(top -b -n 1)

    # Extract system-wide statistics (First 6 lines of top output)
    SYSTEM_STATS=$(echo "$TOP_OUTPUT" | head -n 6)

    # Extract the process list, filtering only rows where %CPU > 0.0
    FILTERED_PROCESSES=$(echo "$TOP_OUTPUT" | awk '
        NR == 7 { header_line = $0; } # Capture process table header (PID USER ...)
        NR > 7 && $1 ~ /^[0-9]+$/ {  # Ensure the line starts with a PID
            if ($9 != "0.0") {
                lines[NR] = $0;  # Store process lines
                cpu_values[NR] = $9 + 0;  # Store CPU values for sorting
            }
        }
        END {
            if (header_line) {
                print header_line;  # Print the header before process rows
            }
            for (i = 1; i <= NR; i++) {
                if (cpu_values[i] > 0) {
                    print lines[i];  # Print only lines with active processes (CPU > 0)
                }
            }
        }
    ')

    # Always create log file, even if no active processes are found
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
    fi

    # Log system stats and active processes
    {
        echo "host: $HOSTNAME"
        echo "===== $(date +'%a %b %e %H:%M:%S %Z %Y') ====="
        echo "$SYSTEM_STATS"
        echo ""
        [[ -n "$FILTERED_PROCESSES" ]] && echo "$FILTERED_PROCESSES"
    } >> "$LOG_FILE"
}

# Function to analyze logged CPU data
analyze_cpu_log() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Error: Log file '$file' not found!"
        exit 1
    fi

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
        if ($2 == "us,") { next }  # Skip column headers

        # Extract CPU usage values
        user_cpu = $2 + 0
        system_cpu = $4 + 0

        # Skip if both %User and %System are 0.0
        if (user_cpu == 0.0 && system_cpu == 0.0) {
            next
        }

        # Print table header once
        if (printed_header == 0) {
            print "Index | Timestamp                      | %User  | %System | %Nice | %Idle | %Wait | %Hi | %Si | %St"
            print "------------------------------------------------------------------------------------------------"
            printed_header = 1
        }

        # Print the timestamp before CPU data
        if (header != "") {
            printf "%-5d | %-30s |", header_count, header
            header_count++
            header = ""
        }

        # Print CPU usage values
        printf " %-6.1f | %-7.1f | %-5.1f | %-5.1f | %-5.1f | %-5.1f | %-3.1f | %-3.1f | %-3.1f\n",
            user_cpu, system_cpu, $6, $8, $10, $12, $14, $16, $18
    }
    ' "$file"
}

# Main script logic
if [[ "$1" == "--monitor" ]]; then
    monitor_cpu
elif [[ "$1" == "--analyze" ]]; then
    if [[ -z "$2" ]]; then
        echo "Usage: $0 --analyze <log_file>"
        exit 1
    fi
    analyze_cpu_log "$2"
else
    echo "Usage:"
    echo "  $0 --monitor       # Run CPU monitoring and log CPU usage"
    echo "  $0 --analyze <log_file>  # Analyze an existing CPU log file"
    exit 1
fi


