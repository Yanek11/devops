

1.  generate CPU load

kk@ansible:~/ansible/monitoring$ cat random_cpu_load.sh 
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


2. catching rows within a time range

2a.
#!/bin/bash
cat cpu_usage_2025-03-08.log | awk '
  /=====.*03:1[0-4]:.* PM/ {print; for (i=0; i<3; i++) {getline; print} }
' | awk '
  /^%Cpu\(s\):/ || /^=====/
'

output

===== Sat Mar  8 03:10:01 PM CET 2025 =====
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 
===== Sat Mar  8 03:11:01 PM CET 2025 =====
%Cpu(s): 50.0 us,  0.0 sy,  0.0 ni, 50.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 
===== Sat Mar  8 03:12:01 PM CET 2025 =====
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 
===== Sat Mar  8 03:13:01 PM CET 2025 =====
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 
===== Sat Mar  8 03:14:01 PM CET 2025 =====
%Cpu(s):100.0 us,  0.0 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 

2b

filters: time range  and "us" or "sy" columns values are not 0 
#!/bin/bash
cat cpu_usage_2025-03-08.log | awk '
  /=====.*03:1[0-4]:.* PM/ {print; for (i=0; i<3; i++) {getline; print} }
' | awk '
  /^%Cpu\(s\):/ || /^=====/
' | awk '
  /^=====/ {
    header = $0;
    getline;
    if(/^%Cpu\(s\):/){
        us_val = $2 + 0;
        sy_val = $3 + 0;
        if (us_val > 0 || sy_val > 0) {
            print header;
            print $0;
        }
    }
    next;
  }
'
output
===== Sat Mar  8 03:11:01 PM CET 2025 =====
%Cpu(s): 50.0 us,  0.0 sy,  0.0 ni, 50.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 

2c

#!/bin/bash
cat cpu_usage_2025-03-08.log | awk '
  /=====.*:.*:.* PM/ {print; for (i=0; i<3; i++) {getline; print} }
' | awk '
  /^%Cpu\(s\):/ || /^=====/
' | awk '
  /^=====/ {
    header = $0;
    getline;
    if(/^%Cpu\(s\):/){
        us_val = $2 + 0;
        sy_val = $3 + 0;
        if (us_val > 0 || sy_val > 0) {
            print header;
            print $0;
        }
    }
    next;
  }
'