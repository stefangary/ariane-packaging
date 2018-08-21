#!/bin/bash -norc
#================================
# This script will apply the post
# processing suite.  It is nice
# to have a separate script to
# be able to test the postprocessing
# locally before remote deployment.
#================================

#=====================================
# Postprocessing step 1: convert
#=====================================
# Convert to tcdf, output file is t.cdf
# t.cdf is 33MB, this step takes ~1 minute
#
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

# Clean up - remove original output file
# which is very large.
rm -f ariane_trajectories_qualitative.nc

#=========================================
# Postprocessing step 2 - split
#=========================================
# Spilt trajectories by Case Study
# This step takes about 9 seconds for 46k
# trajectories.  Output in split_100XX.nc
# from [1,12] for the 12 Case Studies.
# The split trajectories take another 33MB combined.
/usr/bin/tcdfsplit -F split_file.txt -I t.cdf -J

#=========================================
# Postprocessing step 3 - spatial histogram
#=========================================
# This step is the best visualization tool
# to check if the overall results are reasonable.
# Also, it will form the basis for
# determining the spreading rates of the
# particle tracks.
#
# Will need to change the domain of the histogram (-X and -Y flags)
# and the number of particles (-P flag) to better
# match the larger-scale, full simulation
# Default output is hist.nc
# A histogram of all the particles run together
#/usr/bin/tcdfhist -X -80.0 50.0 0.25 -Y 30.0 85.0 0.25 -I t.cdf

# A time-sliced histogram for each Case Study
# All case studies and time steps take about
# 35 seconds at 0.25 degree
# resolution.  Each results in a 32MB file, but
# since the files are sparse, they each compress
# to a few hundred K.  Run time includes compression.
# At 0.1 degree resolution, it takes total of 111 seconds
# and each file is 200MB, but compressed to ~1MB.
# Choose 0.25 degree resolution because that is sufficient
# for studying large-scale (case-study to case-study)
# pathways.
split_list=`ls -1 split_100??.nc`
for split in $split_list
do
    /usr/bin/tcdfhist -X -80.0 50.0 0.25 -Y 30.0 85.0 0.25 -L 0.0 73.0 1.0 -I $split -q
    mv hist.nc $split.hist
    gzip -1v $split.hist
done

#=========================================
# Postprocessing step 4 - contours
#=========================================
# Not done during parallelization because
# the contouring must be done with
# superimposed histograms, and not with
# individual histograms.

#=========================================
# Postprocessing step 5 - survival
#=========================================
# Default output will be alive.nc
# NOT IMPLEMENTED YET AND NOT EXPENSIVE,
# SO NOT INCLUDED IN PARALLELIZATION.
