#!/bin/bash --norc
#===============================================
# Given the year ($1) and the season ($2),
# This shell will create a list of links to
# netcdf formatted snapshots of model output.
# The list of links will conform
# to the ARIANE naming convention.
#
# Instead of making links, one could readily
# include copy commands (e.g. from a bucket)
# or gunzip -c commpressed > uncompressed
# commands if decompressing on the fly.
#
# NCL - short for netcdf (nc) link.
# Obviously in hindsight, when running in Docker,
# the Docker container can't necessarily follow
# links whose paths are set up to work with the
# HOST system.
# So, here, I mount the VIKING20_bucket (a place
# holder for a GCP bucket) to /app/run/DATA
# and create the links that ARIANE will use
# within the bucket using relative path names.
# I create the .ncl file ending to make certain
# there are no accidental .nc file deletions.
# This artiface is likely unnessarily when in
# the GCP environment since we're likely
# copying VIKING20 files directly to /app/run.
# And why go to all this trouble of links if
# I could just copy data from VIKING20_bucket
# to /app/run/DATA on Lab01?  I don't want to
# uncessarily thrash the disk and hold up other
# users.
#===============================================
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
# WILL NEED TO MOIFY FOR FULL DOMAIN/GCP ENV.
#datdir='/home/sfg/Desktop/active_projects/ParallelWorks/small_domain_for_tests/tsplit_1_VIKING20-K301_5d_'
datdir='./tsplit_1_VIKING20-K301_5d_'
domain='rockall_bank'

# BUT, we want to make relative path links within
# a specific directory, so go to that directory,
# create the links, and then go back to whereever
# we were when we started.
pwd_start=`pwd`
cd /home/sfg/VIKING20_bucket

# Specify the name of the directory to send
# the data to or link to (e.g. /app/run/DATA).
targetdir='./'
#----------------------------------------------

#----------------------------------------------
# 2) Make links or copy files
#----------------------------------------------
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
		 #echo $yy
		 ln -s ${datdir}${yy}0101_${yy}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.ncl
		 let filenum++
	     done
	     for tsplit_num in {101..167} # Follow through for the rest of the year
	     do
		 ln -s ${datdir}${year}0101_${year}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.ncl
		 let filenum++
	     done
	     ;;
	#===============SPRING====================
	MAM) for tsplit_num in {113..173} # Start links in March of this year, continue to end of year
	     do
		 ln -s ${datdir}${year}0101_${year}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.ncl
		 let filenum++
	     done
	     for tsplit_num in {101..112} # Follow through for rest of year with next year's data
	     do
		 let yy=$year+1
		 ln -s ${datdir}${yy}0101_${yy}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.ncl
		 let filenum++
	     done
	     ;;
	#===============SUMMER====================
	JJA) for tsplit_num in {131..173} # Start links in June of this year, continue to end of year
	     do
		 ln -s ${datdir}${year}0101_${year}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.ncl
		 let filenum++
	     done
	     for tsplit_num in {101..130} # Follow through for rest of year with next year's data
	     do
		 let yy=$year+1
		 ln -s ${datdir}${yy}0101_${yy}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.ncl
		 let filenum++
	     done
	     ;;
	#===============FALL====================
	SON) for tsplit_num in {167..173} # Start links in Sept. of this year, continue to end of year
	     do
		 ln -s ${datdir}${year}0101_${year}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.ncl
		 let filenum++
	     done
	     for tsplit_num in {101..166} # Follow through for rest of year with next year's data
	     do
		 let yy=$year+1
		 ln -s ${datdir}${yy}0101_${yy}1231_${domain}_${tsplit_num}_grid_${grid}.nc ${targetdir}/${prefix}${filenum}_grid_${grid}.ncl
		 let filenum++
	     done
	     ;;    
    esac   # Done with seasonal case switch
done   # Done with looping over grid types

# Done with links, so go back to where we were.
cd $pwd_start
