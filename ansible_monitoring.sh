Process:

1. 'monitor_cpu.sh' - creates a log file and  crontab runs it  as job  every  minute or  10 minutes (custom). the log file is getting updated

2. 'stress-ng' -  generates values in "sy" and "us" columns

3. 'find_cpu_sy_us_values.sh'-  shows records containing  values in 'sy' or 'us' columns    
  

Details / scripts:

1. monitor CPU, adding full date and time (hours/seconds)  

'monitor_cpu.sh'
#!/bin/bash

# Directory where log files will be saved
LOG_DIR="/home/kk/ansible/monitoring/"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log file name based on the current date
LOG_FILE="$LOG_DIR/cpu_usage_$(date +%Y-%m-%d).log"

# Append date and time with seconds to the log file in 24 hour notation
echo "===== $(date +'%a %b %e %H:%M:%S %Z %Y') =====" >> "$LOG_FILE"

# Run top command in batch mode and filter the required lines
top -b -n 1 -o +%CPU | head -n 9 >> "$LOG_FILE"




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



3. finding rows with values <> 0.0 in 'sy' and 'us'

'find_cpu_sy_us_values.sh'

FINAL filtering out sy and us values that are not 0.0. sections are numbered

#!/bin/bash

# version newest and working  09/03/2025
 
# Check if a file argument was passed
if [ -z "$1" ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi
 
# Log file is passed as the first argument
LOG_FILE="$1"
 
# Initialize header counter
header_count=1
 
# Process the log file
awk -v header_count="$header_count" '
BEGIN {
    header = ""   # Initialize header variable
}
# When we find the header (=====> lines)
(/^=====/) {
    # Update the header with the new line
    header = $0
}
# Process the CPU line
/%Cpu\(s\):/ {
    # Only print CPU lines if usage is not zero
    if ($2 != "0.0" || $4 != "0.0") {
        # Print the header before the CPU line if it exists
        if (header != "") {
            print header_count ". " header  # Print the header
            header_count++  # Increment header counter after printing the header
            header = ""  # Clear the header to prevent repeating it for the next CPU line
        }
        print $0  # Print the CPU usage line
    }
}
' "$LOG_FILE"


