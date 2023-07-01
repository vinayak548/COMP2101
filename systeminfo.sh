#!/bin/bash

#Here is the path to  Function library
source "$(dirname "$0")/reportfunctions.sh"

LOG_FILE="/var/log/systeminfo.log"

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    errormessage "This script must be run as root."
    exit 1
fi

# Handle command line options
if [[ $# -gt 0 ]]; then
    while getopts "hvsdn" opt; do
        case $opt in
            h)
                display_help
                exit 0
                ;;
            v)
                verbose=true
                ;;
            s)
                run_system=true
                ;;
            d)
                run_disk=true
                ;;
            n)
                run_network=true
                ;;
            \?)
                errormessage "Invalid option: -$OPTARG"
                exit 1
                ;;
        esac
    done
fi

# Source the function library file
source reportfunctions.sh

# Run the appropriate functions based on command line options
if [[ $run_system == true ]]; then
    computerreport
    osreport
    cpureport
    ramreport
    videoreport
elif [[ $run_disk == true ]]; then
    diskreport
elif [[ $run_network == true ]]; then
    networkreport
else
    computerreport
    osreport
    cpureport
    ramreport
    videoreport
    diskreport
    networkreport
fi

# Example usage of the error message function
if [[ $verbose == true ]]; then
    errormessage "Something went wrong!"
fi
