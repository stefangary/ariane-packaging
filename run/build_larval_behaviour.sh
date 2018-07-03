#!/bin/bash --norc
#===============================
# Build the larval_behaviour.txt
# file for input to ARIANE to
# specify the types of larval
# behaviors.  There are 5 params
# for describing the behaviors,
# so there are five inputs to
# this shell script:
# $1 matureage    - age at which larvae reach their maxspeedup ($3, below)
# $2 descendage   - age (from release) at which larvae begin to descend,
#                    regardless of whether they reach the target depth.
# $3 maxspeedup   - maximum upward swimming speed that larvae linearly ramp up to
# $4 maxspeeddown - maximum donwward swimming speed that larvae linearly ramp up to
# $5 targetdepth  - depth at which larvae stop swimming up
#
# Typical value format:
# 0.0 3628800.0 0.00020 0.00020 2
#
# 0 days [s], 42 days [s], 0.2mm/s [m/s], 0.2mm/s [m/s], k=2 target depth 
#
# This file is independent of
# initial_positions.txt, but
# it must have the same number
# of lines since each line
# describes a particle.  So,
# the first step is to get the
# number of lines in
# initial_positions.txt.  In
# this simple version, all
# larvae will have the same
# behaviors, so all lines will
# be identical.  However, one
# could specify different
# behaviors for each particle.
#================================
# NOTE: Specifying different
# behaviors for different
# particles could allow us to
# change the way the parallelization
# is structured by running many
# cases of the same particles.
# However, this has a disadvantage
# if we decide to add more behavior
# cases later.
#================================

matureage=$1
descendage=$2
maxspeedup=$3
maxspeeddown=$4
targetdepth=$5

# Figure out the number of particles
# implicitly by simply spitting out
# a line to larval_behaviour.txt
# for each line in initial_positions.txt,
# thus building the file.
# There's a faster way to do
# this by storing the number of particles
# and avoiding reading initial_positions.txt
# but since this isn't done often,
# not a problem and it transparently
# uses initial_positions.txt as a basis.
awk -v ma=$matureage -v da=$descendage -v msu=$maxspeedup -v msd=$maxspeeddown -v td=$targetdepth '{print ma,da,msu,msd,td}' initial_positions.txt >> larval_behaviour.txt
