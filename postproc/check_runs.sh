#!/bin/tcsh -f
#=======================
# Check that the larval
# perturbations executed
# on many nodes are
# indeed different.
#
# Stefan Gary, 2018
# Distributed under the terms
# of the GNU GPL 3.0 or later
#=======================
# First, run
# check_perturbations.sh
# on each directory we
# will check here.  This
# script will cat all
# the t.cdf.md5sum files
# created by
# check_perturbations.sh
# and look for any
# duplicates.
#=======================

# Initialize a file
touch t.cdf.md5sum.all

# Concatenate all the t.cdf.md5sum files
foreach dir ( 19*_* )
    #echo Working on $dir ...
    cd $dir
    cat t.cdf.md5sum >> ../t.cdf.md5sum.all
    cd ../
end

# Count the number of duplicate lines
set num_dup = `sort t.cdf.md5sum.all | uniq -d | wc -l`
set num_files = `wc -l t.cdf.md5sum.all`
echo There are $num_dup duplicates among $num_files t.cdf files.

