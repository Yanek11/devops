#!/bin/bash
# VERSION WITH SCREEN (RUNS IN BACKGROUND)
# Script Name: nordvpn_ips_collecting_one_hostname.sh
# Description: Connects to a specified NordVPN server, collects unique IPs,
#              and stores them (IP hostname) in a file.  Runs in the background.
#              Log file is automatically generated. Appends to output file.

# Usage: ./nordvpn_ips_collecting_one_hostname.sh <server_prefix> <target_ip_count>

# --- Input Validation ---
usage() {
  echo "Usage: $0 <server_prefix> <target_ip_count>" >&2
  exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

server_prefix="$1"
target_ip_count="$2"

# Validate server prefix (basic check)
if [[ -z "$server_prefix" ]]; then
  echo "Error: Server prefix cannot be empty." >&2
  exit 1
fi

# Validate IP count (must be a positive integer)
if ! [[ "$target_ip_count" =~ ^[0-9]+$ ]] || [[ "$target_ip_count" -eq 0 ]]; then
  echo "Error: Invalid target IP count. Must be a positive integer." >&2
  exit 1
fi

# Check if nordvpn command exists
if ! command -v nordvpn >/dev/null 2>&1; then
  echo "Error: nordvpn command not found. Please install." >&2
  exit 1
fi

# --- Output File Setup ---
output_file="nordvpn_ips_unique_${server_prefix}.txt"
# No file creation/truncation needed.  '>>' will create it if it doesn't exist.

# --- Log File Setup (Automatic Name Generation) ---
timestamp=$(date '+%Y%m%d_%H%M%S')
log_file="nordvpn_ips_collecting_${server_prefix}_${timestamp}.log"

# --- Redirect Standard Output and Standard Error to Log File---
exec > "$log_file" 2>&1

# --- Trap for Cleanup ---
trap 'nordvpn disconnect' EXIT

# --- Main Processing Loop ---
echo "Starting collection for server: ${server_prefix}.nordvpn.com"
echo "Target IP count: $target_ip_count"
echo "Output file: $output_file" # Keep this, useful in the log.
echo "Log file: $log_file"       # Keep this, useful in the log.

# Get the initial count of IPs.
collected_ip_count=$(grep -c "\s${server_prefix}.nordvpn.com$" "$output_file")
echo "Initial unique IP count: $collected_ip_count"  # Keep for the log

while [[ $collected_ip_count -lt $target_ip_count ]]; do
  # No "Connecting to..." message needed.
  timeout 10s nordvpn connect "$server_prefix"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to connect to $server_prefix (or timed out)."
    exit 1
  fi

  # No sleep needed before getting the IP. The connection attempt itself provides a delay.
  # sleep 5

  ip=$(dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"')
  if [ $? -ne 0 ]; then
      echo "Error: dig command failed."
      exit 1
  fi

  if [[ -n "$ip" ]]; then
    # Keep the "Assigned IP" message for the log.
    echo "Assigned IP: $ip"

    if ! grep -Fxq "$ip $server_prefix.nordvpn.com" "$output_file"; then
      echo "$ip $server_prefix.nordvpn.com" >> "$output_file"
      echo "New IP recorded: $ip"  # Keep for the log
      ((collected_ip_count++))
    else
      echo "IP $ip already exists, skipping..." # Keep for the log
    fi
  else
    echo "Error: Failed to retrieve IP!"
     exit 1
  fi

  nordvpn disconnect

  # No random wait needed, as this is for background operation.
done

echo "Finished collection for server: ${server_prefix}.nordvpn.com"
echo "Collected $collected_ip_count unique IPs."

exit 0