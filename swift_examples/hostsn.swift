type file;
#================================================
# Swift script to determine the available hosts.
# Example call:
#
# swift hostsn.swift -n=42
#
# use the optional -n=<integer_N> to call the
# the hostname request, in parallel, integer_N
# times.  The mechanism for this is the arg
# function, which can be embedded in the loop.
#
# In older versions, all function calls and
# variables were prefixed with @ but that is
# not the case with the new version of SWIFT.
# Commented out code below does the same thing
# and works, too, just prompting a warning
# saying that @ in front of function calls is
# depreciated.
#
# However, note the @ in front of the filename
# "o" in the app declaration.  This is necessary
# to convert a declared file variable to a file
# name.  You can also use filename(o) instead of
# @o.
#================================================

#================================================
# Inputs/Outputs
#================================================
# Here, I explicitly create a holder variable for
# the number of calls of hostname:
int num_call_hostname = toInt(arg("n","1"));
# and then replace that in the foreach loop,
# below.  The arg command will read the value
# from the variable -n= on the command line.
# The last parameter is the default value.

#================================================
# App declarations 
#=================================================
# I've changed the name of the app to make
# it explicit which hostname is a LINUX system
# call (in the app) and a swift app call that is
# a wrapper for the LINUX system call.
#================================================
app (file o) hostname_app_wrap ()
{
  hostname stdout=filename(o);
}

# Note that it is **ESSENTIAL** that you use
# the filenames function rather than the
# filename function for this to work.
app (file o) cat_file_array_app ( file[] infile )
{
  cat filenames(infile[*]) stdout=filename(o);
}

#================================================
# Workflow elements
#================================================
# Once the inputs/outputs and app declarations
# are taken care of, the real work is done here.

# First create an array of files.  It's an array
# because of the [] after the variable name "out".
# Note that the directory "outdir" is created if
# it doesn't exist already.  If it does exist,
# then anything in there is potentially
# overwritten.  The prefixes and suffixes are the
# start and end of each filename for the files
# that are created in outdir.  The output files
# are all named: f.XXXXXX.out with the padding
# of zeros set by the padding=6 parameter to
# ensure always 6 digits.
file out[]<simple_mapper; location="hostsn_outdir", prefix="f.",suffix=".out",padding=6>;

# Call the hostname app wrapper a certain
# number of times.
foreach j in [1:num_call_hostname] {
  out[j] = hostname_app_wrap();
}

# Create a single file for all the output to go to
file out_all <"all.log">;
out_all = cat_file_array_app(out);

#---------THIS DOES NOT WORK----------
# You cannot append to a SWIFT file.
# ALL SWIFT VARIABLES ARE SINGLE ASSIGNMENT
#foreach j in [1:num_call_hostname] {
#  out_all = hostname_app_wrap();
#}


#==============================================
# Original code for reference only
#==============================================
#app (file o) hostname ()
#{
#  hostname stdout=@o;
#}
#
#file out[]<simple_mapper; location="outdir", prefix="f.",suffix=".out">;
#foreach j in [1:@toInt(@arg("n","1"))] {
#  out[j] = hostname();
#}
#==============================================
