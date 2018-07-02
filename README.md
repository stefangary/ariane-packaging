# larval-parameter-sweep-src

Scripts necessary for running parallel instances of ARIANE
I chose to keep this separate from the project
larval-parameter-sweep-doc because the docs could get bigger
with fancy images.

# Step 1: Building the container

This is only done once in a blue moon when the code of
ARIANE, netcdf (and dependencies), or tcdf is changed
and changes need to be incorporated into the container.
The script build_ariane_container.sh automates this
process.

# Step 2: Preparing the node for a parallel run

Input files need to be copied to the node.  This includes
~82GB for the VIKING20 velocity fields as well as ~5GB
for the mesh_mask.nc grid information.  These big files
are stored in gs://viking20.  There are also smaller files 
that set the parameters of the run - they are pulled from
ariane_packaging/run.

# Step 3: Run the simulation and postprocessing

Then ARIANE and postprocessing routines need to be run
using the scripts in the ./run directory.

# Step 4: Copy the output to long-term storage

gs://viking20?