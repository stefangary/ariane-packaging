#!/bin/bash -norc
#==========================
# Test printing growing
# status bars.
# 
# Stefan Gary, copyright 2018
# This software is distributed
# under the terms of the GNU
# GPLv3 and any later versions.
#==========================

# Set the time lag for reporting
# Default is 2 for watch, but since
# many nodes are doing this at the
# sime time, there's no need for
# updates quite that fast.
time_lag=1

# Set total number of loops
num_loops=100
jj=1
while [ $jj -le $num_loops ]
do
    # Get start of the message
    message="$HOSTNAME $@ |"
    
    current_percentage=$jj
    number_steps=$(($current_percentage/10))
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
    echo "$message|$current_percentage% looping..." > tmp.log
    sleep $time_lag

    let jj=$jj+1
done
