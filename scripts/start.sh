#!/bin/bash
# shellcheck source=scripts/functions.sh
source "/home/steam/server/functions.sh"

SERVER_FILES="/home/steam/server-files"

cd "$SERVER_FILES" || exit

LogAction "Starting StarRupture Dedicated Server"

# Set defaults if not provided
DEFAULT_PORT="${DEFAULT_PORT:-7777}"
QUERY_PORT="${QUERY_PORT:-27015}"
SERVER_NAME="${SERVER_NAME:-starrupture-server}"
USE_DSSETTINGS="${USE_DSSETTINGS:-true}"

if [ "${USE_DSSETTINGS}" = "true" ]; then
    SESSION_NAME="${SESSION_NAME:-StarRuptureServer}"
    SAVE_GAME_INTERVAL="${SAVE_GAME_INTERVAL:-300}"
    START_NEW_GAME="${START_NEW_GAME:-false}"
    LOAD_SAVED_GAME="${LOAD_SAVED_GAME:-true}"
    SAVE_GAME_NAME="${SAVE_GAME_NAME:-AutoSave0.sav}"

    DSSETTINGS_FILE="$SERVER_FILES/DSSettings.txt"

    LogInfo "Generating DSSettings.txt from environment variables"
    cat > "$DSSETTINGS_FILE" <<EOF
{
  "SessionName": "$SESSION_NAME",
  "SaveGameInterval": "$SAVE_GAME_INTERVAL",
  "StartNewGame": "$START_NEW_GAME",
  "LoadSavedGame": "$LOAD_SAVED_GAME",
  "SaveGameName": "$SAVE_GAME_NAME"
}
EOF

    LogSuccess "DSSettings.txt configured with SessionName: $SESSION_NAME"
    
    generate_password_files "$SERVER_FILES"
else
    LogWarn "USE_DSSETTINGS is disabled - DSSettings.txt will not be generated"
    LogWarn "You must forward port 7777 TCP to use the in-game Server Manager"
    LogWarn "WARNING: Forwarding TCP exposes your server to security vulnerabilities"
    LogWarn "See: https://wiki.starrupture-utilities.com/en/dedicated-server/Vulnerability-Announcement"
fi

SERVER_EXEC="$SERVER_FILES/StarRupture/Binaries/Win64/StarRuptureServerEOS-Win64-Shipping.exe"

if [ ! -f "$SERVER_EXEC" ]; then
    LogError "Could not find server executable at: $SERVER_EXEC"
    LogError "Directory contents:"
    ls -laR "$SERVER_FILES/"
    exit 1
fi

LogInfo "Found server executable: ${SERVER_EXEC}"
LogInfo "Server starting on port ${DEFAULT_PORT}"
LogInfo "Query port: ${QUERY_PORT}"
LogInfo "Server name: ${SERVER_NAME}"

# Build the startup command with Wine and xvfb
STARTUP_CMD="xvfb-run --auto-servernum wine ${SERVER_EXEC} -Log -Port=${DEFAULT_PORT} -QueryPort=${QUERY_PORT} -ServerName=\"${SERVER_NAME}\""

# Add multihome if specified
if [ -n "${MULTIHOME}" ]; then
    STARTUP_CMD="${STARTUP_CMD} -MULTIHOME=${MULTIHOME}"
fi

LogInfo "Starting with Wine..."

# Start the server
eval "$STARTUP_CMD"
