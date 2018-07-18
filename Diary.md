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

# Using the ParallelWorks interface - July 16, 2018

I stated using the PW interface by making a test run with the avgnum_workflow.
As prompted by the GUI, I had to first start the compute engine, which booted
a single node.  Then, I ran the calculation and noted that several workers
were all automatically started by the initial worker and the calculation
spanned all the workers (including the initial worker).  When new workers
are created, it looks like they all start from the default image, they are
not spawned as copies of the first worker that was created when I turn on
the button.

Next, I duplicated the avenum_workflow to make a testing environment in which
I could start to manipulate files.  I set the theme to "Clouds-Midnight" in the text editor to reverse the colors.

# Using SWIFT - July 18, 2018

The most challenging thing I find about learning SWIFT is the paths.  That's
not surprising - in almost every new language/environment it's the process
of understanding where stuff *is* that is the most challenging step.

Some notes:
SWIFT tutorial and manual are out of date.

SWIFT manual has out of date link to SWIFT tutorial, first paragraph.

In the SWIFT guide,
http://swift-lang.org/guides/release-0.96/quickstart/quickstart.html
the hello.swift function that's provided does not output the
hello.txt file as specified in the tutorial.

SWIFT Manual uses filesys_mapper while it appears that FilesysMapper
is now the correct usage.

