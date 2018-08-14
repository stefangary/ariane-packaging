#!/bin/bash -norc
#==============================
# Set up run space, run ARIANE,
# and run postprocessing (pp).
#
# This script is designed to run
# INSIDE the ARIANE container.
#
# The outputs to this are:
# 1) t.cdf - the particle tracks
# 2) hist.nc - a histogram of the particle tracks (postprocessing step 1)
# 3) alive.nc - a histogram of particle survival (postprocessing step 2).
# NOTE: the code for postprocessing steps 1 and 2 is still
# under development.  The computational time required for hist.nc (step1)
# will be nearly the same compared to the version used here.  The
# time required for alive.nc (step2) will be much less than step1
# and an example is not ready yet.  It is not critical that the
# postprocessing be ready at the time of the full runs, but I
# think it would be great if we could incorporate that into the
# fully parallelized runs to fully maximize the parallelization.
#==============================

#------------------------------------------
# 1) Set up directory to store output
#------------------------------------------
# Create a directory for this
# combination of larval behaviors
# to organize the output and make this
# directory the working directory.
#
# NOTE: if we are passing data back to
# cloud storage, then best to make these
# directories earlier, not during runtime.
rundir=larval_run_all
mkdir ${rundir}
cd ${rundir}

#------------------------------------------
# 2) Create links for critical files
#------------------------------------------
ln -sv ../namelist ./
ln -sv ../mesh_mask.nc ./
ln -sv ../initial_positions.txt ./
#ln -sv ../DATA ./ # This does not work if DATA is full of links, ARIANE crashes following link of link.
mkdir ./DATA
cd DATA
ln -sv ../../DATA/mklist_VIKING20.sh ./
./mklist_VIKING20.sh 1962 DJF
cd ../
ln -sv ../split_file.txt ./
ln -sv ../larval_behaviour.txt ./

#------------------------------------------
# 3) Set larval params for this run
#------------------------------------------
# NOTE NEEDED HERE

#------------------------------------------
# 4) Run ARIANE
#------------------------------------------
/usr/bin/ariane

# Post run clean up
rm -f fort.*
rm -f ariane_memory.log 
rm -f mod_criter*

#=====================================
# Postprocessing step 1: convert
#=====================================
# Convert to tcdf, output file is t.cdf
# Default ARIANE output has much more
# precision than needed, so leverage
# packing to create smaller output files.
#
# NOTE: There is a small bug somewhere
# that causes the resulting bdep variable
# (bottom depth) to have some occasional
# fill values on lab01 but not on my laptop.
# Aside from that, the files and subsequent
# processing are identical.  We don't need
# bdep here, so do not pursue further.
/usr/bin/ariane2tcdf -I ariane_trajectories_qualitative.nc -J -P 

# Clean up - remove original output file.
rm -f ariane_trajectories_qualitative.nc

#=========================================
# Postprocessing step 2 - split
#=========================================

# Split by larvale params
/usr/bin/tcdfsplit -N 46126 -I t.cdf -J

# Spilt trajectories by Case Study
# NOT IMPLEMENTED YET FOR SIMPLICITY
# tcdfsplit

#=========================================
# Postprocessing step 3 - spatial histogram
#=========================================
#
# This step is the best visualization tool
# to check if the overall results are reasonable.
#
# Will need to change the domain of the histogram (-X and -Y flags)
# and the number of particles (-P flag) to better
# match the larger-scale, full simulation
# WISH LIST: auto determine number of particles and domain size.
# Default output is hist.nc
/usr/bin/tcdfhist -X -80.0 50.0 0.25 -Y 30.0 85.0 0.25 -I t.cdf -P 1 46126 0

#=========================================
# Postprocessing step 4 - survival
#=========================================
# Default output will be alive.nc
# NOT IMPLEMENTED YET
#tcdfalive
