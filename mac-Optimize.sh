#!/bin/bash

# Mac System Utility Script
# Provides various system maintenance and troubleshooting options

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to display header
display_header() {
    clear
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${YELLOW}   Mac System Utility Script${NC}"
    echo -e "${CYAN}===========================================${NC}"
}

# System Status Function
system_status() {
    display_header
    echo -e "${MAGENTA}System Status:${NC}"
    
    # Uptime Check
    uptime_info=$(uptime)
    uptime_days=$(echo "$uptime_info" | awk -F',' '{print $1}' | awk '{print $3}')
    echo -e "${BLUE}Uptime:${NC} $uptime_info"
    
    if (( $(echo "$uptime_days > 2" | bc -l) )); then
        echo -e "${RED}⚠ System has been running for more than 2 days. Consider restarting.${NC}"
    fi
    
    # Disk Space
    echo -e "\n${MAGENTA}Disk Space:${NC}"
    df -h | grep -E "Filesystem|/$"
    
    # Memory Usage
    echo -e "\n${MAGENTA}Memory Usage:${NC}"
    memory_stats
    
    read -p "Press Enter to continue..."
}

# Enhanced Memory Statistics Function
memory_stats() {
    # Get memory info in a more readable format
    total_mem=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2 " " $3}')
    
    # Use vm_stat and other commands to get detailed memory info
    vm_stats=$(vm_stat)
    
    # Extract key memory metrics
    pages_free=$(echo "$vm_stats" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    pages_active=$(echo "$vm_stats" | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    pages_inactive=$(echo "$vm_stats" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
    pages_wired=$(echo "$vm_stats" | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
    
    # Page size is typically 4096 bytes (4KB)
    page_size=4096
    
    # Convert pages to GB
    free_gb=$(echo "scale=2; ($pages_free * $page_size) / (1024 * 1024 * 1024)" | bc)
    active_gb=$(echo "scale=2; ($pages_active * $page_size) / (1024 * 1024 * 1024)" | bc)
    inactive_gb=$(echo "scale=2; ($pages_inactive * $page_size) / (1024 * 1024 * 1024)" | bc)
    wired_gb=$(echo "scale=2; ($pages_wired * $page_size) / (1024 * 1024 * 1024)" | bc)
    
    # Current memory usage
    current_mem_usage=$(ps -A -o %mem | awk '{sum+=$1} END {print sum}')
    
    # Output formatted memory information
    echo -e "${BLUE}Total Memory:${NC} $total_mem"
    echo -e "${BLUE}Free Memory:${NC} ${free_gb}GB"
    echo -e "${BLUE}Active Memory:${NC} ${active_gb}GB"
    echo -e "${BLUE}Inactive Memory:${NC} ${inactive_gb}GB"
    echo -e "${BLUE}Wired Memory:${NC} ${wired_gb}GB"
    echo -e "${BLUE}Total Memory Usage:${NC} ${current_mem_usage}%"
    
    # Top memory-intensive processes
    echo -e "\n${MAGENTA}Top 5 Memory-Intensive Processes:${NC}"
    ps aux | awk '{print $4 " " $11}' | sort -rn | head -5
}

# Temp Files Cleaning Function
clean_temp_files() {
    display_header
    echo -e "${YELLOW}Cleaning Temporary Files...${NC}"
    
    # List of temp directories to clean
    temp_dirs=(
        "$HOME/Library/Caches"
        "/Library/Caches"
        "/private/var/folders"
        "$HOME/Downloads/ChunkTemp"
        "$HOME/Library/Application Support/Google/Chrome/Default/Cache"
        "$HOME/Library/Application Support/Firefox/Profiles/*/cache2"
    )
    
    # Total size before cleaning
    before_size=$(du -sh "$HOME/Library/Caches" | cut -f1)
    
    for dir in "${temp_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo -e "${BLUE}Cleaning:${NC} $dir"
            find "$dir" -type f -mtime +7 -delete 2>/dev/null
        fi
    done
    
    # Additional temp file cleaning
    echo -e "${BLUE}Clearing system temp files...${NC}"
    sudo rm -rf /private/tmp/* 2>/dev/null
    
    # After size
    after_size=$(du -sh "$HOME/Library/Caches" | cut -f1)
    
    echo -e "\n${GREEN}Cleanup Complete!${NC}"
    echo -e "Cache size before: ${YELLOW}$before_size${NC}"
    echo -e "Cache size after:  ${GREEN}$after_size${NC}"
    
    read -p "Press Enter to continue..."
}

# Open Junk Folders Function
open_junk_folders() {
    display_header
    echo -e "${YELLOW}Opening Potential Junk Folders:${NC}"
    
    folders=(
        "$HOME/Library/Caches"
        "$HOME/Downloads"
        "$HOME/Library/Application Support/Google/Chrome/Default/Cache"
        "$HOME/Library/Logs"
        "/private/var/log"
    )
    
    for folder in "${folders[@]}"; do
        if [ -d "$folder" ]; then
            echo -e "${BLUE}Opening:${NC} $folder"
            open "$folder"
        fi
    done
    
    read -p "Press Enter to continue..."
}

# Large Files Finder Function
find_large_files() {
    display_header
    echo -e "${YELLOW}Finding Large Files (>100MB):${NC}"
    
    echo -e "${BLUE}Top 10 Largest Files in Home Directory:${NC}"
    find "$HOME" -type f -size +100M -print0 | xargs -0 ls -lhS | head -10
    
    echo -e "\n${BLUE}Disk Usage by Directories:${NC}"
    du -h "$HOME" | sort -rh | head -10
    
    read -p "Press Enter to continue or type 'd' to delete large files: " action
    if [[ "$action" == "d" ]]; then
        read -p "Enter full path of file to delete: " file_to_delete
        if [ -f "$file_to_delete" ]; then
            rm "$file_to_delete"
            echo -e "${GREEN}File deleted successfully.${NC}"
        else
            echo -e "${RED}Invalid file path.${NC}"
        fi
    fi
    
    read -p "Press Enter to continue..."
}

# Network Troubleshooting Submenu
network_tools() {
    while true; do
        display_header
        echo -e "${YELLOW}Network Troubleshooting Tools:${NC}"
        echo "1. Flush DNS Cache"
        echo "2. Restart Network Services"
        echo "3. Network Diagnostics"
        echo "4. Show Network Interfaces"
        echo "5. Test Internet Connectivity"
        echo "0. Return to Main Menu"
        
        read -p "Enter your choice: " network_choice
        
        case $network_choice in
            1)  
                echo -e "${BLUE}Flushing DNS Cache...${NC}"
                sudo killall -HUP mDNSResponder
                sudo dscacheutil -flushcache
                echo -e "${GREEN}DNS Cache Flushed!${NC}"
                read -p "Press Enter to continue..."
                ;;
            2)
                echo -e "${BLUE}Restarting Network Services...${NC}"
                sudo killall -HUP mDNSResponder
                sudo ifconfig en0 down
                sudo ifconfig en0 up
                echo -e "${GREEN}Network Services Restarted!${NC}"
                read -p "Press Enter to continue..."
                ;;
            3)
                echo -e "${BLUE}Running Network Diagnostics...${NC}"
                # Alternative network diagnostic commands
                echo -e "${YELLOW}Network Diagnostics:${NC}"
                echo -e "${BLUE}DNS Configuration:${NC}"
                scutil --dns
                
                echo -e "\n${BLUE}Routing Table:${NC}"
                netstat -nr
                
                echo -e "\n${BLUE}Active Network Interfaces:${NC}"
                networksetup -listnetworkserviceorder
                
                read -p "Press Enter to continue..."
                ;;
            4)
                echo -e "${BLUE}Network Interfaces:${NC}"
                ifconfig | grep flags
                read -p "Press Enter to continue..."
                ;;
            5)
                echo -e "${BLUE}Testing Internet Connectivity...${NC}"
                ping -c 4 8.8.8.8
                read -p "Press Enter to continue..."
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Clear RAM Function (Note: macOS manages memory differently)
clear_ram() {
    display_header
    echo -e "${YELLOW}RAM and Performance Optimization:${NC}"
    
    # Detailed memory information
    memory_stats
    
    echo -e "\n${MAGENTA}Performance Recommendations:${NC}"
    echo -e "${BLUE}1. Close Memory-Intensive Applications:${NC}"
    ps aux | awk '{if ($4 > 10.0) print "   - " $11 " (Memory Usage: " $4 "%)"}' | head -5
    
    echo -e "\n${BLUE}2. Potential Memory Cleanup:${NC}"
    echo "   - Clear application caches"
    echo "   - Remove unused downloads and temporary files"
    echo "   - Close background applications"
    
    echo -e "\n${RED}Note: macOS automatically manages memory efficiently.${NC}"
    echo -e "      Forced memory clearing is not recommended."
    
    read -p "Press Enter to continue..."
}

# Main Menu
main_menu() {
    while true; do
        display_header
        echo "1. View System Status"
        echo "2. Clean Temporary Files"
        echo "3. Open Junk Folders"
        echo "4. Find Large Files"
        echo "5. Network Tools"
        echo "6. RAM & Performance Optimization"
        echo "0. Exit"
        
        read -p "Enter your choice: " choice
        
        case $choice in
            1) system_status ;;
            2) clean_temp_files ;;
            3) open_junk_folders ;;
            4) find_large_files ;;
            5) network_tools ;;
            6) clear_ram ;;
            0) 
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Start the main menu
main_menu
