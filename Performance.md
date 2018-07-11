# Performance Characteristics

The biggest challenge in this project is the I/O bottleneck, followed by RAM needs and, finally, CPU needs.

# Copying data to node

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

# Running a single instance

Our goal is to simulate 46,126 particles over one year.
We will add 32 different perturbations to the particle
behavior and 200 different launch times, resulting in
6,400 total instances (32 * 200).

On a stand alone workstation with regular hard drives
in a software RAID0 configuration, a single full-domain
instance takes 28 minutes.  This is about 13 minutes longer
than my initial estimates because I did not account for
the larger domain of the simulation.  If this
is an issue for using premptive resources, then 6 month
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

# Running two or more instances at the same time

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

# Summary

Counting the time to copy data and the time to actually
run the simulation, it looks like we can run 32 instances
in about an hour (30 minutes compute time + 30 minute data
copy time) on a 32 core x 416GB RAM node.  The cost
for a 32core, 416GB RAM, 200GB SSD, premptable machine would be:
$0.884 per hour x 1 hour run time x 200 instances = $177 
with the minimum total run time, assuming all 200 instances
running at the same time, being 1 hour.  The non-premptable
cost is about 3.2x more.

The alternative, to run all 32 types of larval swimming in
one, slower instance (1 hour compute time + 30 min. data copy time)
using a 2 core, 18GB RAM, 200GB SSD, premptable machine would be:
$0.083 per hour x 1.5 hour run time x 200 instances = $25 
with the minimum total run time, assuming all 200 instances
running at the same time, being 1.5 hours.  The non-premptable
cost is about 2x more.

Although it is tempting to pursue the finest grain parallelization
possible, the duplicated RAM usage and high I/O needs of concurrent
ARIANE containers can make the finest grain parallelization much more
expensive and not that much faster than an intermediate-level
parallelization.  Even the intermediate-level parallelization option
has the potential to parallelize both the I/O bottleneck and the CPU
time across 200 instances. Furthermore, for a relatively small increment
in cost, we can switch from premptable to non-premptable resources
making it easier to manage the 200 instances.

