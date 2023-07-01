#!/bin/bash

#CPU Report Function
function cpureport {
    cat <<EOF

===================================================

CPU Report
----------

	Manufacturer: $(uname -p)
	Architecture: $(uname -m)
	Core Count: $(nproc)
	Max Speed: $(lscpu | awk '/^CPU MHz/ { printf "%.2f GHz\n", $3/1000 }')
	Cache Sizes:
	$(lscpu | awk -F ': +' '/^L[1-3] cache/ {print $2}')

EOF
}

#Computer Report Function
function computerreport {
   if [[ $(id -u) -eq 0 ]]; then
        cat <<EOF

===================================================

Computer Report
---------------

	Manufacturer: $(sudo dmidecode -t system | grep 'Manufacturer:' | cut -c 16-)
	Model: $(sudo dmidecode -t system | grep 'Product Name:' | cut -c 16-)
	Serial Number: $(sudo dmidecode -t system | grep 'Serial Number:' | cut -c 15-)

EOF
    else
        errormessage "Root access required!!"
    fi
}

#Operating System Report Function
function osreport {
    cat <<EOF

===================================================

OS Report
---------

	Linux distro: $(hostnamectl | grep -w 'Operating System' | cut -c 19-24)
	Distro version: $(hostnamectl | grep -w 'Operating System' | cut -c 26-32)

EOF
}


#RAM Report Funciton
function ramreport {
    cat <<EOF

===================================================

RAM Report
----------

	Installed Memory Components:
	$(dmidecode -t memory | awk '/^Memory Device$/ { count++ } /^Size:|^Speed:|^Manufacturer:|^Part Number:|^Locator:/ {ORS=(NR%5?FS:RS)}; NR%5==0 { print count, $2, $4, $6, $8, $10 }'>
	    printf "Device%-5s %-15s %-15s %-20s %-25s %s\n" "$count:" "$manufacturer" "$part_number" "$size" "$speed" "$locator" done)

	Total RAM Installed: $(free -h | awk '/^Mem:/ { print $2 }')

EOF
}


#Video Report Function
function videoreport {
    cat <<EOF

==================================================

Video Report
------------

	Manufacturer: $(lspci | awk '/VGA compatible controller:/ { print $5 }')
	Description or Model: $(lspci -vnnn | awk -F': ' '/VGA compatible controller/ { print $2 }')

EOF
}


#Disk Report Function
function diskreport {
    cat <<EOF

==================================================

Disk Report
-----------

	Installed Disk Drives:
	$(lsblk -o NAME,TYPE,SIZE,VENDOR,MODEL | awk '$2=="disk" { printf "%-15s %-15s %-20s %-15s %-10s\n", $1, $4, $5, "-", "-" }')
	$(lsblk -o NAME,MOUNTPOINT,FSTYPE,SIZE,TYPE,FSSIZE,FSUSED | awk '$2!="" { printf "%-15s %-15s %-20s %-15s %-10s %-10s\n", $1, "-", "-", $4, $5, $6, $7 }')

EOF
}


#Network Report Function
function networkreport {
    cat <<EOF

==================================================

Network Report
--------------

	Installed Network Interfaces:
	$(ip -o link show | awk '{print $2,$9}' | sed 's/://g' | while read -r interface state; do
	    manufacturer=$(ethtool -i "$interface" 2>/dev/null | awk '/^driver:/{print $2}')
	    model=$(ethtool -i "$interface" 2>/dev/null | awk '/^bus-info:/{print $2}')
	    speed=$(ethtool "$interface" 2>/dev/null | awk '/Speed:/{print $2}')
	    ip_addresses=$(ip -o addr show dev "$interface" | awk '{print $4}')
	    dns_servers=$(cat /etc/resolv.conf | awk '/^nameserver/{printf "%s ", $2}')
	    search_domains=$(cat /etc/resolv.conf | awk '/^search/{print $2}')
	    printf "%-15s %-25s %-15s %-15s %-30s %s\n" "$manufacturer" "$model" "$state" "$speed" "$ip_addresses" "$dns_servers $search_domains"
	done)

==================================================

EOF
}


#Error Message to save to the systeminfo.log
function errormessage {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[Error - $timestamp]: $1" >&2
    echo "[Error - $timestamp]: $1" >> /var/log/systeminfo.log
}
