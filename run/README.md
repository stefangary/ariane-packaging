# More detail about run scripts here

# Step 1: setting the larval behaviors

+ **build_larval_behavior.sh** will create larval_behaviour.txt given initial_positions.txt and 5 command line specified larval behavior parameters.  All the larval behaviors are the same and it's a 1-to-1 mapping of larval behavior to initial positions.

+ **build_single_run_all_param_input.sh** will create larval_behavior.txt with ALL 32 perturbations of the behaviors given initial_positions.txt.  After this script is run, one needs to rename initial_positions.all.txt to initial_positions.txt in order to run ARIANE with this input file.  I required this manual renaming processing to avoid overwriting the original initial_positins.txt file in case I do a git commit and forget I'm using 32x46k particles instead of just the 46k particles.  Eventually, I want this script to also generate a lookup table assigning a "perturbation ID" to each specific combination of larval behaviors so that output files can be labeled [01,02,...,32] and then we can know what the behaviors are for that file.  This will make regrouping and merging files easier during postprocessing.

# Step 2: front end scripts running the simulation

+ **test_concurrent_runs.sh** was a first draft at running the ARIANE container within a series of loops over larval behaviours as well as time.  It is not yet parallelized and is *probably no longer useful*, but retained for reference.

+ **fe_run_ariane_in_parallel.sh** and **fe_run_ariane_and_pp_in_parallel.sh** allows for testing multiple concurrent runs of ARIANE on the same machine to see how simultaneous containers exploit the kernal cache.

+ **test_kernal_cache_single_run.sh** runs only one instance of ARIANE, in the same context as run_ariane_in_parallel.sh, which is useful if we want to do a simulation with all larval behavior perturbations instead of simultaneous runs for each larval behavior perturbation.

# Step 3: run scripts used by the front end scripts

+ **run_ariane_and_postprocess.sh** is a first draft at running ARIANE in a container and is used by test_concurrent_runs.sh.  It is *probably no longer immediately useful* but may serve as a simple template.

+ **set_and_run_ariane.sh** and **set_and_run_ariane_and_pp.sh** is used by fe_run_ariane_in_parallel.sh and fe_run_ariane_and_pp_in_parallel.sh and sets the run environment, runs, and, for the _and_pp_ variants only, postprocesses.

+ **set_and_run_ariane_and_pp_single_run.sh** is used by test_kernal_cache_single_run.sh and is very similar to set_and_run_ariane_and_pp.sh but modified for a single run on a node.

# Step 4: postprocessing

+ Some of the postprocessing is already included in the above.  The whole postprocessing chain can also be executed by **post_process_ARIANE_run.sh**.
