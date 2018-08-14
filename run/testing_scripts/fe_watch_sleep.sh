#!/bin/bash -norc
#==========================
# This script will run its
# input script and then scan
# the created logs to create
# near-real time status
# updates.
#
# Invoke with:
# ./fe_watch_run.sh ./fe_run_ariane_in_parallel.sh
#
# Once running, use something like
# the line below to see near-real
# time summary updates:
# watch -d gsutil cat gs://viking20/*.run.report
#
# THIS PARTICULAR VERSION IS
# A SIMPLE TESTING SCRIPT THAT
# IS USED WITH sleep 30 TO
# CHECK PROGRESS.
# 
# Copyright, Stefan Gary, 2018
# This software is distributed
# under the terms of the GNU
# GPL v3 and any later version.
#============================

# Set the distant location for
# sending the files
report_bn=gs://viking20/node-
report_ex=.run.report

# Set the time lag for reporting
# Default is 2 for watch, but since
# many nodes are doing this at the
# sime time, there's no need for
# updates quite that fast.
time_lag=1

# Run the script the user wants
# in the background.
$@ &

# Get the process ID for this running script
run_pid=$!

# Loop while the simulation is running.
# If the command is still active, then
# there will be at least two lines in the ps
# command output.  If the process does not
# exist any more, then there will be only
# one line of output.
while [ $(ps -p $run_pid | wc -l) -gt 1 ]
do
    # Get start of the message
    message="$HOSTNAME running $@ |"

    # Print message
    echo $message > tmp.log
    
    # Wait until the next time to report
    sleep $time_lag
done

# Make certain we are actually done
wait

# Do it one last time when done
echo "$message DONE!" > tmp.log
