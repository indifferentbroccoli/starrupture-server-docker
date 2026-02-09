#!/bin/bash
# shellcheck source=scripts/functions.sh
source "/home/steam/server/functions.sh"

LogAction "Set file permissions"

# if the user has not defined a PUID and PGID, throw an error and exit
if [ -z "${PUID}" ] || [ -z "${PGID}" ]; then
    LogError "PUID and PGID not set. Please set these in the environment variables."
    exit 1
else
    usermod -o -u "${PUID}" steam
    groupmod -o -g "${PGID}" steam
fi

chown -R steam:steam /home/steam/server-files /home/steam/

cat /branding

if [ "${UPDATE_ON_START:-true}" = "true" ]; then
    install
else
    LogWarn "UPDATE_ON_START is set to false, skipping server update from Steam"
fi

# shellcheck disable=SC2317
term_handler() {
    if ! shutdown_server; then
        # Force shutdown if graceful shutdown fails
        kill -SIGTERM "$(pidof wine-preloader)"
    fi
    tail --pid="$killpid" -f 2>/dev/null
}

trap 'term_handler' SIGTERM

export DEFAULT_PORT
export SERVER_NAME
export MULTIHOME
export ADMIN_PASSWORD
export PLAYER_PASSWORD
export USE_DSSETTINGS
export SESSION_NAME
export SAVE_GAME_INTERVAL
export START_NEW_GAME
export LOAD_SAVED_GAME
export SAVE_GAME_NAME

# Start the server as steam user
su - steam -c "cd /home/steam/server && DEFAULT_PORT='${DEFAULT_PORT}' SERVER_NAME='${SERVER_NAME}' MULTIHOME='${MULTIHOME}' ADMIN_PASSWORD='${ADMIN_PASSWORD}' PLAYER_PASSWORD='${PLAYER_PASSWORD}' USE_DSSETTINGS='${USE_DSSETTINGS}' SESSION_NAME='${SESSION_NAME}' SAVE_GAME_INTERVAL='${SAVE_GAME_INTERVAL}' START_NEW_GAME='${START_NEW_GAME}' LOAD_SAVED_GAME='${LOAD_SAVED_GAME}' SAVE_GAME_NAME='${SAVE_GAME_NAME}' ./start.sh" &

# Process ID of su
killpid="$!"
wait "$killpid"
