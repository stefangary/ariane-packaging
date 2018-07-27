#!/bin/bash -norc
#==============================
# Set up run space, run ARIANE,
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
rundir=larval_run_${1}_${2}_${3}_${4}_${5}
mkdir ${rundir}
cd ${rundir}

#------------------------------------------
# 2) Create links for critical files
#------------------------------------------
ln -sv ../namelist ./
ln -sv ../mesh_mask.nc ./
ln -sv ../initial_positions.txt ./
ln -sv ../DATA ./ # This does not work if DATA is full of links, ARIANE container crashes following link of link because this is not a *container* system path.
#mkdir ./DATA
#cd DATA
#ln -sv ../../DATA/mklist_VIKING20.sh ./
#./mklist_VIKING20.sh 1962 DJF
#cd ../
ln -sv ../build_larval_behaviour.sh ./
ln -sv ../split_file.txt ./

#------------------------------------------
# 3) Set larval params for this run
#------------------------------------------
# ARIANE will read this file to define
# the specific larval behavior for
# this particular run.  This script
# grabs the total number of particles to
# run from initial_positions.txt - the
# unchanging launch locations of the larvae.
./build_larval_behaviour.sh $1 $2 $3 $4 $5

#------------------------------------------
# 4) Run ARIANE
#------------------------------------------
/usr/bin/ariane

# Post run clean up
rm -f fort.*
rm -f ariane_memory.log 
rm -f mod_criter*
