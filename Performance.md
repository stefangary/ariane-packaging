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
+ ran 32 concurrent simulations in 37 minutes, including postprocessing (~2 minutes), so closer to ~35 minutes.

A Skylake, 34 CPU, 416GB, SSD instance, image-ariane-sfg-6
+ copied input data - unknown due to preemption and not logged
+ 2 nodes finished data copy, 32 concurrent simulations data saving (8 total nodes deployed, but 6 got preempted) in 56.0 minutes and 57.8 minutes (log data to reconstruct: create log file on PW GUI: 13:45:27 = 49527, data saved on bucket at 14:41:25 = 52885s and 14:42:34 = 52994s)
+ So, assuming 16 minute data copy and 2 minutes postprocessing and 2 minutes output compression and copy, 56.0 - 16 - 2 -2 = ~36 minutes and ~38 minutes with uncertainties on the order of 1 minute.

So, it appears that the extra 16 GB of RAM compared to the 400GB node does not help very much.  I wonder if bigger RAM usage makes a preemptible machine more of a target for being preempted.

Finally, 64 CPUs do appear to decrease the data copy time.  For 64
cores,
+ copied input data in 15 minutes.
+ ran 32 concurrent simulations in 32 minutes.

# Impact of Image size (and SSD size) on run times

According to GCE documentation at:
https://cloud.google.com/compute/docs/disks/performance#ssd-pd-performance
it seems that the read/write speed to an SSD scales
linearly with the size of the SSD as well as the number
of CPU.  We have already reached the plateau with
the number of CPU, so I attempted to double the
size of the SSD from 200GB to 400GB to test for
any increase in run time.  I estimate that:
15 minutes of data copy time -> 7.5 minutes with doubling of I/O speed
1/3*35 = 12 minutes of I/O during sim time -> reduced to 6 minutes
for a total time savings of 13 minutes.

However, when running 2 VM's with two (cycling over)
jobs each, I found that that the execution time was
about the same or worse as the previous runs.

| Copy | Sim | Save | Notes |
|---|---|---|---|
| 20:27 | 35:49 | 2:44 | |
| 14:33 | 35:37 | 6:06 | |
| 14:01 | 37:55 | 6:03 | |
| 20:06	| 43:30 | 2:46 | |
| 17 | 39 | | avg |
       
In conclusion, it is not worth expanding the size of
the images.

In another run, I created a new image that is only 150GB
to test if a smaller image really runs slower as the
Google Console GUI suggests.  I ran 2 VM's each cycling
over 2 jobs with the following times.

| Copy | Sim | Save | Notes |
| --- | --- | --- | --- |
| 20:51 | 49:23 | 6:54 |
| 22:10 | 55:58 | 2:48 |
| 21:40 | 38:35 | 2:28 |
| 20:53 | 40:05 | 6:24 |
| 21 | 46 | | avg |

Saving seems to be about the same, perhaps a little slower.
Simulation times are consistently much higher (7 minutes slower
on average) as are the data copy times (4 minutes slower).
The total savings of 200GB SSD instead of 150GB SSD is
11 minutes, which is a substantial portion of a 1 hour
run time.

# An attempt to run with local SSD scratch space instead of persistent SSD

It's fairly straightforward to dump the whole workflow into
a locally mounted SSD which is supposed to be faster than
persistent disk SSD.  In a test,

| Copy | Sim | Save | Notes |
| --- | --- | --- | --- |
| 12:56 | 35:53 | 6:09 |
| 13:34 | 36:13 | 2:46 |
| 13:38 | 60:27 | 2:48 |
| 12:46 | 36:21 | 6:02 |
| 13:11 | 42:08 | | avg |

Local SSD results in the fastest ever recorded data copy times,
by about ~2-3 minutes (~20% of the total copy time, or ~5% overall).
The simulation does not appear to be speeded up very much, however.
In fact, it seems slower by about ~3 minutes, which is the amount of
time saved by the copying time.  Of course, the 60min run time may
be an anomaly, but even still, comparable simulation times are
achieved by the persistent 200GB SSD, without the local SSD.

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

