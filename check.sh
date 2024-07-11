#!/bin/bash

BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}"
    echo "======================================================================="
    echo "                 $1"
    echo "======================================================================="
    echo -e "${NC}"
}

# Function to check if the script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

# Function to detect temporary network interfaces that are deactivated
detect_and_clean_temp_interfaces() {


    print_header "Detect and clean temporary network interfaces"
    echo -e "${BLUE}"
    echo "######################################################################"
    echo "#             Once detect , the option allows users to remove        #"
    echo "#                     these unnecessary interface                    #"
    echo "######################################################################"
    echo -e "${NC}"

    # List all network interfaces along with their statuses

    interfaces=$(ip -o link show)

    # Define a pattern to identify temporary interfaces

    
    pattern1="cvd-"

    echo "Detecting and handling temporary network interfaces that are deactivated..."

    while IFS= read -r line; do
        iface=$(echo $line | awk -F': ' '{print $2}')
        state=$(echo $line | grep -oP '(?<=state\s)\w+')
        if [[ $iface == $pattern1* ]]; then
            if [[ $state == "DOWN" ]]; then
                if [[ $iface != *"ebr"* ]]; then
                    echo "Temporary interface detected and deactivated: $iface (state: DOWN)"
                    echo "Attempting to delete interface: $iface"
                    ip link delete $iface 2>/dev/null
                    if [ $? -eq 0 ]; then
                      echo "Successfully deleted $iface"
                    else
                        echo "Failed to delete $iface"
                    fi
                else
                    echo "Interface $iface is deactivated but excluded from deletion"
                fi
            fi
        fi
    done <<< "$interfaces"
     echo -e "${PURPLE}"
    echo "***Detection and cleanup complete***"
    echo -e "${NC}"
}

# Main script execution
check_root
detect_and_clean_temp_interfaces
