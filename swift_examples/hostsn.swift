type file;
#================================================
# Swift script to determine the available hosts.
#
# use the optional -n=<integer_N> to call the
# the hostname request, in parallel, integer_N
# times.
#
# In older versions, all function calls and
# variables were prefixed with @ but that is
# not the case with the new version of SWIFT.
# Commented out code below does the same thing
# and works, too, just prompting a warning
# saying that @ is depreciated.
#================================================
app (file o) hostname ()
{
  hostname stdout=@o;
}

file out[]<simple_mapper; location="outdir", prefix="f.",suffix=".out">;
foreach j in [1:@toInt(@arg("n","1"))] {
  out[j] = hostname();
}

#==============================================
# Original code
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
