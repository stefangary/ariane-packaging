#!/bin/tcsh -f
#======================
# Front end script to
# superpose histograms
# created by tcdf.
#
# This script is different
# from fe_superpose_histograms
# because it will take existing
# histograms in a series of
# directories and superpose
# all hist in a given directory
# into a single histogram.  The
# goal here is to create
# "ring around the basin" hists.
#
# Stefan Gary, 2019
# Distributed under the terms
# of the GNU GPL 3.0 or later
#======================

#================================================================
# Set which data to run over
#================================================================
# These lists will be used to build up
# the directory names where the merging
# will happen.

set t1_list_rampup='0.0 864000.0'
set t2_list_surfag='345600.0 3628800.0'
set s1_list_swimup='0.00020 0.00100'
set s2_list_swimdn='0.00020 0.00100'
set d1_list_target='3 13'

# This is a list of the case studies to merge together
set cases_to_use = '10001 10002 10003 10004 10005 10006 10007 10008 10009 10010 10011 10012'

# This is the indicator for the case result
set out_case_num = '20001'

#================================================================
# Make output directories - not done here because dirs exist.
# This was a step in fe_superpose_histograms, the first level
# of processing.
#================================================================

#================================================================
# Process
#================================================================
# For each run, aggregate histograms
# Change into each run dir
# Loop over larval parameters
foreach t1 ( $t1_list_rampup )
    foreach t2 ( $t2_list_surfag )
	foreach s1 ( $s1_list_swimup )
	    foreach s2 ( $s2_list_swimdn )
		foreach d1 ( $d1_list_target )
		    cd larval_run_${t1}_${t2}_${s1}_${s2}_${d1}

		    # start counter
		    @ iteration_count = 1

		    # Loop over each case study
		    foreach case ( $cases_to_use )

			if ( $iteration_count == 1 ) then
			    # No existinig file, so just copy.
			    /usr/local/bin/tcdf_merge_hist -O out.tmp.nc -K -F split_${case}.nc.hist
			else
			    # Rename input data
			    mv -f out.tmp.nc add.nc.hist

			    /usr/local/bin/tcdf_merge_hist -O out.tmp.nc -K -F split_${case}.nc.hist add.nc.hist

			    # Clean up
			    rm -f add.nc.hist
			endif

			@ iteration_count = $iteration_count + 1

		    end # Done with case

		    # Update storage
		    mv -f out.tmp.nc split_${out_case_num}.nc.hist

		    # Done with all case studies in this directory,
		    # so move back up.
		    cd ..
		end   # done d1
	    end   # done s2
	end   # done s1
    end   # done t2
end   # done t1
