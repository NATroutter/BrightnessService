#!/bin/bash

######################################################################################
#                                                                                    #
# PROGRAM CONFIGURATION!                                                             #
#                                                                                    #
######################################################################################

# Set your display
export DISPLAY=:0

#Service name
SERVICE_NAME="brightness.service"
SERVICE_PATH="/etc/systemd/system" # NO TRAILING SLASHES!

# Path to brightness control
BRIGHTNESS_PATH="/sys/class/backlight/10-0045/brightness"
DESKTOP_USER="pi"

# Brightness levels
FULL_BRIGHTNESS=150
DIM_BRIGHTNESS=0

# Time to wait before dimming (in seconds)
INACTIVITY_TIME=3

# Print debug messages
DEBUG=0

######################################################################################
#                                                                                    #
# PROGRAM STARTS HERE DO NOT EDIT!                                                   #
#                                                                                    #
######################################################################################
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#Variables
DIM=1
last_mouse=""
idle_start=0
SERV_PATH="$SERVICE_PATH/$SERVICE_NAME"

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"

# -------------------------
# Helper function to check if service is installed
# -------------------------
service_installed() {
    if [ ! -f "$SERV_PATH" ]; then
        echo "Error: $SERV_PATH is not installed."
        return 1
    fi
    return 0
}

get_timestamp() {
    date +"%d.%m.%Y-%H:%M:%S"
}

# -------------------------
# Functions for each action
# -------------------------

start_service() {
    service_installed || exit 1
    echo "Starting $SERVICE_NAME..."
    sudo systemctl start $SERVICE_NAME
}

stop_service() {
    service_installed || exit 1
    echo "Stopping $SERVICE_NAME..."
    sudo systemctl stop $SERVICE_NAME
}

restart_service() {
    service_installed || exit 1
    echo "Restarting $SERVICE_NAME..."
    sudo systemctl restart $SERVICE_NAME
}

status_service() {
    service_installed || exit 1
    echo "Status of $SERVICE_NAME:"
    sudo systemctl status $SERVICE_NAME
}

run_service() {
    #Startup info
    [[ "$DEBUG" -eq 1 ]] && echo "[$(get_timestamp)] Starting auto-dim script..."
    [[ "$DEBUG" -eq 1 ]] && echo "[$(get_timestamp)] Full brightness: $FULL_BRIGHTNESS, Dim brightness: $DIM_BRIGHTNESS"
    [[ "$DEBUG" -eq 1 ]] && echo "[$(get_timestamp)] Inactivity time before dimming: $INACTIVITY_TIME seconds"

    while true; do

        # Check owner of the brightness file
        owner=$(stat -c "%U" "$BRIGHTNESS_PATH")

        if [[ "$owner" != "$DESKTOP_USER" ]]; then
            sudo chown $DESKTOP_USER "$BRIGHTNESS_PATH"
            echo "[$(get_timestamp)] Corrected ownership of brightness file"
        fi


        #Get current mouse position
        eval $(xdotool getmouselocation --shell)
        mouse="$X-$Y"

        [[ "$DEBUG" -eq 1 ]] && echo "[$(get_timestamp)] Current mouse position: $mouse"

        # If mouse position changed
        if [[ "$mouse" != "$last_mouse" ]]; then

            [[ "$DEBUG" -eq 1 ]] && echo "[$(get_timestamp)] Mouse moved."

            last_mouse="$mouse"
            idle_start=$(date +%s)

            # Restore full brightness if needed

            [[ "$DEBUG" -eq 1 ]] && echo "[$(get_timestamp)] Restoring full brightness."
            [[ ! "$DEBUG" -eq 1 && "$DIM" -eq 1 ]] && echo "[$(get_timestamp)] User interacted - Restoring brightness.!"

            echo $FULL_BRIGHTNESS | tee $BRIGHTNESS_PATH > /dev/null
            DIM=0

        else

            # Calculate idle time
            now=$(date +%s)
            idle=$((now - idle_start))

            [[ "$DEBUG" -eq 1 ]] && echo "[$(get_timestamp)] Mouse idle for $idle seconds."

            # Dim the screen if idle for more than INACTIVITY_TIME
            if (( idle >= INACTIVITY_TIME )); then

                [[ "$DEBUG" -eq 1 ]] && echo "[$(get_timestamp)] Mouse idle for $INACTIVITY_TIME+ seconds, dimming screen."
                [[ ! "$DEBUG" -eq 1 && "$DIM" -eq 0 ]] && echo "[$(get_timestamp)] User has not interacted for $INACTIVITY_TIME seconds - Dimming screen!"

                echo $DIM_BRIGHTNESS | tee $BRIGHTNESS_PATH > /dev/null
                DIM=1

            fi
        fi
    done
}

restore_brightness() {
    echo "Restoring full brightness..."
    echo $FULL_BRIGHTNESS | tee $BRIGHTNESS_PATH > /dev/null
    exit 1
}

install_service() {
    echo "Installing $SERVICE_NAME..."

    # Create the systemd service file
    sudo tee "$SERV_PATH" > /dev/null <<EOL
[Unit]
Description=Auto screen brightness
After=multi-user.target

[Service]
User=$DESKTOP_USER
Environment="DISPLAY=:0"
Environment="XAUTHORITY=/home/$DESKTOP_USER/.Xauthority"
Type=simple
ExecStart=/bin/bash $SCRIPT_PATH run
ExecStop=/bin/bash $SCRIPT_PATH restore
ExecStopPost=/bin/bash $SCRIPT_PATH restore
Restart=always

[Install]
WantedBy=multi-user.target

EOL

    # Reload systemd daemon, enable and start service
    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME

    echo "$SERVICE_NAME installed."
}

usage() {
    echo "Usage: $0 {start|stop|status|restart|run|restore|install}"
    exit 1
}

# -------------------------
# Main script execution
# -------------------------

# Check if argument is provided
if [ $# -lt 1 ]; then
    usage
fi

# Read the first argument
ACTION=$1

# Call the corresponding function
case "$ACTION" in
    start) start_service ;;
    stop) stop_service ;;
    restart) restart_service ;;
    status) status_service ;;
    run) run_service ;;
    restore) restore_brightness ;;
    install) install_service ;;
    *) usage ;;
esac