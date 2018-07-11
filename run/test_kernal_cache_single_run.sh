#!/bin/bash --norc
#=======================================
# Our goal is to try running multiple
# isntances of ARIANE at the same time
# so that each instance pulls the same
# data from the kernal cache, thus
# minimizing the amount of time data is
# both copied to a node as well as data
# is read from disk to RAM.
#
# This wrapper will test a single run
# with all params.
#=======================================

docker run --rm --name=ariane_container -v/md0/sa03sg/work/ariane_container_tests/larval-parameter-sweep-src/run:/app/run -v/md0/sa03sg/scratch/VIKING20_nest_5d/cut_ATLAS/UV:/app/data -w/app/run stefanfgary/ariane ./set_and_run_ariane_and_pp_single_run.sh &> run.log &

