#!/bin/bash --norc
#=======================================

rm -f tmp.xy

cases_list='1 2 3 4 5 6 7 8 9 10 11 12'

declare -a pdx_list=("0.75i" "2.5i" "2.5i" "-5.0i" "2.5i" "2.5i" "-5.0i" "2.5i" "2.5i" "-5.0i" "2.5i" "2.5i")
declare -a pdy_list=("9i" "0i" "0i" "-2.75i" "0i" "0i" "-2.75i" "0i" "0i" "-2.75i" "0i" "0i")
declare -a wesn_list=("Wesn" "wesn" "wesn" "Wesn" "wesn" "wesn" "Wesn" "wesn" "wesn" "WeSn" "weSn" "weSn")
rflag_list='b'
bflag_list='a'

for case in $cases_list
do

    let case_index=$case-1
    let case_num=10000+$case

#=======================================
# Set up plot
#=======================================
    if [ "$case" = "1" ]; then
	gmt psbasemap -JX2i/2i -R0/3e12/0/100 -Ba1e12f1e11:"Area Growth [m@+2@+]":/a10f5:"Along-bathy. retention [%]"::.${case}:${wesn_list[$case_index]} -P -K -X${pdx_list[$case_index]} -Y${pdy_list[$case_index]} > out.ps
    else
	gmt psbasemap -JX2i/2i -R0/3e12/0/100 -Ba1e12f1e11:"Area Growth [m@+2@+]":/a10f5:"Along-bathy. retention [%]"::.${case}:${wesn_list[$case_index]} -P -O -K -X${pdx_list[$case_index]} -Y${pdy_list[$case_index]} >> out.ps
    fi

echo ${pdx_list[$case_index]}
echo ${pdy_list[$case_index]}
echo ${wesn_list[$case_index]}

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
			w_flag=-Wthick,gray
		    else
			w_flag=-Wthick,light${symbol_color}
		    fi
		else
		    w_flag=-Wthick,${symbol_color}
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

		    # build filename to access
		    include_this_file=larval_run_${t1}_${t2}_${s1}_${s2}_${d1}/split_${case_num}.nc.hist.gz.nc.ml.out.txt
		    include_this_file2=larval_run_${t1}_${t2}_${s1}_${s2}_${d1}/split_${case_num}.nc.hist.gz.nc.sv.out.txt

		    paste $include_this_file $include_this_file2 | awk '{print $6,$11}' | gmt psxy -J -R -B $s_flag $w_flag -P -O -K >> out.ps

		    paste $include_this_file $include_this_file2 | awk '{print $6,$11}' >> tmp.xy

		done # with d1 loop
	    done # with s2 loop
	done # with s1 loop
    done # with t2 loop
done # with t1 loop
#----------Done with all larval params loops--------------------

upper=`gmt gmtmath -Ca tmp.xy UPPER -Sl =`

# Compute line of best fit
gmt gmtmath -N3/1 -Atmp.xy -C0 1 ADD LSQFIT = fit.si
slope=`tail -1 fit.si`
inter=`head -1 fit.si`
echo 0.0 $inter > line.xy
set -- $upper
xmax=`gmt gmtmath -Q ${1} CEIL =`
ymax=`gmt gmtmath -Q $xmax $slope MUL $inter ADD =`
echo $xmax $ymax >> line.xy
gmt psxy line.xy -J -R -B -Wthin,green -P -O -K >> out.ps

rm -f line.xy
#rm -f tmp.xy

echo $case has slope $slope and intercept $inter
rm -f fit.si

done
#-----------Done with all case studies---------------------------
ps2pdf out.ps
rm -f out.ps
