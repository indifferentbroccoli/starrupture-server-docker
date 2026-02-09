#!/bin/bash

#================
# Log Definitions
#================
export LINE='\n'                        # Line Break
export RESET='\033[0m'                  # Text Reset
export WhiteText='\033[0;37m'           # White

# Bold
export RedBoldText='\033[1;31m'         # Red
export GreenBoldText='\033[1;32m'       # Green
export YellowBoldText='\033[1;33m'      # Yellow
export CyanBoldText='\033[1;36m'        # Cyan
#================
# End Log Definitions
#================

LogInfo() {
  Log "$1" "$WhiteText"
}
LogWarn() {
  Log "$1" "$YellowBoldText"
}
LogError() {
  Log "$1" "$RedBoldText"
}
LogSuccess() {
  Log "$1" "$GreenBoldText"
}
LogAction() {
  Log "$1" "$CyanBoldText" "====" "===="
}
Log() {
  local message="$1"
  local color="$2"
  local prefix="$3"
  local suffix="$4"
  printf "$color%s$RESET$LINE" "$prefix$message$suffix"
}

install() {
  LogAction "Starting server install"
  LogInfo "Installing StarRupture Dedicated Server (App ID: 3809400)"
  /home/steam/steamcmd/steamcmd.sh +runscript /home/steam/server/install.scmd
}

# Attempt to shutdown the server gracefully
# Returns 0 if it is shutdown
# Returns 1 if it is not able to be shutdown
shutdown_server() {
    local return_val=0
    LogAction "Attempting graceful server shutdown"
    
    # Find the process ID
    local pid=$(pidof wine-preloader)
    
    if [ -n "$pid" ]; then
        # Send SIGTERM to allow graceful shutdown
        kill -SIGTERM "$pid"
        
        # Wait up to 30 seconds for process to exit
        local count=0
        while [ $count -lt 30 ] && kill -0 "$pid" 2>/dev/null; do
            sleep 1
            count=$((count + 1))
        done
        
        # Check if process is still running
        if kill -0 "$pid" 2>/dev/null; then
            LogWarn "Server did not shutdown gracefully, forcing shutdown"
            return_val=1
        else
            LogSuccess "Server shutdown gracefully"
        fi
    else
        LogWarn "Server process not found"
        return_val=1
    fi
    
    return "$return_val"
}

# Generate password JSON files
generate_password_files() {
    local server_files="$1"
    local admin_pass="$2"
    local player_pass="$3"
    
    [ -z "$admin_pass" ] && [ -z "$player_pass" ] && return
    
    LogInfo "Generating encrypted password files..."
    
    local response=$(curl -sf -X POST https://starrupture-utilities.com/passwords/ \
        -d "adminpassword=${admin_pass}" \
        -d "playerpassword=${player_pass}")
    
    if [ $? -ne 0 ]; then
        LogWarn "Failed to generate passwords via API. Generate manually at: https://starrupture-utilities.com/passwords/"
        return
    fi
    
    if [ -n "$admin_pass" ]; then
        local admin_encrypted=$(echo "$response" | jq -r '.adminpassword')
        echo "{\"password\":\"$admin_encrypted\"}" > "$server_files/Password.json" && LogSuccess "Admin password configured"
    fi
    
    if [ -n "$player_pass" ]; then
        local player_encrypted=$(echo "$response" | jq -r '.playerpassword')
        echo "{\"password\":\"$player_encrypted\"}" > "$server_files/PlayerPassword.json" && LogSuccess "Player password configured"
    fi
}
