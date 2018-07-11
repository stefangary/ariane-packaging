# larval-parameter-sweep

The goal of this project is to parallelize
a coral larvae simulation in order to test
the sensitivity of larval spreading
to larval swimming behavior.

This README documents the installation,
data flow logic and performance
characteristics of the calculations
resulting from this project.

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

