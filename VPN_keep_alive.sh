# keeping VPN on all the time

#1

#!/bin/bash

# Check VPN status
vpn_status=$(sudo cyberghostvpn --traffic --country-code PL --status)

# If no VPN connections are found, reconnect
if [[ "$vpn_status" == *"No VPN connections found"* ]]; then
  sudo cyberghostvpn --traffic --country-code PL --connect
fi

#2
crontab -e * * * * * /home/kk/scripts/check_vpn.sh

#3 other VPN profiles
sudo cyberghostvpn --traffic --country-code DE --connect --server berlin-s451-i09 --city berlin
sudo cyberghostvpn --traffic --country-code PL --connect --server warsaw-s402-i03 --city warsaw

warsaw-s401-i01, warsaw-s402-i11, warsaw-s401-i12, warsaw-s403-i16, warsaw-s403-i17
138.199.59.0

"45.134.212.0/24"
 "85.221.131.0/24"
 "85.221.155.0/24"
 "194.36.108.0/24" berlin-s451-i09
 "89.163.154.0/24" dusseldorf-s403-i06
 "89.163.151.0/24"dusseldorf-s401-i10