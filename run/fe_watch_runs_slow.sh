#!/bin/bash -norc
#==========================
# This script will continually
# check the output of runs already
# launched by scanning the
# created logs to create
# near-real time status
# reports.
#
# Invoke with:
# ./fe_watch_runs.sh &
#
# Once running, use something like
# the line below to see near-real
# time summary updates:
# watch -d gsutil cat gs://viking20/*.run.report
#
# The _slow version makes nice to
# read progress bars and calculates
# percentages, but it slows things
# down.
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
time_lag=5

# Each run goes though 73 steps and there
# are 32 runs on each node.
let total_steps_expected=73*32

# Initialize the current total number of
# time steps completed
let total_steps_completed=0

# Get start of the message
message_start="$HOSTNAME running "

# Loop while the simulation is running.
# It would be best to check that the
# active process is still running, but
# not done for now.
while [ $total_steps_completed -lt $total_steps_expected ]
do
    # Clear any previous report log
    rm -f tmp${report_ex}
    
    # Get a list of active runs based on
    # the number of present logs on this
    # node.
    run_list=`ls -1 run*.log`
    
    for run in $run_list
    do
	# Re initialize the current total number of
	# time steps completed - if we do not do this,
	# then the accumulator will grow with the
	# number of times we check on the runs!
	let total_steps_completed=0
	
	# Fine tune line prefix for this run
	message="$message_start $run |"
	
	# Determine the run progress
	let run_progress_step=`grep READ\ INPUT\ DATA $run | wc -l`
	let run_progress_percentage=`echo $run_progress_step | awk '{int(print $1/73)}'`

	# Accumulate the number of steps completed over
	# all runs for this node
	let total_steps_completed=$total_steps_completed+$run_progress_step
	
	# Add a progress bar for each separate run
	number_steps=$(($run_progress_percentage/10))
	let ii=1
	while [ $ii -le $number_steps ]
	do
	    message="$message#"
	    let ii=$ii+1
	done
	while [ $ii -le 10 ]
	do
	    message="$message-"
	    let ii=$ii+1	    
	done
	echo "$message|$run_progress_percentage% running..." >> tmp${report_ex}
    done

    # When done with each separate run, add a final
    # node summary line which is used by the top
    # level watching script.
    let total_percent_done=`echo $total_steps_completed | awk -v tot=$total_steps_expected '{int(print $1/tot)}'`
    echo "$message $total_percent_done% total percent done." >> tmp${report_ex}
    
    # Move the report to the cental location
    gsutil mv tmp${report_ex} ${report_bn}${HOSTNAME}${report_ex}

    # Wait until the next time to report
    sleep $time_lag
done
