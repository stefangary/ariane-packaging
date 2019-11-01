#!/bin/tcsh -f
#======================
# Front end script to
# superpose histograms
# created by tcdf.
#
# fe_seasonal_superposition
# condensed all data by seasonal
# launch times.  This
# reduced the data set by 50x.
# Case studies are still kept
# separate and a single "ring"
# (all case study) superposition
# was also done.
#
# Here we want to flatten
# all the seasons into a single
# data set, again keeping case
# studies separate and a single
# merged ring-around-the-basin.
#
# Stefan Gary, 2019
# Distributed under the terms
# of the GNU GPL 3.0 or later
#======================

#================================================================
# Set which data to run over
#================================================================
set seasons_to_use = 'DJF MAM JJA SON'

set t1_list_rampup='0.0 864000.0'
set t2_list_surfag='345600.0 3628800.0'
set s1_list_swimup='0.00020 0.00100'
set s2_list_swimdn='0.00020 0.00100'
set d1_list_target='3 13'

# Include the ring-around-the-basin 2*
set cases_to_use = '10001 10002 10003 10004 10005 10006 10007 10008 10009 10010 10011 10012 20001'

#================================================================
# Make output directories
#================================================================

# Absolute path
set topdir = `pwd`

# Loop over larval parameters
foreach t1 ( $t1_list_rampup )
    foreach t2 ( $t2_list_surfag )
	foreach s1 ( $s1_list_swimup )
	    foreach s2 ( $s2_list_swimdn )
		foreach d1 ( $d1_list_target )

		    # This is where we're going to work
		    set target = ${topdir}/seasonal_histograms/all_ALL/larval_run_${t1}_${t2}_${s1}_${s2}_${d1}
		    echo Working on $target
		    mkdir -p $target
		    cd $target

		    foreach cs ( $cases_to_use )

			# Grab the corresponding file from
			# each season:
			foreach season ( $seasons_to_use )
			    gunzip -c ${topdir}/seasonal_histograms/all_${season}/larval_run_${t1}_${t2}_${s1}_${s2}_${d1}/split_${cs}.nc.hist.gz > ./${season}.nc
		        end

			# Merge the files
			/usr/local/bin/tcdf_merge_hist -O split_${cs}.nc.hist -K -F DJF.nc MAM.nc JJA.nc SON.nc

			# Clean up
			gzip -1v split_${cs}.nc.hist
			rm -f DJF.nc MAM.nc JJA.nc SON.nc
		    end
		end
	    end
	end
    end
end
