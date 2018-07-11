# Performance Characteristics

Initial tests were carried out to
understand the I/O bottle neck challenge
and RAM and CPU needs for this project.

# Copying data to node

A first test for copying data to a
node results in 108 files copied over
17 minutes.  I interrupted the transfer
early since I was about to fill the disk.
Conclusions:

 + I need space for an additional 38 files = ~22 GB.
 + I estimate the total "real world" copy time to be ~23 minutes.
 + I transferred ~65 GB in ~18 minutes => (65*8)/(18*60) = 0.5Gbit/s

gsutil says this would go faster if I
included compiled crcmod.  Install that on
the node using instructions at:

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
main output file is 162MB with other, optional, output
files on the order of 450KB.  The simulation required at
most 13GB of RAM.

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
data to their respective containers.

To verify this in a brute force way, I tried to run
three instances at the same time knowing I only had
32GB of RAM.  RAM usage went into swap space and although
two instances seemed to progress, the third instance
slowed to a crawl.

In conclusion - it looks like running 32 instances
on a 32 core machine is possible but we'd need about
32 x 12 = 384GB of RAM to do it.

# Summary

Counting the time to copy data and the time to actually
run the simulation, it looks like we can run 32 instances
in about an hour on a 32 core x 384GB RAM node.


