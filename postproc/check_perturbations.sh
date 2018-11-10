#!/bin/tcsh -f
#=======================
# Check that the larval
# perturbations executed
# on a single node are
# indeed different.
#
# Stefan Gary, 2018
# Distributed under the terms
# of the GNU GPL 3.0 or laterx
#=======================

set indir = $1
set startdir = `pwd`
cd $indir

# Compute the md5sum of the main output file
# for each perturbation
foreach dir ( larval_run_* )
    #echo Working on $dir ...
    cd $dir
    md5sum t.cdf >> ../t.cdf.md5sum
    cd ../
end

# Count the number of duplicate lines
set num_dup = `sort t.cdf.md5sum | uniq -d | wc -l`
set num_files = `wc -l t.cdf.md5sum`
echo In $indir there are $num_dup duplicates among $num_files t.cdf files.

cd $startdir
