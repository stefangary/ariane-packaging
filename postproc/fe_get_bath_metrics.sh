#!/bin/tcsh -f
#========================
# Front end controlling
# survivability index
# operations.
#
# This is a direct copy of
# fe_get_surv_metrics.sh
# except that we want to
# calculate the percent of
# positions within the isobath
# range, not just particles along
# the bottom and within the
# isobath range.
#
# Stefan Gary, 2019
#
# This software is distributed
# under the GNU GPL v3 or later.
#========================

source /usr/local/ferret/ferret_paths.csh

set seasons_to_use = 'DJF MAM JJA SON ALL'
#set seasons_to_use = 'ALL'

foreach season ( $seasons_to_use )
    cd all_${season}

    # Work on all directories for this season
    foreach dir ( larval_run_* )

	echo Working on $dir

	cd $dir

	# Runscript
	ln -sv /mnt/md0/sa03sg/work/PW_results/larval-parameter-sweep/postproc/get_bath_metrics.sh ./

	# Gridded bottom topography from tcdf_get_bot
	ln -sv ../../bott.nc ./
	
	foreach file ( split_*.nc.hist.gz )
	    # Decompress
	    gunzip -c ${file} > ${file}.nc

	    # Process
	    ./get_bath_metrics.sh ${file}.nc

	    # Clean up
	    rm -f ${file}.nc
	end

	# Clean up
	rm -f get_bath_metrics.sh bott.nc
	cd ..
    end

    cd ..

end
