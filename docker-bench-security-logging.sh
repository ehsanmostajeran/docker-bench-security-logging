#!/bin/bash

# Create timestamp in the format of mm/dd/yyy hh:mm:ss
timestamp=$(date +"%m/%d/%Y %H:%M:%S")
# Set host variable as the system hostname
host=$(hostname)
# Log file location
logfile='dockerbenchsecurity.json'
# Set check variable as the first command line argument
check=$1
# Set check variable as the second command line argument
check_description=$2
# Set check variable as the third command line argument
status=$3
# Set check variable as the fourth command line argument
status_details=$4

# Check if no arguments are supplied
if [ $# -eq 0 ]
  then
    echo "usage: docker-bench-security-logging [docker check] [docker check description] [docker check status] [docker check status description]"
fi

# Create json file
cat << EOF >> $logfile
{"timestamp" : "$timestamp","host" : "$host","check" : "$check","check_description" : "$check_description","status" : "$status","status_details" : "$status_details" }
EOF
