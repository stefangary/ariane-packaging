#!/bin/bash
#======================
# This script will:
# 1) Copy input data to node
# 2) run the simulation and postprocessing on just this node
#    ---> Note, the "simulation" on this node will be
#    ---> 32 concurrent instances of ARIANE!
# 3) copy the output data to
#    gs://viking20
#=======================

hostname
whoami
date
pwd

#----------INPUT DATA------------
# Set timer to zero
SECONDS=0

cd /home/stefanfgary/larval-parameter-sweep
echo "Copying data for year $1 season $2..."
./copy_data_to_node.sh $1 $2

# Stop the timer and print
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

#----------SIMULATION------------
# Set timer to zero
SECONDS=0

cd run
echo "Running ARIANE for year $1 season $2..."
./fe_run_ariane_in_parallel.sh

#echo "Running ARIANE and postprocessing for year $1 season $2..."
#./fe_run_ariane_and_pp_in_parallel.sh

# Stop the timer and print
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

#----------SAVE RESULTS------------
# Set timer to zero
SECONDS=0

echo "Saving results for year $1 season $2..."
sudo tar -czf output_$1_$2.tar.gz ./larval_run_*
gsutil cp output_$1_$2.tar.gz gs://viking20/

# Stop the timer and print
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

hostname
date