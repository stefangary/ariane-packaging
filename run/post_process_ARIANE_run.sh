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
#rm -f ariane_trajectories_qualitative.nc

#=========================================
# Postprocessing step 2 - split
#=========================================
# Spilt trajectories by Case Study
/usr/bin/tcdfsplit -F split_file.txt -I t.cdf -J

#=========================================
# Postprocessing step 3 - spatial histogram
#=========================================
# This step is the best visualization tool
# to check if the overall results are reasonable.
#
# Will need to change the domain of the histogram (-X and -Y flags)
# and the number of particles (-P flag) to better
# match the larger-scale, full simulation
# WISH LIST: auto determine number of particles and domain size.
# Default output is hist.nc
# A histogram of all the particles run together
/usr/bin/tcdfhist -X -80.0 50.0 0.25 -Y 30.0 85.0 0.25 -I t.cdf

# A time-sliced histogram for each Case Study


#=========================================
# Postprocessing step 4 - survival
#=========================================
# Default output will be alive.nc
# NOT IMPLEMENTED YET
#tcdfalive
