#!/bin/tcsh -f
#======================
# Front end script to
# superpose histograms
# created by tcdf.
#
# Stefan Gary, 2018
# Distributed under the terms
# of the GNU GPL 3.0 or later
#======================

#================================================================
# Set which data to run over
#================================================================
set years_to_use = '1960'
#set years_to_use = '1959 1960 1961 1962 1963 1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008'

set seasons_to_use = 'DJF MAM JJA SON'

set t1_list_rampup='0.0 864000.0'
set t2_list_surfag='345600.0 3628800.0'
set s1_list_swimup='0.00020 0.00100'
set s2_list_swimdn='0.00020 0.00100'
set d1_list_target='3 13'

set cases_to_use = '10001 10002 10003 10004 10005 10006 10007 10008 10009 10010 10011 10012'

#================================================================
# Make output directories
#================================================================
mkdir superposed_histograms
cd superposed_histograms
# Loop over larval parameters
foreach t1 ( $t1_list_rampup )
    foreach t2 ( $t2_list_surfag )
	foreach s1 ( $s1_list_swimup )
	    foreach s2 ( $s2_list_swimdn )
		foreach d1 ( $d1_list_target )
		    mkdir larval_run_${t1}_${t2}_${s1}_${s2}_${d1}
		end
	    end
	end
    end
end

cd ../
set workdir = `pwd`

#================================================================
# Process
#================================================================

# start counter
@ iteration_count = 1

# Loop over years
foreach year ( $years_to_use )

    # Loop over seasons
    foreach season ( $seasons_to_use )

	# Unpack the data set
	unpack.sh output_${year}_${season}.tar.gz
    
	# Go into the resulting directory
	cd ${year}_${season}

	# For each run, aggregate histograms
	# Change into each run dir
	# Loop over larval parameters
	foreach t1 ( $t1_list_rampup )
	    foreach t2 ( $t2_list_surfag )
		foreach s1 ( $s1_list_swimup )
		    foreach s2 ( $s2_list_swimdn )
			foreach d1 ( $d1_list_target )
			    cd larval_run_${t1}_${t2}_${s1}_${s2}_${d1}

			    # Loop over each case study
			    foreach case ( $cases_to_use )

				# Decompress file
				gunzip split_${case}.nc.hist.gz

				if ( $iteration_count == 1 ) then
				    # No existinig file, so just copy.
				    /usr/local/bin/tcdf_merge_hist -O out.tmp.nc -K -F split_${case}.nc.hist
				else
				    # Link and use input data
				    ln -sv ${workdir}/superposed_histograms/larval_run_${t1}_${t2}_${s1}_${s2}_${d1}/split_${case}.nc.hist add.nc.hist

				    /usr/local/bin/tcdf_merge_hist -O out.tmp.nc -K -F split_${case}.nc.hist add.nc.hist

				    # Clean up
				    rm -f add.nc.hist
				endif

				# Update storage
				mv -f out.tmp.nc ${workdir}/superposed_histograms/larval_run_${t1}_${t2}_${s1}_${s2}_${d1}/split_${case}.nc.hist

				# Clean up
				rm -f split_${case}.nc.hist

			    end   # done case

			    # Done with all case studies in this iteration,
			    # so move back up.
			    cd ..
			end   # done d1
		    end   # done s2
		end   # done s1
	    end   # done t2
	end   # done t1
	
	# Done with all iterations.  Clean up
	cd ..
	rm -rf ${year}_${season}
	@ iteration_count = $iteration_count + 1
	
    end   # done season loop
end   # done year loop

# Done looping over years and seasons
