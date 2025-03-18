

kk@deb01:~/scripts/nordvpn$ cat ./nordvpn_ips_collecting_all.sh
#!/bin/bash

# Script Name: nordvpn_ips_collecting_all.sh
# Description: This script connects to a list of NordVPN servers,
#              collects up to 9 unique IP addresses for each server,9

#              and stores them in a file, formatted as "IP hostname".
#              It uses connection caching and random server selection to
#              improve efficiency and avoid repeated connections to the same server.

# Function to display usage instructions
usage() {
  echo "Usage: $0 "
  echo "   : File containing the list of NordVPN servers, one per line." >&2
}

# --- Input Validation Section ---
# This section checks if the script was called correctly and if the necessary
# preconditions are met (input file exists, nordvpn command is available).

if [ $# -ne 1 ]; then  # Check for exactly one argument.
  usage
  exit 1  # Exit with an error code if the number of arguments is incorrect.
fi

SERVER_LIST_FILE="$1"  # The first argument is the path to the server list file.

if [[ ! -f "$SERVER_LIST_FILE" ]]; then  # Check if the file exists and is a regular file.
  echo "Error: File not found - $SERVER_LIST_FILE" >&2
  usage
  exit 1
fi

# Check if server list file is empty
if [[ ! -s "$SERVER_LIST_FILE" ]]; then
  echo "Error: Server list file is empty." >&2
  exit 1
fi

# Check if nordvpn command exists.  `command -v` is the POSIX-compliant way to do this.
if ! command -v nordvpn >/dev/null 2>&1; then
  echo "Error: nordvpn command not found.  Please install the NordVPN client." >&2
  exit 1
fi

# --- Output File Setup ---
OUTPUT_FILE="nordvpn_pl_unique_ips_list.txt"
# Only create the file if it does not exist.
if [[ ! -f "$OUTPUT_FILE" ]]; then
  touch "$OUTPUT_FILE"
fi

# --- Trap for Cleanup ---
# This ensures that 'nordvpn disconnect' is *always* called when the script exits,
# even if it's interrupted or encounters an error.  This prevents lingering connections.
trap 'nordvpn disconnect' EXIT

# --- Main Processing Loop ---
# This loop continues until all servers in the list have been connected to
# and have at least 9 unique IPs recorded (or the script is interrupted).

while true; do  # Outer loop:  Continues until all servers have enough IPs.
  # --- Read and Shuffle Server List ---
  # Reads the server list file into an array, then shuffles the array.
  # This is done *inside* the loop so that the list is randomized on *each* iteration.
  mapfile -t SERVERS < "$SERVER_LIST_FILE"  # Read the server list into the SERVERS array.
  SERVERS=( $(shuf -e "${SERVERS[@]}") )     # Shuffle the SERVERS array.

  all_servers_done=true  # Optimistic assumption: all servers might be done.

  # --- Inner Loop: Iterate Through Shuffled Server List ---
  for NORDVPN_SERVER in "${SERVERS[@]}"; do

    # --- Use AWK for IP Counting and Checking ---
    # This section uses `awk` to efficiently count the number of unique IPs
    # already recorded for the current server and to check if a newly
    # assigned IP has already been recorded. This avoids redundant `grep` calls.

    # The `awk` script is executed, and its output (two values) is read into
    # the `server_ip_count` and `is_recorded` variables using 'read'.
    read -r server_ip_count is_recorded <<< $(awk -F " " -v server="$NORDVPN_SERVER" '
      {
        # $1 is the IP, $2 is the hostname.  Fields are separated by a space.
        server_ips[$2]++;         # Increment the count of IPs for this server.
        recorded_ips[$2,$1] = 1;  # Mark this IP as recorded for this server.
      }
      END {
        # After processing the entire output file, check the count.
        if (server_ips[server] < 20) {
          # If less than 9 IPs, print the count and 0 (not recorded).
          print server_ips[server], 0;
        } else {
          # If 9 or more IPs, print the count and 1 (server is "done").
          print server_ips[server], 1;
        }
      }
    ' "$OUTPUT_FILE")


    # Check if the server already has 9 unique IPs.
    if [[ "$is_recorded" == 1 ]] ; then
      echo "Reached 9 unique IPs for $NORDVPN_SERVER. Skipping."
      continue  # Skip to the next server in the inner loop.
    fi

    all_servers_done=false # We processed a server, set to false

    # --- Connect to NordVPN ---
    echo "Connecting to NordVPN server: $NORDVPN_SERVER..."
    timeout 10s nordvpn connect "${NORDVPN_SERVER%%.*}"  # Connect, with a 10-second timeout.
    if [ $? -ne 0 ]; then  # Check the exit status of the 'nordvpn connect' command.
      echo "Error: Failed to connect to $NORDVPN_SERVER (or timed out)." >&2
      continue  # Skip to the next server if the connection fails.
    fi

    sleep 5  # Wait for the connection to stabilize.

    # --- Get Assigned IP ---
    IP=$(dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"')  # Get the public IP.
    if [ $? -ne 0 ]; then  # Check the exit status of the 'dig' command.
      echo "Error: dig command failed." >&2
      continue  # Skip to the next server if 'dig' fails.
    fi

    # --- Process the IP ---
    if [[ -n "$IP" ]]; then  # Check if the IP address is not empty.
      echo "Assigned IP: $IP"

      # --- Check if IP is Already Recorded (using AWK) ---
      is_recorded=$(awk -F " " -v server="$NORDVPN_SERVER" -v ip="$IP" '
        {
          recorded_ips[$2,$1] = 1;  # Mark IP as recorded (even if it *was* already recorded).
        }
        END{
          # Check if the IP was recorded for this server.
          if (recorded_ips[server, ip] == 1){
            print 1;  # Already recorded.
          }
          else {
            print 0  # Not recorded.
          }
        }
        ' "$OUTPUT_FILE")

      if [[ "$is_recorded" == "0" ]]; then  # If the IP is *not* already recorded:
        # Output in the format: IP hostname (SPACE separated)
        echo "$IP $NORDVPN_SERVER" >> "$OUTPUT_FILE"  # Append the IP and server to the output file.
        echo "New IP recorded: $IP for server $NORDVPN_SERVER"
      else
        echo "IP $IP for server $NORDVPN_SERVER already exists, skipping..."
      fi
    else
      echo "Error: Empty IP address received." >&2  # Handle the case where 'dig' returns an empty string.
    fi

    # --- Disconnect and Wait ---
    nordvpn disconnect  # Disconnect from the VPN.

    WAIT_SECONDS=$((RANDOM % 61 + 5))  # Generate a random wait time between 5 and 65 seconds.
    echo "Waiting $WAIT_SECONDS seconds before the next connection..."
    sleep "$WAIT_SECONDS"
    break #Exit inner for loop to pick another random server
  done
    if $all_servers_done; then #If all servers are done, break outer loop
      break;
    fi
done

echo "Finished"
kk@deb01:~/scripts/nordvpn$ 