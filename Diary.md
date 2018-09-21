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

# Using the ParallelWorks interface - July 16-19, 2018

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

It took a good deal of experimentation before I understood exactly how to pass
variables from the GUI's form interface into the SWIFT script.  The key
advancement in my understanding that made it easier for me to progress was
the idea that swift is started via the command line from the GUI and all the
parameters passed from the form are send to swift via command line flag
options, for example: swift main.swift -n_opt=42.  The form defines the values
on the command line and the main.swift script has to be compatible with
the form's inputs.

# Using SWIFT - July 18-19, 2018

The most challenging thing I find about learning SWIFT is the paths.  That's
not surprising - in almost every new language/environment it's the process
of understanding where stuff *is* that is the most challenging step.

Once I wrote a handy app in SWIFT to combine log files,
app ( file out_file ) cat_file_array_app ( file[] in_file_array )
{
  cat filenames(in_file_array[*]) stdout=filename(out_file);
},
I was able to verify that all the test instances were in fact
doing the right thing.  The other discovery that helped me was
the bash SECONDS varible which allowed me to effectively time
the executions of each instance within the shell script and
post the run times to the log files.

I am **astonished** and **thrilled** at how easy it is to then
post a SWIFT workflow onto the PW interface, set the chosen
parameters for the resources to use (e.g. number of CPUs,
number of computers) and then just make things happen.  I also
am impressed with the ability of the PW GUI to monitor and
manage the amount of CPU-hours that are being consumed.  It's
very straightforward to keep track of what's being used.

# First attempt at a full run - Aug 23, 2018
 
The nodes are continuing to register.  Very slow to access gs://viking20
to get copy updates, but perhaps this is due to new nodes coming online.
When the number of nodes plateaus at 187, getting info at the reports
is fast.  Perhaps cloud storage slows when new files are being created
but is faster with updated files?
 
Registered workers appears to plateau at 187.  This plateau is first
due to the available resources at the time, then a separate plateau
occurrs when we reached our cap for total SSD space on GCE!
 
I am impressed with how fast the registered workers are deleted once
they are done.  Workers are killed after the max wall time allowed
which is counted from the time the worker is requested on the PW
interface, ***not*** when it actually starts working on the
problem, so it is important to factor in some overhead time in
the "Auto-shutdown" field of the resources page AND in the
"Max wall time" field of the resource button (cloud icon) on
the workflow's compute tab.

I also noted that it is important to clean up a node when done
because it may be possible that the PW GUI will use that node
for a second time (if there are not enough resources available)
and so that means that if the node is not clear, it may have
trouble overwriting data from the previous run.  In my case, I
also want to allow at least 2x more time in the "Auto-shutdown"
and "Max wall time" fields to allow for two cycles on the
nodes.

# Second attempt at a full run - Sept 17, 2018

Three of the runs used a corrupted file as input, so those
input files were fixed.

I removed excess Docker images from the node.  I found on the
GCE documentation ( https://cloud.google.com/compute/docs/disks/performance#ssd-pd-performance )
that the I/O speed on an SSD depends on both the number of CPU
(ensuring that there are some unused CPU to manage I/O) as
well as the size of the SSD.  SSD I/O plateaus after 32 CPU,
which is great beacuse that is the number we want to use
anyway.  As for SSD size, 200GB, we get about 96MB/s.  While
I can shrink the image to 128GB, that would result in SSD
limits of 61MB/s (36% loss in speed).  If I double the image
size to 400GB, we get 192MB/s (doubling in speed).  I am
curious to try this as perhaps we can dramatically speed
up the calculation (at greater cost, of course).



 
