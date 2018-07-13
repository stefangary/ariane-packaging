# larval-parameter-sweep

The goal of this project is to parallelize
a coral larvae simulation in order to test
the sensitivity of larval spreading
to larval swimming behavior.

This README documents the installation,
data flow logic and performance
characteristics of the calculations
resulting from this project.

# Summary of multipliers here, more details below

**We have:**
+ 5 different larval behaviors;
+ each larval behavior has a low and high value -> 2^5 = 32 combinations;
+ 50 years of input data;
+ 4 seasons for each year (DJF, MAM, JJA, SON); and
+ 46,126 particles launched for each season for each year.

**Multiplying it out, we have:**
+ 50 years x 4 seasons/year = 200 times at which particles are launched; and
+ 32 combos of larval swimming x 200 launch times = 6400 instances.

**Our strategy is to:**
+ Run all 32 simulations associated with each launch time concurrently on the same node since it takes a long time to copy data to a node and read that data to RAM.
+ 200 nodes will each run 32 simulations.  Although there is some overlap in the input data from node to node, when we start copying data to all 200 nodes, they will each start copying different files.
+ Current estimates are ~16 minutes data copy + ~32 minutes simulation run for each node.

**For postprocessing we have (optional):**
+ 12 case study sites
+ 4 postprocessing steps which will take about 2 minutes for each of the 6400 instances (8 days serial running...)
+ postprocessing results can be superposed so they lend themselves well to parallelization, just as the simulation.
+ the last step of postprocessing is still under development, so only estimates here.

# Overview

The core simulation is executed by the
ARIANE software distributed under a
CeCILL license.  ARIANE is single
threaded and written in FORTRAN 90
by Bruno Blanke and Nicholas Grima
at the University of Brest, France.
ARIANE inputs a velocity field (e.g.
the output of an ocean model) and
computes the trajectories of particles
as they move along streamlines in
the flow.

Alan Fox and I have designed a modified
version of ARIANE that superposes active
vertical swimming, associated with coral
larvae when they are released by their
parents, onto the purely advective movement
of particles computed by ARIANE.  Since
the actual behavior of coral larvae is
poorly understood, we want to test a
range of different swimming behaviors
to see if they have a significant impact
on the spreading of larvae compared to
pure advection of particles by the currents.

A more in-depth summary of the science
and types of swimming behavior are in
./doc/coral_behavior_scope.pdf.

I have subdivided the documentation into
separate files:

+ Installation.md, includes information on:
    - installing ARIANE
    - building an ARIANE container

+ DataFlow.md, includes information on:
    - a list of the input and output files
    - see ./doc/ARIANE larval simulation parallelization schematic.pdf
    - running the ARIANE container
    - visualization of ARIANE output
    
+ Performance.md, includes information on:
    - single runs
    - parallel runs
    - CPU, RAM, disk space, and data transfer needs

