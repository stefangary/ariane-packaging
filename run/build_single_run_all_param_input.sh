#!/bin/bash --norc
#=======================================
# Our goal is to try running multiple
# isntances of ARIANE at the same time
# so that each instance pulls the same
# data from the kernal cache, thus
# minimizing the amount of time data is
# both copied to a node as well as data
# is read from disk to RAM.
#
# After some experimentation, it seems
# that running all perturbations to
# larval behavior at the same time
# might be the most efficient way to
# leverage loading data to memory
# with the cost of not parallelizing
# the compute time but rather parallelizing
# the I/O.
#
# This script will build the
# initial_positions.txt
# and
# larval_behaviours.txt
# files necessary for this single run.
#=======================================

# To double check units,
# t1 = [0days to 10days] -> passed in [s]
# t2 = [4days to 42days] -> passed in [s]
# s1 = [0.2mm/s to 1mm/s] -> passed in [m/s]
# s2 = [0.2mm/s to 1mm/s] -> passed in [m/s]
# d1 = [12m to 150m] -> passed in k-index
#                      use VIKING20 vertical grid spacing,
#                      gdepw_0 in mesh_mask.nc to check!
#------------------------------------------
t1_list_rampup='0.0 864000.0'
t2_list_surfag='345600.0 3628800.0'
s1_list_swimup='0.00020 0.00100'
s2_list_swimdn='0.00020 0.00100'
d1_list_target='3 13'

# Loop over larval parameters
for t1 in $t1_list_rampup
do
    for t2 in $t2_list_surfag
    do
	for s1 in $s1_list_swimup
	do
	    for s2 in $s2_list_swimdn
	    do
		for d1 in $d1_list_target
		do
		    # Make a file for a single combination
		    # NOTE: this script will automatically
		    # accumulate to larval_behaviour.txt
		    ./build_larval_behaviour.sh $t1 $t2 $s1 $s2 $d1

		    # Accumulate that information to long-term files
		    cat initial_positions.txt >> initial_positions.all.txt

	      done # with d1 loop
	  done # with s2 loop
       done # with s1 loop
    done # with t2 loop
done # with t1 loop
