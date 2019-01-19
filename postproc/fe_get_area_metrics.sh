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

foreach dir ( larval_run_* )

    echo Working on $dir

    cd $dir

    ln -sv ../get_area_metrics_ring.sh ./

    foreach file ( split_2*.nc.hist )
	get_area_metrics_ring.sh $file
    end

    # Clean up
    rm -f get_area_metrics_ring.sh
    cd ..

end
