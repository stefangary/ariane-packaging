# Performance Characteristics

The biggest challenge in this project is the I/O bottleneck, followed by RAM needs and, finally, CPU needs.

# Copying data to node - first test with 8 CPUs

A first test for copying data to a
node results in 108 files copied over
17 minutes.  I interrupted the transfer
early since I was about to fill the disk.
Conclusions:

 + We need at least 180GB of disk space on a node to hold the input data.
 + I estimate the total "real world" copy time to be ~23 minutes.
 + I transferred ~65 GB in ~18 minutes => (65*8)/(18*60) = 0.5Gbit/s

gsutil says this would go faster if I
included compiled crcmod.  To install that on
the node use instructions at:

https://cloud.google.com/storage/docs/gsutil/addlhelp/CRC32CandInstallingcrcmod

...but I was not able to complete the uninstall step therein.

# Copying data to node - second test with 32 CPUs

Installing Docker and other key software to the node as required
in setup_node.sh is very fast, at about ~3 minutes, including
pulling the container.

I'm curious to see if the data copy time is faster with a VM
with 32 CPUs since GCE seems to tie bandwidth to number of CPUs.
A first attempt results in 88GB copied over in 16:11:81 min = 972 s.
This is equivalent to: 88GB * 8 Gbits/1GB / 972s = 0.72 Gbit/s.
The transfer speed of the second test is a 50% increase over the
first test with a smaller number of CPU.

Note that in these data transfer tests, the hard drive of the
VM was specified to be an SSD.  Specifying a standard rotational
drive adds about 5 minutes to the data transfer process.

# Summary of software/data copy tests:

+ A node can be prepared from scratch in about 3 minutes.
+ Input data can be copied over to a node in about 16 minutes -> specify SSD!

# Running a single instance - 1st attempt on a stand alone workstation

Our goal is to simulate 46,126 particles over one year.
We will add 32 different perturbations to the particle
behavior and 200 different launch times, resulting in
6,400 total instances (32 * 200).

On a stand alone workstation with regular hard drives
in a software RAID0 configuration, a single full-domain
instance takes 28 minutes.  This is about 13 minutes longer
than my initial estimates because I did not account for
the larger domain of the simulation.  If this
is an issue for using preemptive resources, then 6 month
long tracks (scaling the calculation back by 50%) is
possible.

During the time, the simulation read 82GB of input data,
5GB of grid information, and other smaller files.  The
main output file is 33MB with other, optional, output
files on the order of 450KB.  (But another ~200MB is
used on disk during the run with intermediate files.)
The simulation required at most 13GB of RAM.

28 minutes includes the most expensive post-processing step
which takes about ~30 seconds to a minute.

# Running a single instance on a GCE VM

This test is the same as the previous case but this time
on a 32 CPU, 416GB RAM, 200GB SSD GCE node with the data
pre-copied onto the SSD (see above).  Only 10.9GB RAM was
used and a single CPU stayed at 100% whole time.  Times are:
+ 20:05.45 minute simulation; and
+ 00:52.73 postprocessing (step 1 only).

The GCE VM was substantially faster (~8 mins) than the
standalone workstation probably because it has an SSD and
newer CPUs.

# Running >2 instances concurrently - 1st attempt on standalone workstation

Mike's hypothesis that we will be able to exploit the
kernal cache will if two instances run at the same
time and try to access the same data is correct.  I ran
two instances on the same setup as above and together they
took 30 minutes.  I don't know yet how the extra 2 minute
overhead, compared to a single run, will scale.

The RAM usage doubled to 23GB.  Although the instances were
able to use the kernal cache, they probably still copied
data to the RAM of their respective containers.

To verify this in a brute force way, I tried to run
three instances at the same time knowing I only had
32GB of RAM.  RAM usage went into swap space and although
two instances seemed to progress, the third instance
slowed to a crawl.

In conclusion - it looks like running 32 instances
on a 32 core machine is possible but we'd need about
32 x 13 = 416GB of RAM to do it.

# Running >2 instances concurrently - 2nd attempt on GCE VM

On the 32 core, 416GB RAM, 200GB SSD machine,

+ 2 instances of ARIANE take:
    - 20.5GB RAM;
    - both processors at 100% the whole time;
    - 19:30.75 simulation time; and
    - 00:48.32 postprocessing time (step 1 only).
    
+ 32 instances of ARIANE take:
    - 318GB RAM;
    - 32 processors at 100% the whole time;
    - instances get slightly out of sync (reading up to 2-3 different time steps)
    - 31:02.92 simulation time for instance #1
    - 01:25.75 postprocessing time (step 1 only, instance #1 only)
    - all other instances finished within about a minute more.

Since the VM used only 318GB RAM, I stopped the machine, edited its RAM to 340GB and added 2 CPU to help with "management".  I also allowed it full access to all CloudAPIs so I could copy the results to gs://viking20.  32 instances on this machine took substantially longer with:
+ 49:00.63 minutes simulation time or instance #1
+ 01:35.32 minutes for postprocessing (step 1 only)
+ 52:16.96 minutes for finishing all instances.

During this run, the two extra processors were only at about 5% each and RAM held steady at 318GB, as before.  However, the instances got further out of sync than in the high memory VM test case, above, with a spread of 6 time steps over the instances.  Also, there were distinct times when the CPUs ramped down to wait for disk reading.  This leads me to believe that the kernal buffer cache was not large enough to deal with the spread in the time steps.  In particular, there was only ~335GB - 318GB = 17GB free space for the kernal buffer cache.  Including the model grid information (5GB) and space for a 6-time step spread (2files x 574MB/file x 6 time steps = 6888MB = 6.7GB), the kernal would need a buffer of at least ~12GB.  For an 8-time step spread (possible at certain moments?), the cache would need to be 14GB.  Both of those estimates are less than the available 17GB overhead, so I'm not totally convinced.  However, when running htop, it's clear that the kernal is fully using whatever cache space is available; the RAM bar is only 3/4 green (actual memory use) and the rest is yellow (cache).  Looking at the CPU usage, at the beginning of the simulation, the processors ramp up quickly but for the first 30 seconds they are mostly red bars (kernal processes) and then go to nearly all green except for occasional red tips for the rest of the simulation.

# Alternative - running all 32 larval perturbations in one ARIANE instance

Since larval_behaviour.txt allows different larval behavior to
be specified in a single simulation, I thought another good baseline would
be to test how long it takes to run
46,126 particles x 32 types of larval behaviors = 1,476,032 particles
in a single ARIANE instance.

The reasoning behind this is that the CPU usage for the simulation is
modest compared to the demands of the I/O bottleneck, so why not just
load the input data into one container and run all the particles in
one container? This would minimize the RAM usage at the expense of not
parallelizing all the CPU time.

It took 58 minutes and 17GB RAM to run all the particles at once with
the main output file being 1.1GB before it was split into 32 separate
files, one for each set of larval behaviors.

# Comparing Skylake versus older CPU architectures

A Skylake, 34 CPU, 416GB RAM, SSD instance, image-ariane-sfg-5
+ copied input data in 16.5 minutes.
+ ran 32 concurrent simulations in 32 minutes.

A Haswell, 34 CPU, 416GB RAM, SSD instance, image-ariane-sfg-5
+ copied input data in 16.75 minutes.
+ ran 32 concurrent simulation in 37 minutes.

A Broadwell, 34 CPU, 416GB RAM, SSD instance, image-ariane-sfg-5
+ copied input data in 16.5 minutes.
+ run 32 concurrent simulations in 36 minutes (but 36 minutes was the time for the slowest simulation, in this case there were simulations that finished at 30 minutes, too.  The other CPU architecture tests all had their simulations finish within +/- a minute of each other.

Can maxing out RAM help run things faster? - No.
A Skylake, 34 CPU, 624GB RAM, SSD instance, image-ariane-sfg-5
+ copied input data in 15.75 minutes.
+ run 32 concurrent simulations in 42 minutes.
I was expecting at least a speedup since the RAM was bigger to allow for more caching.  But, it looks like maxing out RAM is not a big help.

How small can I make the RAM while still running fast?
I already tried 340GB VM which ran slowly, so the target
RAM for this is somewhere between 340GB and 416GB.  Try 378GB:
A Skylake, 34 CPU, 378GB, SSD instance, image-ariane-sfg-5
+ copied input data in 15 minutes, 51 seconds.
+ ran 32 concurrent simulations in 38 minutes.  Used all remaining RAM for cache.

A Skylake, 34CPU, 400GB, SSD instance, image-ariane-sfg-5
+ copied input data in 16 minutes
+ ran 32 concurrent simulations in 37 minutes, including postprocessing (2 minutes), so closer to ~35 minutes.

Finally, 64 CPUs do appear to decrease the data copy time.  For 64
cores,
+ copied input data in 15 minutes.
+ ran 32 concurrent simulations in 32 minutes.

# Summary

Counting the time to copy data and the time to actually
run the simulation, it looks like we can run 32 instances
in less than hour (32 minutes compute time + 16 minute data
copy time) on a 32 core x 416GB RAM node.  The cost
for a 32core, 416GB RAM, 200GB SSD, preemptable machine would be:
$0.884 per hour x 0.8 hour run time x 200 instances = $142 
with the minimum total run time, assuming all 200 instances
running at the same time, being 0.8 hours.  The non-preemptable
cost is about 3.2x more.

The alternative, to run all 32 types of larval swimming in
one, slower instance (1 hour compute time + 16 min. data copy time)
using a 2 core, 18GB RAM, 200GB SSD, preemptable machine would be:
$0.083 per hour x 1.3 hour run time x 200 instances = $21 
with the minimum total run time, assuming all 200 instances
running at the same time, being 1.3 hours.  The non-preemptable
cost is about 2x more.

The duplicated RAM usage and high I/O needs of concurrent
ARIANE containers can make the finest grain parallelization more
expensive. Even the intermediate-level parallelization option
has the potential to parallelize both the I/O bottleneck and the CPU
time across 200 instances.

