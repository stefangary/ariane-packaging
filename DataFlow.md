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

+ on GCE, select a node with 32 cores, 416GB RAM, 200GB SSD, preemptible.

+ **setup_node.sh** will install necessary software.  After development is done, this script will only need to be run once, an image will be taken of the VM disk, and then can be used later. Automating docker login doesn't seem to work, so at the command line, you need to type:
    - sudo docker login
    - sudo docker pull stefanfgary/ariane

+ Information about taking and restarting an image of this machine will go here.

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
    - split_file.txt <--- Used for splitting into case studies.
    - V20_full_\<avg|var\>\_TSDQAUV_nopack_v2.nc <--- **NOT USED** because survival filter will not be included in parallelization.

# Step 3: Run monitoring

There are two main stages in the run:
+ data copy (~16 minutes)
    - Use fe_copy_and_watch.sh to monitor copying the data.
    - This watching script is a wrapper around the main data copy script, copy_data_to_node.sh .
    - This script will create a file for each node that reports the status of the data copy every ~5 seconds or so.  The files are sent to gs://viking20/*.copy.report.
    - One way to continously monitor the copying is: watch -d --interval gsutil cat gs://viking20/*.copy.report .
    - The -d option in watch is handy because it highlights changes.  Detecting a preempted node is easy: any node that is lagging and does not get highlighted is gone.
    - See an example screenshot in doc/data_copy_watching.png .  In this example, 4 out of 8 nodes were preempted (two preempted at 10% and two preempted at ~45%, respectively, copy completion).
    - If there are lots of nodes working at the same time, then one would want to look at only a subset of the files.
    
+ simulation and postprocessing (~35 minutes)
    - Use fe_watch_runs.sh to monitor the simulations.
    - This watching script is called after all the simulations are started and queries the simulations' log files until they are all complete.
    - It works very much like the copy monitoring routine except files are send to gs://viking20/*.run.report .
    - The fe_watch_runs_slow.sh version will show progress bars and list more information but because the files that are created are larger, it impacts disk I/O, which in turn slows the simulation which is heavily dependent on I/O, too.
    - See an example screenshot in doc/run_watching.png .
    - In this example, four nodes are running at the same time.  The numbers between the | symbols are the current time step of the 32 concurrent runs on a single node (out of a maximum of 73).  The node name is to the left.  I am not computing percentages to avoid extra overhead with calling awk or bc on the node.  The number to the far right is the total number of time steps achieved so far, over all the runs (out of a maxium of 32*73 = 2336).  Highlighted numbers are runs that have been updated within the last 10 seconds due to the --interval 10 option included with the watch command.

# Step 4: Copy the output to long-term storage.

+ Tar all the output directories for the year-season combo run on each node and move it to gs://viking20/output_<year>_<season>.tar.gz

