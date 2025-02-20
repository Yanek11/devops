                                                                                                                                                      ./firewall_NEWEST                                                                                                                                                                    
#!/bin/bash
# Variable definitions for ROUTER
export EXTERNAL_IP_ROUTER="88.99.213.79"
export EXTERNAL_INTERFACE_ROUTER="ens18"
export SSH_INTERNAL_PORT_ROUTER="666"
export SSH_EXTERNAL_PORT_ROUTER="666"  # The external port for SSH

export ALLOWED_IPS_ROUTER=("138.199.59.0/24" "45.134.212.0/24" "85.221.131.0/24")  # <--- Replace with your allowed IPs

# Clear existing rules (use with caution!)
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X

# Set default policies (crucial for security)
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD DROP  # Not strictly necessary in this scenario, but good practice
sudo iptables -P OUTPUT ACCEPT



# 3. Allow established and related connections <--- Moved UP
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow DNS traffic
#sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
#sudo iptables -A OUTPUT -p udp --sport 53 -j ACCEPT

# Block all other incoming UDP traffic
sudo iptables -A INPUT -p udp  --dport 111 -j REJECT

# Block all other outgoing UDP traffic (optional)
sudo iptables -A INPUT -p udp ! --dport 53 -j REJECT




# 1a. Allow incoming SSH to Proxmox (from ALLOWED_IPS_ROUTER) on the EXTERNAL port
for ip in "${ALLOWED_IPS_ROUTER[@]}"; do
  sudo iptables -A INPUT -i $EXTERNAL_INTERFACE_ROUTER -p tcp --dport $SSH_EXTERNAL_PORT_ROUTER -s "$ip" -j ACCEPT
  sudo iptables -A INPUT -i $EXTERNAL_INTERFACE_ROUTER -s "$ip" -j ACCEPT
done

## 1b. Allow all traffic to port 8006 from ALLOWED_IPS_ROUTER
#for ip in "${ALLOWED_IPS_ROUTER[@]}"; do
#  sudo iptables -A INPUT -i $EXTERNAL_INTERFACE_ROUTER -p tcp --dport $WEB_EXTERNAL_PORT_ROUTER -s "$ip" -j ACCEPT
#  sudo iptables -A INPUT -i $EXTERNAL_INTERFACE_ROUTER -s "$ip" -j ACCEPT
#done

# 4. Log and block the rest of the traffic (for security)
sudo iptables -A INPUT -j LOG --log-prefix "IPTABLES_ROUTER_DROP_INPUT: "
# Comment out or remove the DROP rule
# sudo iptables -A INPUT -j DROP
sudo iptables -A FORWARD -j LOG --log-prefix "IPTABLES_ROUTER_DROP_FORWARD: " # Although FORWARD is DROP by default
sudo iptables -A FORWARD -j DROP

# Save the rules (important!)
#sudo iptables-save > /etc/iptables/rules.v4
#sudo netfilter-persistent save  # If you're using netfilter-persistent


