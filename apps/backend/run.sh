#!/bin/bash

# Load environment variables from .env file into the current shell
set -a
source .env
set +a


# File to store the PID of the master process
PID_FILE="master.pid"

NODEJS_BIN=$(which node)
NODEJS_APP="./main.js"
PYTHON_SCRIPT="${TASK_HOME}/scripts"
WHISPERX_TASK="exec_whisperx_task_v1.0.py"
LOG_DIR="${TASK_HOME}/log"

CURRENT_DATE=$(date +%Y-%m-%d)
LOG_FILE="${LOG_DIR}/sparrow-${CURRENT_DATE}.log"


# Start the application
start() {
    if [ -f "${PID_FILE}" ] && kill -0 $(cat "${PID_FILE}") 2>/dev/null; then
        echo "Sparrow is already running."
    else
        echo "Starting Sparrow..."

        # Kill any running exec_whisperx_task_v1.2.py processes before starting Sparrow
        # echo "Stopping any running exec_whisperx_task_v1.3.py processes..." >> "${LOG_FILE}"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Checking and stopping old whisperx task..." >> "${LOG_FILE}"
        
        # Ensure WHISPERX_TASK of the process are stopped before proceeding
        # while pgrep -f "${PYTHON_BIN} ${PYTHON_SCRIPT}/${WHISPERX_TASK}" > /dev/null; do
        #    pkill -f "${PYTHON_BIN} ${PYTHON_SCRIPT}/${WHISPERX_TASK}"
        #    sleep 1
        # done

        # Ensure all instances of the process are completely stopped before proceeding
        while pgrep -f "${PYTHON_SCRIPT}" > /dev/null; do
            pkill -f "${PYTHON_SCRIPT}"
            sleep 1
        done

        echo "$(date '+%Y-%m-%d %H:%M:%S') - All exec_whisperx_task_v*.py processes have been stopped." >> "${LOG_FILE}"

        echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting Sparrow app in ${NODE_ENV} mode." >> "${LOG_FILE}"
        nohup ${NODEJS_BIN} --trace-warnings ${NODEJS_APP} >> ${LOG_FILE} 2>&1 < /dev/null &
	#nohup ${NODEJS_BIN} ${NODEJS_APP} >> /dev/null 2>&1 < /dev/null &
        echo $! > "${PID_FILE}"
        echo "Sparrow started with PID $(cat ${PID_FILE})"
    fi
}

# Stop the application
stop() {
    if [ -f "${PID_FILE}" ] && kill -0 $(cat "${PID_FILE}") 2>/dev/null; then
        echo "Stopping sparrow..."
        kill -9 $(cat "${PID_FILE}")
        rm -f "${PID_FILE}"
        echo "Sparrow stopped."
    else
        echo "Sparrow is not running."
    fi
}

# Check the application status
status() {
    if [ -f "${PID_FILE}" ] && kill -0 $(cat "${PID_FILE}") 2>/dev/null; then
        echo "Sparrow is running with PID $(cat ${PID_FILE})"
    else
        echo "Sparrow is not running."
    fi
}

# Restart the application
restart() {
    echo "Restarting Sparrow..."
    stop
    start
}

# Handle command line arguments
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        restart
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac

