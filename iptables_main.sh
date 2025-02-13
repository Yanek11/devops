IPTABLES SCRIPTS - PROXMOX 13/02/2025

  GNU nano 7.2                                                                                                                                                          iptables.script.sh                                                                                                                                                                    

# iptables.script.sh - SSH OK, no DNAT


        #!/bin/bash

        # Variable definitions for Proxmox
        export EXTERNAL_IP_PROXMOX="88.99.213.85"
        export EXTERNAL_INTERFACE_PROXMOX="vmbr0"
        export SSH_INTERNAL_PORT_PROXMOX="22"
        export SSH_EXTERNAL_PORT_PROXMOX="22"  # The external port for SSH
        export WEB_INTERNAL_PORT_PROXMOX="8006"
        export WEB_EXTERNAL_PORT_PROXMOX="8006"  # The external port for Proxmox Web

        export ALLOWED_IPS_PROXMOX=("138.199.59.0/24" "45.134.212.0/24" "85.221.131.0/24")  # <--- Replace with your allowed IPs

        # Clear existing rules (use with caution!)
        sudo iptables -F
        sudo iptables -X
        sudo iptables -t nat -F
        sudo iptables -t nat -X

        # Set default policies (crucial for security)
        sudo iptables -P INPUT DROP
        sudo iptables -P FORWARD DROP  # Not strictly necessary in this scenario, but good practice
        sudo iptables -P OUTPUT ACCEPT

        # 3. Allow established and related connections <--- Moved UP
        sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        # 1a. Allow incoming SSH to Proxmox (from ALLOWED_IPS_PROXMOX) on the EXTERNAL port
        for ip in "${ALLOWED_IPS_PROXMOX[@]}"; do
        sudo iptables -A INPUT -i $EXTERNAL_INTERFACE_PROXMOX -p tcp --dport $SSH_EXTERNAL_PORT_PROXMOX -s "$ip" -j ACCEPT
        done

        # 1b. Allow incoming web management (8006) to Proxmox (from ALLOWED_IPS_PROXMOX) on the EXTERNAL port
        for ip in "${ALLOWED_IPS_PROXMOX[@]}"; do
        sudo iptables -A INPUT -i $EXTERNAL_INTERFACE_PROXMOX -p tcp --dport $WEB_EXTERNAL_PORT_PROXMOX -s "$ip" -j ACCEPT
        done

        # 2a. Port Forwarding (NAT) - SSH 666=>22
        sudo iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE_PROXMOX -p tcp --dport $SSH_EXTERNAL_PORT_PROXMOX -j DNAT --to-destination :$SSH_INTERNAL_PORT_PROXMOX

        # 2b. Port Forwarding (NAT) - PROXMOX WEB 8006=>8006
        sudo iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE_PROXMOX -p tcp --dport $WEB_EXTERNAL_PORT_PROXMOX -j DNAT --to-destination :$WEB_INTERNAL_PORT_PROXMOX


        # 4. Log and block the rest of the traffic (for security)
        sudo iptables -A INPUT -j LOG --log-prefix "IPTABLES_PROXMOX_DROP_INPUT: "
        sudo iptables -A INPUT -j DROP
        sudo iptables -A FORWARD -j LOG --log-prefix "IPTABLES_PROXMOX_DROP_FORWARD: " # Although FORWARD is DROP by default
        sudo iptables -A FORWARD -j DROP



        # Save the rules (important!)
        sudo iptables-save > /etc/iptables/rules.v4
        #sudo netfilter-persistent save  # If you're using netfilter-persistent

# iptables.script.sh - SSH OK, no DNAT
