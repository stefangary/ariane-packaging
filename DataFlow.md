# Data flow: Background

A diagram of the data flow is in
./doc/ARIANE larval simulation parallelization schematic.pdf
which is a Google Draw document whose
evolving read-only link is:
https://docs.google.com/drawings/d/1hA5vn5SuMYzSjKdvnoqieq_R-_mnY0OxzVkB6nlIRNQ/edit?usp=sharing

The goal for this simulation is to
use ARIANE to compute many millions
of particle tracks with the VIKING20
ocean model as the source of the
velocity field driving the particles.
Here we just use the output from
VIKING20 (3D volumes of U and V
velocity data) and do not need to re-run
that ocean model.  The vertical
velocity component, W, is reconstructed
during the simulation to a very good
approximation from U and V by assuming
incompressible flow.

The VIKING20 output spans 52 years:
1958 to 2009.  Output is at a 5-day
time step, so there are
52 years X 73 steps/year = 3796 steps
in the input data.  Since U and V are
stored in separate files, there are
2 x 3796 = 7592 possible input files.

We want to simulate only *year-long*
particle tracks initialized
in winter (DJF), spring (MAM), summer
(JJA), and fall (SON).  So, each
simulation only needs at a minimun
access to 146 files (73 time steps)
to cover a full year and other particle
simulations encompassing different
year-long time spans can be run in parallel.

Since a winter spans two years, our
first winter is the winter of 1959,
which includes the December of 1958.
Winter 1959 is our first launch and
Fall 2008 is our last launch to allow
for year long particle tracks to finish
in the model output for 2009.
Since there are 4 seasons per year
and 50 possible years of simulation,
1959-2008, we have 200 different
times at which launches are made.

All particles are launched from
the same 46,126 positions.  These
launch positions correspond to
potential cold water coral grounds across
the North Atlantic which are
organized into 12 Case Study Regions
as specified in the EU-ATLAS project
proposal and in its Deliverable 1.1:
https://www.overleaf.com/read/bqzyzscrhkdb

So, for one "run", there are:
46,126 lauch pos x 200 launch times = 9.2 million trajectories.

Our goal is to execute 32 of these runs,
all identical except for different larval
swimming parameters as defined by the
larval_behaviours.txt file.  We have identified
5 different parameters (see coral_behavior_scope.pdf)
whose high and low states will be the
basis for a 2^5 = 32 run parameter sweep
to test for the sensitivity of larval-particle
spreading to larval swimming.

The output of ARIANE is particle tracks.
The tcdf package provides a series of
postprocessing tools that can be used to
sort and visualize the particle tracks
by case study and by season/year to
look for inter- and intra-annual
variability in spreading.

In summary:
+ There are some input files that do not change, ever:
    - initial_positions.txt - launch locations, set for EACH particle
    - namelist - basic ARIANE behavior
    - mesh_mask.nc - bathymetry of the ocean
    - V20_full_\<avg|var\>\_TSDQAUV_nopack_v2.nc - mean and variance bottom properties from VIKING20 for optional postprocessing.

+ There is one main parameter file that does change with each run, larval_behaviour.txt, which specifies larval swimming for EACH particle.

+ There is a large input data set (7592 files) that does not change but individual runs in ARIANE will only access subsets (146 files) at a time.

# Step 1: Preparing the node for a parallel run

Software and data need to be put on the node with two scripts:

+ **setup_node.sh** will install necessary software.  After development is done, this script will only need to be run once, an image will be taken of the VM disk, and then can be used later.

+ **copy_data_to_node.sh** will copy input files to the node. This stage of setup includes ~82GB for the VIKING20 velocity fields as well as ~5GB for the **mesh_mask.nc** grid information and ~300 MB for bottom properties information.  These big files are stored in gs://viking20.

There are also smaller files  that set the parameters of
the run - they are pulled from ./run by the ARIANE
container during a run:

+ namelist
+ initial_positions.txt
+ larval_behaviour.txt

NOTE: larval_behaviour.txt is created locally
at run time by **build_larval_behaviour.sh**
during step 3, below.

# Step 2: Run the simulation and postprocessing

Then ARIANE and postprocessing routines need to be run
using the scripts and small specification file in
the ./run directory.

+ Run scripts:
    - run_ariane_and_postprocess.sh <---Original testing with Docker
    - set_and_run_ariane_and_pp.sh <----**BEST** because used for concurrent Docker runs
    
+ Files used for visualization
    - split_file.txt
    - V20_full_\<avg|var\>\_TSDQAUV_nopack_v2.nc

# Step 4: Copy the output to long-term storage
Not implemented yet.  gs://viking20?

