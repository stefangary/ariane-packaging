#!/bin/bash --norc
#=======================================
# Our goal is to try running multiple
# isntances of ARIANE at the same time
# so that each instance pulls the same
# data from the kernal cache, thus
# minimizing the amount of time data is
# both copied to a node as well as data
# is read from disk to RAM.
#=======================================

# The following loops over years, seasons,
# and the 5 larval swimming parameters
# break up what could be a giant single
# run into many small runs.

#---------------------------------------
# 1) Set the years and seasons
#---------------------------------------
#
# This is done at the node setup stage,
# IN A LOOP OUTSIDE THIS ROUTINE.
#
# Any year/seasonal difference in the
# simulations is entirely due to selecting
# which subset of the input files are
# copied to the node.
#
# Breaking up the big runs by years
# and seasons should help distribute/parallelize
# the I/O bottleneck.  The full span
# will be [1959,...,2008] and [DJF,MAM,JJA,SON].
#
# NOTE: BECAUSE OF DJF AS A SEASON, THIS
# SCRIPT WILL DRAW DATA FROM YEAR-1 FOR
# DECEMBER.  Also, for the other seasons,
# the *start* time is the beginning of
# that season, so YEAR+1 will be used so
# we have full-length, one-year trajectories.
#
# Just to be clear - our goal is to create
# ensembles of simulated year-long particle
# tracks.  EACH TRACK IS ALWAYS 1 YEAR LONG.
# To account for seasonal and interannual
# variabilty, we launch particles, from
# exactly the same launch locations each
# time, at four different seasons at
# each year.  There are 50 years of total
# data we can use to drive our simulation,
# but here we use just two years.
#
# Although the particle tracks are simulated
# and post-processed separately, it is
# straightforward linear superposition to
# add together the tracks and post-processed results
# across the many simulations because the
# primary results of the post-processing are
# histograms (raw counts), not probability
# distributions (which would require weighting
# by number of individuals to combine).
#
#------------------------------------------

#------------------------------------------
# 2) Loop over larval behavior.
#------------------------------------------
# There are 5 parameters that govern the larval
# behavior so we have 5 nested loops here.
# The outermost loops must be larval behavior
# since that is the one set of parameters that
# changes from simulation to simulation.
#
# They are: time for ramp-up [s], time at surface [s],
# upward swiming speed [m/s], downward swiming speed [m/s]
# (NO need to specify negative sign!!!), and
# target depth [k-index units].  These params are passed in
# this order to build_larval_behaviors.txt
# as well as to ARIANE.
#
# To double check units,
# t1 = [0days to 10days] -> passed in [s]
# t2 = [4days to 42days] -> passed in [s]
# s1 = [0.2mm/s to 1mm/s] -> passed in [m/s]
# s2 = [0.2mm/s to 1mm/s] -> passed in [m/s]
# d1 = [12m to 150m] -> passed in k-index
#                      use VIKING20 vertical grid spacing,
#                      gdepw_0 in mesh_mask.nc to check!
#------------------------------------------
t1_list_rampup='0.0'
t2_list_surfag='345600.0'
s1_list_swimup='0.00020'
s2_list_swimdn='0.00020'
d1_list_target='3'
let runnum=0
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
#--------->INSERT COMMAND TO RUN DOCKER CONTAINER HERE
		    let runnum=$runnum+1
		    docker run --rm --name=ariane_container${runnum} -v/home/stefanfgary/larval-parameter-sweep/run:/app/run -w/app/run stefanfgary/ariane ./set_and_run_ariane_and_pp.sh $t1 $t2 $s1 $s2 $d1 &> run${runnum}.log &
		done # with d1 loop
	    done # with s2 loop
	done # with s1 loop
    done # with t2 loop
done # with t1 loop
	#----------Done with all larval params loops--------------------

# Dummy single item loop limts for testing.
t1_list_rampup='0.0'
t2_list_surfag='345600.0'
s1_list_swimup='0.00020'
s2_list_swimdn='0.00020'
d1_list_target='13'

# The script called here engages both
# ARIANE itself and the necessary postprocessing.
# NOTE: I'm launching Docker from my current
# working directory and also mounting that
# directory as the current working directory for
# the Docker container.  I don't know if that's
# good practice, but I'm doing that here as a
# first try and for these purposes appears to work
# fine.
#----------------EXAMPLE FOR STANDALONE WORKSTATION------------------
#docker run --rm --name=ariane_container1 -v/md0/sa03sg/work/ariane_container_tests/larval-parameter-sweep/run:/app/run -v/md0/sa03sg/scratch/VIKING20_nest_5d/cut_ATLAS/UV:/app/data -w/app/run stefanfgary/ariane ./set_and_run_ariane_and_pp.sh $t1_list_rampup $t2_list_surfag $s1_list_swimup $s2_list_swimdn $d1_list_target &> run1.log &

#----------------EXAMPLE FOR GCE NODE------------------
#docker run --rm --name=ariane_container2 -v/home/stefanfgary/larval-parameter-sweep/run:/app/run -w/app/run stefanfgary/ariane ./set_and_run_ariane_and_pp.sh $t1_list_rampup $t2_list_surfag $s1_list_swimup $s2_list_swimdn $d1_list_target &> run2.log &

#s1_list_swimup='0.00100'
#docker run --rm --name=ariane_container3 -v/home/stefanfgary/larval-parameter-sweep/run:/app/run -w/app/run stefanfgary/ariane ./set_and_run_ariane_and_pp.sh $t1_list_rampup $t2_list_surfag $s1_list_swimup $s2_list_swimdn $d1_list_target &> run3.log &

# Don't put sudo here if you want to put it in the background!
# Be careful you have different container names!!!

# Get rid of copied input data.
# This is not explicitly required
# since the node is not persistent.

    
