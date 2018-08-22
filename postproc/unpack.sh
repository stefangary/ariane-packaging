#!/bin/tcsh -f
#====================
# Unpack data from tarball
#====================

# Get critical information about file
set bn = `basename $1 .tar.gz`
set year_season = `awk -F_ '{print $2_$3}'`

# Unpack
tar -xvzf $1

# Make directory to put it in
mkdir $year_season

# Move stuff into the directory
mv larval_run_* $year_season

# Done
