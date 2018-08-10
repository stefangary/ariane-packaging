#!/bin/bash -norc
#==========================
# This front end script
# will start the copy
# process, run the simulation,
# and send real-time update
# information
# to another location
# for "watching".
#
# NOTE: this does not use
# the watch command which
# is designed to send output
# to the screen, not a log
# file as we desire here.
#
# The way this reporting
# system works is that each
# node reports a summary of
# its status with a separate
# file.  It is important
# that each node writes to
# its own file - that way
# individual nodes can be
# watched or all nodes
# can be watched.  If they
# all write to the same file,
# they can potentially
# overwrite at different times.
#
# At the separate location,
# concatenate all nodes' progress
# files together like:
# $ watch cat node_update*.txt
# or just watch one node with:
# $ watch cat node_update_my_favorite_node_name.txt
# 
# Stefan Gary, copyright 2018
# This software is distributed
# under the terms of the GNU
# GPLv3 and any later versions.
#==========================

# Set the distant location for
# sending the files
report_bn=gs://viking20/data_copy_node_
report_ex=.report

# Set the time lag for reporting
# Default is 2 for watch.
time_lag=2

# Set the directory to watch for data
data_copy_watch_dir=/tmp/swiftwork/larval-parameter-sweep

# Set the final expected size of the directory
# This does not have to be exact.  Currently
# working in [GB], need generality later.
final_size=89

# Pass the command line params onto the command
# and run it in the background.
./copy_data_to_node.sh $@ &

# Get process ID of the copy operation
copy_pid=$!

# Loop while the data is copying.
# If the command is still active, then
# there will be at least two lines in the ps
# command output.  If the process does not
# exist any more, then there will be only
# one line of output.
while ( `ps -p $copy_pid | wc -l` > 1 )
do
    # Get the number of gigabytes in the input directory
    # which is the last line of the du command and then
    # the first number after "G".  Then convert that number
    # of GB into a percentage based on the amount of
    # expected GB to be copied.
    current_percentage=`du -h $data_copy_watch_dir | tail -1 | awk -FG -v fs=$final_size '{print int(100*$1/fs)}'`
    echo $hostname $current_percentage'% data copying...' > tmp.log
    gsutil mv tmp.log ${report_bn}${hostname}${report_ex}
    sleep $time_lag
done

# Do it one last time when done
echo $hostname $current_percentage'% data copying done.' > tmp.log
gsutil mv tmp.log ${report_bn}${hostname}${report_ex}

#####################################################
# to make things look nice, consider using something like this:
#echo -ne '#####                     (33%)\r'
#sleep $time_lag
#echo -ne '#############             (42%)\r'
#sleep $time_lag
#echo -ne '#######################   (100%)\r'
#echo -ne '\n'
#####################################################
