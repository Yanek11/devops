#!/bin/bash

# Script Name: nordvpn_ips_collecting_one_hostname.sh
# Description: This script connects to a specified NordVPN server prefix,
#              collects a user-defined number of unique IP addresses,
#              and stores them in a file, formatted as "IP hostname".

# Function to display usage instructions
display_usage() {
  echo "Usage: $0"
  echo "This script prompts for a NordVPN server prefix and the number of unique IPs to collect." >&2
}

# --- Prompt for User Input ---

# Prompt the user for the NordVPN server prefix (e.g., pl122).
read -p "Enter the NordVPN server prefix (e.g., pl122): " server_prefix

# --- Input Validation ---

# Validate the server prefix input (check if it's empty).
if [[ -z "$server_prefix" ]]; then
  echo "Error: No server prefix provided." >&2
  display_usage
  exit 1  # Exit with an error code.
fi

# Prompt the user for the number of unique IPs to collect.
read -p "Enter the number of unique IPs to collect: " target_ip_count

# Validate the IP count input (check if it's a positive integer).
if ! [[ "$target_ip_count" =~ ^[0-9]+$ ]] || [[ "$target_ip_count" -eq 0 ]]; then
  echo "Error: Please enter a valid positive integer for the number of IPs." >&2
  exit 1
fi

# --- Output File Setup ---

# Define the output file name, incorporating the server prefix.
output_file="nordvpn_ips_unique_${server_prefix}.txt"

# Ensure the output file exists (creates it if it doesn't).
touch "$output_file"

echo "Starting collection for server: ${server_prefix}.nordvpn.com"

# --- Initialization ---
collected_ip_count=0  # Initialize the counter for collected IPs.

# --- Trap for Cleanup ---
# This ensures that 'nordvpn disconnect' is *always* called when the script exits,
# even if it's interrupted or encounters an error.
trap 'nordvpn disconnect' EXIT

# --- Main Processing Loop ---
# This loop continues until the desired number of unique IPs has been collected.

while [[ $collected_ip_count -lt $target_ip_count ]]; do

  # --- Connect to NordVPN ---
  echo "Connecting to NordVPN server: ${server_prefix}..."
  timeout 10s nordvpn connect "$server_prefix"  # Connect to the server, with timeout
   if [ $? -ne 0 ]; then
      echo "Error: Failed to connect to $server_prefix (or timed out)." >&2
      continue  # Skip to the next iteration of the outer loop
  fi

  # Wait for the connection to establish
  sleep 5

  # --- Get Assigned IP ---
  ip=$(dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"') # Get the public IP.
    if [ $? -ne 0 ]; then
      echo "Error: dig command failed." >&2
      continue
  fi

  # --- Process the IP ---
  if [[ -n "$ip" ]]; then  # Check if the IP address is not empty.
    echo "Assigned IP: $ip"

    # --- Check for Duplicate IP ---
    # Check if the IP is already recorded for this server.  Uses grep for simplicity.
    if ! grep -Fxq "$ip $server_prefix.nordvpn.com" "$output_file"; then
      # If NOT a duplicate:
      echo "$ip $server_prefix.nordvpn.com" >> "$output_file"  # Append to the output file.
      echo "New IP recorded: $ip $server_prefix.nordvpn.com"
      ((collected_ip_count++))  # Increment the counter.
    else
      # If it IS a duplicate:
      echo "IP $ip for server ${server_prefix}.nordvpn.com already exists in the list, skipping..."
    fi
  else
    echo "Failed to retrieve IP!" >&2  # Handle the case where 'dig' returns an empty string.
  fi

  # --- Display Current Count ---
  # Display the current count of unique IPs that have been collected.
  unique_ip_count=$(grep -c "\s${server_prefix}.nordvpn.com$" "$output_file")
  echo "Total unique IPs collected for ${server_prefix}.nordvpn.com: $unique_ip_count"

  # --- Disconnect and Wait ---
  nordvpn disconnect  # Disconnect from the VPN.

  # --- Generate a random wait time between 5 and 70 seconds. ---
  min_wait=5
  max_wait=70
  random_wait=$((min_wait + RANDOM % (max_wait - min_wait + 1)))
  echo "Waiting $random_wait seconds before the next connection..."
  sleep "$random_wait"

done

echo "Finished collection for server: ${server_prefix}.nordvpn.com"