#!/bin/bash --norc
#=======================================
# This script is a template for looping
# over all the required runs for ARIANE
#
# THIS IS THE PRIMARY FILE THAT
# WILL NEED TO BE TRANSLATED TO SWIFT.
#=======================================

# The following loops over years, seasons,
# and the 5 larval swimming parameters
# break up what could be a giant single
# run into many small runs.

#---------------------------------------
# 1) Set the years and seasons
#---------------------------------------
#
# This is done at the node setup stage.
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
year_list='1959'
season_list='DJF'

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
#t1_list_rampup='0.0 864000.0'
#t2_list_surfag='345600.0 3628800.0'
#s1_list_swimup='0.00020 0.00100'
#s2_list_swimdn='0.00020 0.00100'
#d1_list_target='3 13'

# Dummy single item loop limts for testing.
t1_list_rampup='0.0'
t2_list_surfag='345600.0'
s1_list_swimup='0.00020'
s2_list_swimdn='0.00020'
d1_list_target='3'

# Loop over years
for year in $year_list
do
    # Loop over seasons
    for season in $season_list
    do
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

			    #---------------------------------------
			    # 3) Pass larval behavior to simulation
			    #---------------------------------------
			    # Deep in the behavior loops, here
			    # we build the larval_behaviors.txt
			    # file that ARIANE will read to define
			    # the specific larval behavior for
			    # this particular run.  This script
			    # grabs the total number of particles to
			    # run from initial_positions.txt - the
			    # unchanging launch locations of the larvae.
			    ./build_larval_behaviour.sh $t1 $t2 $s1 $s2 $d1

			    #------------------------------------------
			    # 4) Set up directory to store output
			    #------------------------------------------
			    # Create a directory for this
			    # combination of larval behaviors
			    # to organize the output.
			    #
			    # NOTE: if we are passing data back to
			    # cloud storage, then best to make these
			    # directories earlier, not during runtime.
			    outdir=larval_run_${t1}_${t2}_${s1}_${s2}_${d1}
			    mkdir $outdir

			    #------------------------------------------
			    # 5b) Run ARIANE via a Docker container.
			    #------------------------------------------
			    # The script called here engages both
			    # ARIANE itself and the necessary postprocessing.
			    # NOTE: I'm launching Docker from my current
			    # working directory and also mounting that
			    # directory as the current working directory for
			    # the Docker container.  I don't know if that's
			    # good practice, but I'm doing that here as a
			    # first try and for these purposes appears to work
			    # fine.
			    #
			    docker run -v~/run:/app/run -w/app/run --rm ariane_container ./run_ariane_and_postprocess.sh
			    
			    #------------------------------------------
			    # 5c) Track files by year and season and clean up
			    #------------------------------------------
			    # Rename the main output files to year
			    # and season and move them to the directory
			    # for this run so we can keep
			    # track of the outputs from each subrun.
			    #
			    # In future versions, I anticipate creating
			    # directories for each year and season and
			    # changing the file naming convention.
			    mv -f hist.nc ${outdir}/hist_${year}_${season}.nc
			    mv -f t.cdf ${outdir}/t_${year}_${season}.cdf
			    #mv -f alive.nc ${outdir}/alive_${year}_${season}.nc


			    # Clean up - if this file is not removed, then
			    # subsequent runs will simply append more larval
			    # behaviors to the original file which means
			    # that the larval behaviors will not change
			    # since only the first n-particles lines will
			    # be read from the file.
			    rm -f larval_behaviors.txt
		    
			done # with d1 loop
		    done # with s2 loop
		done # with s1 loop
	    done # with t2 loop
	done # with t1 loop
	#----------Done with all larval params loops--------------------

    done # with the season loop
done # with the year loop
#-------------Done with all loops for year and season-------
	
# Get rid of copied input data.
# This is not explicitly required
# since the node is not persistent.

    
