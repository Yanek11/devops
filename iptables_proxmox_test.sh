# there are two versions: 
# first version using loops and arrays
# second version very simple. 



# First version
    #!/bin/bash

    # Variable definitions for PROXMOX
    export EXTERNAL_IP_PROXMOX="88.99.213.79"
    export EXTERNAL_INTERFACE_PROXMOX="ens18"
    export SSH_INTERNAL_PORT_PROXMOX="8585"
    export SSH_EXTERNAL_PORT_PROXMOX="8585"  # The external port for SSH
    export ALLOWED_IPS_PROXMOX=("138.199.59.0/24" "45.134.212.0/24" "85.221.131.0/24" "194.36.108.0/24" "89.163.154.0/24" "89.163.151.0/24")

    # Clear existing rules (use with caution!)
    sudo iptables -F
    sudo iptables -X
    sudo iptables -t nat -F
    sudo iptables -t nat -X
    sudo iptables -t raw -F
    sudo iptables -t raw -X

    # Set default policies
    sudo iptables -P INPUT ACCEPT
    sudo iptables -P FORWARD DROP
    sudo iptables -P OUTPUT ACCEPT

    # Table: nat
    sudo iptables -t nat -P PREROUTING ACCEPT
    sudo iptables -t nat -P INPUT ACCEPT
    sudo iptables -t nat -P OUTPUT ACCEPT
    sudo iptables -t nat -P POSTROUTING ACCEPT

    # Table: raw
    sudo iptables -t raw -P PREROUTING ACCEPT
    sudo iptables -t raw -P OUTPUT ACCEPT

    # Table: filter
    # Allow established and related connections
    sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    # Reject specific traffic
    declare -A reject_rules=(
        ["icmp"]="--icmp-type 8"
        ["udp_111"]="-p udp --dport 111"
        ["tcp_111"]="-p tcp --dport 111"
        ["udp_not_53"]="-p udp ! --dport 53"
    )
    for rule in "${!reject_rules[@]}"; do
        sudo iptables -A INPUT ${reject_rules[$rule]} -j REJECT --reject-with icmp-port-unreachable
    done

    # Allow specific traffic from ALLOWED_IPS_PROXMOX
    declare -A allowed_ports=(
        ["22"]="22"
        ["8006"]="8006"
    )
    for ip in "${ALLOWED_IPS_PROXMOX[@]}"; do
        for port in "${!allowed_ports[@]}"; do
            sudo iptables -A INPUT -s "$ip" -i $EXTERNAL_INTERFACE_PROXMOX -p tcp --dport ${allowed_ports[$port]} -j ACCEPT
        done
        sudo iptables -A INPUT -s "$ip" -i $EXTERNAL_INTERFACE_PROXMOX -j ACCEPT
    done

    # Log and drop the rest of the traffic (for security)
    sudo iptables -A INPUT -j LOG --log-prefix "IPTABLES_PROXMOX_DROP_INPUT: "
    sudo iptables -A INPUT -j DROP
    sudo iptables -A FORWARD -j LOG --log-prefix "IPTABLES_PROXMOX_DROP_FORWARD: "
    sudo iptables -A FORWARD -j DROP

    # Save the rules (important!)
    # sudo iptables-save > /etc/iptables/rules.v4
# First version - end
