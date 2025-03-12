

1. #converting list of IPs and subnets. removing not needed characters comments etc

convert_to_subnets.sh   


        #!/bin/bash

        # Usage: ./convert_to_subnets.sh <input_file> <output_file>
        # Converts IP addresses to /24 subnets with optimized performance and progress tracking.

        if [ $# -ne 2 ]; then
            echo "Error: Incorrect number of arguments." >&2
            echo "Usage: $0 <input_file> <output_file>" >&2
            exit 1
        fi

        input_file="$1"
        output_file="$2"

        if [ ! -f "$input_file" ]; then
            echo "Error: Input file '$input_file' does not exist." >&2
            exit 1
        fi

        if ! command -v parallel &>/dev/null; then
            echo "Error: 'parallel' command not found. Install it with: sudo apt install parallel" >&2
            exit 1
        fi

        if ! command -v pv &>/dev/null; then
            echo "Error: 'pv' command not found. Install it with: sudo apt install pv" >&2
            exit 1
        fi

        # --- Function to Convert IP to /24 Subnet ---
        convert_to_subnet() {
            local ip="$1"

            # Ensure IP is valid (four octets)
            if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
                echo "${ip%.*}.0/24"
            fi
        }

        export -f convert_to_subnet

        # --- Extract, Convert, and Save ---
        total_lines=$(wc -l < "$input_file")  # Count total lines for progress tracking
        processed_lines=0

        grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$input_file" |  
            sort -u |  
            pv -l -s "$total_lines" |  
            parallel --jobs 8 convert_to_subnet |  
            sort -u > "$output_file"

        processed_lines=$(wc -l < "$output_file")  # Count processed lines

        # --- Completion Message ---
        if [ -s "$output_file" ]; then
            unique_subnets=$(wc -l < "$output_file")
            echo "✅ Subnets written to '$output_file'."
            echo "✅ Processed: $processed_lines / $total_lines rows."
            echo "✅ Number of unique subnets: $unique_subnets"
        else
            echo "❌ Error: Output file is empty or was not created." >&2
            exit 1
        fi
end


2. #filtering  list of pl subnets 
#ultra optimized very fastscript using paralell 

./filter_pl_subnets.sh 

    GNU nano 7.2                                                                   ./filter_pl_subnets.sh                                                                            
    #!/bin/bash
    # ver 06 - Optimized with caching and summary stats
    # Usage: ./filter_pl_subnets.sh <input_file> <output_file>
    # This script filters out subnets belonging to Poland using geoiplookup.

    if [ $# -ne 2 ]; then
        echo "Error: Incorrect number of arguments." >&2
        echo "Usage: $0 <input_file> <output_file>" >&2
        exit 1
    fi

    input_file="$1"
    output_file="$2"
    cache_file="geo_cache.txt"

    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' does not exist." >&2
        exit 1
    fi

    if ! command -v geoiplookup >/dev/null 2>&1; then
        echo "Error: geoiplookup command not found. Please install GeoIP." >&2
        exit 1
    fi

    # --- Read Total Lines for Progress ---
    total_lines=$(wc -l < "$input_file")
    echo "📊 Total subnets to check: $total_lines"

    # Ensure cache file exists
    touch "$cache_file"

    # Function to check IP country using cache
    lookup_ip() {
        local ip="$1"

        # Check if IP exists in cache
        if grep -q "^$ip " "$cache_file"; then
            grep "^$ip " "$cache_file" | awk '{print $2}'
            return
        fi

        # Perform lookup
        local result
        result=$(geoiplookup "$ip" | grep "PL, Poland")

        if [[ -n "$result" ]]; then
            echo "$ip PL" >> "$cache_file"  # Store result
            echo "$ip"
        else
            echo "$ip -" >> "$cache_file"  # Mark as non-PL
        fi
    }

    export -f lookup_ip
    export cache_file

    # Use GNU Parallel with progress bar to filter PL subnets efficiently
    cat "$input_file" | awk -F/ '{print $1}' | sort -u | pv -l -s "$total_lines" | parallel --jobs 16 lookup_ip | grep -v "^- $" > "$output_file"

    # --- Completion Summary ---
    pl_count=$(wc -l < "$output_file")
    echo "✅ Filtered PL subnets written to '$output_file'."
    echo "📌 Number of PL subnets: $pl_count"
    echo "📊 Percentage of PL subnets: $(awk "BEGIN {printf \"%.2f\", ($pl_count/$total_lines)*100}")%"

end


3. #example data

3a. all_ips_txt

    217.170.204.82 # holax.io,holavpn.net,hola.org
    217.170.204.88 # holax.io,holavpn.net,hola.org
    217.170.206.134 # holax.io,holavpn.net,hola.org
    217.170.206.135 # holax.io,holavpn.net,hola.org
    94.242.224.215
    94.242.206.66
    104.244.79.81
    94.242.224.199
    91.235.143.209
    91.235.143.210
    185.86.78.176
    91.203.145.142
    103.199.16.61
    103.199.16.60
    125.212.251.88
    103.199.16.120
end

3b. all_subnets.txt

    100.24.143.0/24
    100.42.17.0/24
    101.2.169.0/24
    101.226.196.0/24
    101.226.197.0/24
    102.128.164.0/24
    102.128.176.0/24
    102.129.145.0/24
    9.84.84.0/24
    99.84.88.0/24
    99.84.96.0/24
    99.84.98.0/24
    99.86.0.0/24
    99.86.8.0/24
end