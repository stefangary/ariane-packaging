#!/bin/bash --norc
#=======================================

#=======================================
# Set up plot
#=======================================
if [ -f tmp.xy ]; then
    # Spit out domain found
    upper=`gmt gmtmath -Ca tmp.xy UPPER -Sl =`
    lower=`gmt gmtmath -Ca tmp.xy LOWER -Sl =`
    set -- $upper
    echo ${1}
    echo ${2}
    xmax=`gmt gmtmath -Q ${1} CEIL =`
    ymax=`gmt gmtmath -Q ${2} CEIL =`
    set -- $lower
    xmin=`gmt gmtmath -Q ${1} FLOOR =`
    ymin=`gmt gmtmath -Q ${2} FLOOR =`

    # Manual figure tuning
    # Based on experience, ymax should be < ???
    ymax=100
    
#    gmt psbasemap -JX6i/6i -R${xmin}/${xmax}/${ymin}/${ymax} -B:"Relative Area Growth":/:"Relative Area Growth Curvature":WeSn -P -K -X1i -Y1i >> out.ps
    #    gmt psbasemap -JX6i/6i -R${xmin}/${xmax}/${ymin}/${ymax} -B:"Relative Area Growth":/:"Relative Area Growth Curvature":WeSn -P -K -X1i -Y1i >> out.ps
    gmt psbasemap -JX6i/4i -R${xmin}/${xmax}/${ymin}/${ymax} -Ba1e12f1e11:"Area Growth [m@+2@+]":/a10f5:"Along-bathymetry retention":WeSn -P -K -X1i -Y1i >> out.ps
else
    # Use default domain
#    gmt psbasemap -JX6i/6i -R0/400/0/2.5 -Ba100f50:"Relative Area Growth":/a0.5f0.1:"Relative Area Growth Curvature":WeSn -P -K -X1i -Y1i >> out.ps
    gmt psbasemap -JX6i/6i -R0/3e12/10/100 -Ba1e12f1e11:"Area Growth [m@+2@+]":/a10f5:"Along-bathymetry retention":WeSn -P -K -X1i -Y1i >> out.ps

fi
#=======================================
# Loop over larval behavior
#=======================================

# To double check units,
# t1 = [0days to 10days] -> passed in [s]
# t2 = [4days to 42days] -> passed in [s]
# s1 = [0.2mm/s to 1mm/s] -> passed in [m/s]
# s2 = [0.2mm/s to 1mm/s] -> passed in [m/s]
# d1 = [12m to 150m] -> passed in k-index
#                      use VIKING20 vertical grid spacing,
#                      gdepw_0 in mesh_mask.nc to check!
#------------------------------------------
t1_list_rampup='0.0 864000.0'
t2_list_surfag='345600.0 3628800.0'
s1_list_swimup='0.00020 0.00100'
s2_list_swimdn='0.00020 0.00100'
d1_list_target='3 13'
#cases_list='10001 10002 10003 10004 10005 10006 10007 10008 10009 10010 10011 10012'
#cases_list='10012'
cases_list='20001'

# Loop over larval parameters
for t1 in $t1_list_rampup
do
    #symbol change (plus/circle)
    #zero is solid and dotted lines
    #10d is dot-dash and dashed lines
    if [ "$t1" = "0.0" ]; then
	symbol_type=-Ss
    else
	symbol_type=-Sc
    fi

    for t2 in $t2_list_surfag
    do
	#color change
	#warm (red/purple) for early down
	#cool (black/blue) for late down
	if [ "$t2" = "345600.0" ]; then
	    color_opts='red magenta'
	else
	    color_opts='black blue'
	fi

	for s1 in $s1_list_swimup
	do
	    #color change
	    #purple/blue for slow up
	    #red/black for fast up
	    set -- $color_opts
	    if [ "$s1" = "0.00100" ]; then
	        symbol_color=${1}
	    else
		symbol_color=${2}
	    fi

	    for s2 in $s2_list_swimdn
	    do
		#Intensity change
		#light/pale for fast down
		#dark for slow down
		if [ "$s2" = "0.00100" ]; then
		    if [ "$symbol_color" = "black" ]; then
			w_flag=-Wthickest,gray
		    else
			w_flag=-Wthickest,light${symbol_color}
		    fi
		else
		    w_flag=-Wthickest,${symbol_color}
		fi

		for d1 in $d1_list_target
		do
		    #symbol change (size?)
		    #solid/dotted
		    #dash-dot/dash
		    if [ "$d1" = "3" ]; then
			s_flag=${symbol_type}0.1i
		    else
			s_flag=${symbol_type}0.2i
		    fi

		    for case in $cases_list
		    do
			# build filename to access
			include_this_file=larval_run_${t1}_${t2}_${s1}_${s2}_${d1}/split_${case}.nc.hist.gz.nc.ml.out.txt
			include_this_file2=larval_run_${t1}_${t2}_${s1}_${s2}_${d1}/split_${case}.nc.hist.gz.nc.sv.out.txt

			paste $include_this_file $include_this_file2 | awk '{print $6,$11}' | gmt psxy -J -R -B $s_flag $w_flag -P -O -K >> out.ps
			paste $include_this_file $include_this_file2 | awk '{print $6,$11}' >> tmp.xy

		    done # with case loop
		done # with d1 loop
	    done # with s2 loop
	done # with s1 loop
    done # with t2 loop
done # with t1 loop
#----------Done with all larval params loops--------------------

# Spit out domain found
set upper = `gmt gmtmath -Ca tmp.xy UPPER -Sl =`
set lower = `gmt gmtmath -Ca tmp.xy LOWER -Sl =`

# Compute line of best fit
# -N sets 3 columns with time in 1st column
# -A sets up linear solver based on input.
gmt gmtmath -N3/1 -Atmp.xy -C0 1 ADD -Ca LSQFIT = fit.si

# Plot line of best fit
slope=`tail -1 fit.si`
inter=`head -1 fit.si`
echo 0.0 $inter > line.xy
upper=`gmt gmtmath -Ca tmp.xy UPPER -Sl =`
set -- $upper
xmax=`gmt gmtmath -Q ${1} CEIL =`
ymax=`gmt gmtmath -Q $xmax $slope MUL $inter ADD =`
echo $xmax $ymax >> line.xy
gmt psxy line.xy -J -R -B -Wthin,green -P -O -K >> out.ps

ps2pdf out.ps
rm -f out.ps
#rm -f tmp.xy
