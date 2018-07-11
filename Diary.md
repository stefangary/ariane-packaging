# Project diary

# Using Docker - June 2018

Although it took some time for me to understand what Docker was,
I am extremely impressed and believe that it makes for an excellent
way to streamline the distribution of scientific software.  My
biggest stumbling block was understanding that the paths in mounted
directories must be set up for the **Docker instance** and not for
the host machine.  While this is perhaps obvious in hindsight, it
took me a little digging to figure out why things didn't work at
first.

In the future, I'm going to consider creating public Docker images
for my scientific software and data associated with my publications
so that the data processing and analysis I do can be achived in a
relatively easily accessible and transparent manner.

# Uploading data to Google Cloud - June/July 2018

The gsutil package works well and reliably.  I found that using rsync
helps to automate the process of sending files and a large amount of
data can be sent even over a weekend.

# Using Google Compute Engine - July 11, 2018

I am impressed with how easy it is to customize a virtual machine for
use in the cloud.  It is also easy to start and terminate machines
so I have good control over which resources I am using.

Once logged in (an easy click on the VM Instances list), the VM is
lightning fast, and already prepared and connected to key aspects
of the compute environment (e.g. git, gsutil, and access to the
ParallelWorks cloud buckets) so it is easy to hit the ground running
with a newly created instance.  For example of how I set up a node,
see setup_node.sh.

# Using the ParallelWorks interface

