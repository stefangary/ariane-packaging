#!/bin/tcsh -f
#========================
# Front end controlling
# lots of area index
# operations.
#
# Stefan Gary, 2018
#
# This software is distributed
# under the GNU GPL v3 or later.
#========================

#set seasons_to_use = 'DJF MAM JJA SON ALL'
set seasons_to_use = 'ALL'

foreach season ( $seasons_to_use )
    cd all_${season}

    # Work on all directories for this season
    foreach dir ( larval_run_* )

	echo Working on $dir

	cd $dir

	ln -sv /mnt/md0/sa03sg/work/PW_results/larval-parameter-sweep/postproc/get_area_metrics.sh ./

	foreach file ( split_*.nc.hist.gz )
	    # Decompress
	    gunzip -c ${file} > ${file}.nc

	    # Process
	    get_area_metrics.sh ${file}.nc

	    # Clean up
	    rm -f ${file}.nc
	end

	# Clean up
	rm -f get_area_metrics.sh
	cd ..
    end

    cd ..

end
