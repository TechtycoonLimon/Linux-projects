#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

LOG_FILE="system_log.txt"


draw_bar() {
    percent=$1
    bars=$((percent / 2))

    echo -n "["
    for ((i=0; i<50; i++)); do
        if [ $i -lt $bars ]; then
            echo -ne "#"
        else
            echo -ne " "
        fi
    done
    echo -n "] $percent%"
}

get_cpu() {
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1)
    LOAD_INT=${LOAD%.*}
    echo ${LOAD_INT:-0}
}

get_memory() {
    USED=$(free | awk 'NR==2{print $3}')
    TOTAL=$(free | awk 'NR==2{print $2}')
    echo $((USED*100/TOTAL))
}

get_disk() {
    df / | awk 'NR==2{print $5}' | tr -d '%'
}

log_data() {
    echo "$(date) | CPU: $(get_cpu)% | MEM: $(get_memory)% | DISK: $(get_disk)%" >> $LOG_FILE
}

header() {
    echo -e "${BLUE}========================================${RESET}"
    echo -e "${CYAN}        PRO SYSTEM MONITOR${RESET}"
    echo -e "${BLUE}========================================${RESET}"
    echo "User: $(whoami) | Date: $(date)"
    echo ""
}

dashboard_view() {
    header

    echo -e "${YELLOW}CPU Usage${RESET}"
    cpu=$(get_cpu)
    draw_bar $cpu
    echo ""

    echo -e "${YELLOW}Memory Usage${RESET}"
    mem=$(get_memory)
    draw_bar $mem
    echo ""

    echo -e "${YELLOW}Disk Usage${RESET}"
    disk=$(get_disk)
    draw_bar $disk
    echo ""

    echo ""
    echo -e "${YELLOW}Top Processes${RESET}"
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
}

process_view() {
    header
    echo -e "${YELLOW}All Running Processes${RESET}"
    ps aux | less
}

system_info() {
    header
    echo -e "${YELLOW}System Info${RESET}"
    uname -a
    uptime
    free -h
    df -h
}


while true
do
    clear
    header

    echo "1. Dashboard View"
    echo "2. Process Viewer"
    echo "3. System Info"
    echo "4. Exit"
    echo ""
    read -p "Choose option: " choice

    case $choice in
        1)
            while true
            do
                clear
                dashboard_view
                log_data
                echo ""
                echo "Press 'b' to go back"
                read -t 2 -n 1 key
                if [[ $key == "b" ]]; then
                    break
                fi
            done
            ;;
        2)
            process_view
            ;;
        3)
            system_info
            read -p "Press enter to go back..."
            ;;
        4)
            echo "Exiting..."
            exit
            ;;
        *)
            echo "Invalid option"
            sleep 1
            ;;
    esac

done