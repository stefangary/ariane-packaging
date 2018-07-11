#!/bin/bash -norc
#==========================
# This software is distributed
# under the terms of GNU GPL v3
# and any future versions.
# Copyright, Stefan Gary 2018
#==========================
# Copy input data to a node for parallel
# ARIANE runs.
#
# Given the year ($1) and the season ($2),
# This shell will copy the appropriate
# netcdf files to the node with file
# names that will conform
# to the ARIANE naming convention.
#
#===============================================
#
#---------------------------------------------
# 0) Download key environment files from GitHub
#---------------------------------------------
# (You need to do this first so you can access
#  THIS script!!)
#git clone https://github.com/stefangary/larval-parameter-sweep.git
#
#---------------------------------------------
# 1) Set input and output locations/file naming
#---------------------------------------------
# Here, set the prefix of each link that will be
# read by ARIANE.  This prefix must match the
# c_prefix_?? items on the namelist. Unlikely
# to change, ever.
prefix='VIKING20_'

# List the grids to use (variables are on
# different grids which are in different files).
# For our purposes here, we only need the two
# vector components of the velocity field, U and
# V.  Temperature and salinity are not needed.
#set grids2use = 'U V T'  Unlikely to change, ever.
grids2use='U V'

# Here we want to create links to files based on
# the year to use and the season, specified on
# the command line.
year=$1
season=$2

# Specify the name of the directory in which all
# the files are stored and the domain used.
#datdir='/home/sfg/Desktop/active_projects/ParallelWorks/small_domain_for_tests/tsplit_1_VIKING20-K301_5d_'
datdir='gs://viking20/tsplit_1_VIKING20-K301_5d_'
domain='full'

# Specify the name of the directory to send
# the data to (e.g. /app/run/DATA).
targetdir='./run/DATA'
#----------------------------------------------

#----------------------------------------------
# 2) Make links or copy files
#----------------------------------------------

# Copy over the ~5GB grid file (absolutely necessary)
gsutil cp gs://viking20/mesh_mask.nc ./run/mesh_mask.nc

# Copy over ~300MB bottom properties files
# (only necessary for final stage of postprocessing)
gsutil cp gs://viking20/V20_full_avg_TSDQAUV_nopack_v2.nc ./run/bottom_avg.nc
gsutil cp gs://viking20/V20_full_var_TSDQAUV_nopack_v2.nc ./run/bottom_var.nc

# For each grid type (U and V absolutely required)
for grid in $grids2use
do

    # For each file,
    filenum=10001  # Initialize a file counter

    case $season in
	#===============WINTER====================
	DJF) for tsplit_num in {168..173} # Start links in December of previous year
	     do
		 let yy=$year-1
		 gsutil cp ${datdir}${yy}0101_${yy}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.nc
		 let filenum++
	     done
	     for tsplit_num in {101..167} # Follow through for the rest of the year
	     do
		 gsutil cp ${datdir}${year}0101_${year}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.nc
		 let filenum++
	     done
	     ;;
	#===============SPRING====================
	MAM) for tsplit_num in {113..173} # Start links in March of this year, continue to end of year
	     do
		 gsutil cp ${datdir}${year}0101_${year}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.nc
		 let filenum++
	     done
	     for tsplit_num in {101..112} # Follow through for rest of year with next year's data
	     do
		 let yy=$year+1
		 gsutil cp ${datdir}${yy}0101_${yy}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.nc
		 let filenum++
	     done
	     ;;
	#===============SUMMER====================
	JJA) for tsplit_num in {131..173} # Start links in June of this year, continue to end of year
	     do
		 gsutil cp ${datdir}${year}0101_${year}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.nc
		 let filenum++
	     done
	     for tsplit_num in {101..130} # Follow through for rest of year with next year's data
	     do
		 let yy=$year+1
		 gsutil cp ${datdir}${yy}0101_${yy}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.nc
		 let filenum++
	     done
	     ;;
	#===============FALL====================
	SON) for tsplit_num in {167..173} # Start links in Sept. of this year, continue to end of year
	     do
		 gsutil cp ${datdir}${year}0101_${year}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.nc
		 let filenum++
	     done
	     for tsplit_num in {101..166} # Follow through for rest of year with next year's data
	     do
		 let yy=$year+1
		 gsutil cp ${datdir}${yy}0101_${yy}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.nc
		 let filenum++
	     done
	     ;;    
    esac   # Done with seasonal case switch
done   # Done with looping over grid types
