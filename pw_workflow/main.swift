type file;

# ------ INPUTS / OUTPUTS -------#
# The strings start_year and final_year correspond
# exactly to the strings in the .xml file.  Through
# the PW interface, they are passed as command line
# arguments to swift (hence the arg() command) and
# then they are converted to integer values here.
int start_year = toInt(arg("start_year","1959"));
int final_year = toInt(arg("final_year","1959"));

# The seasons list in the .xml file is a list of
# text items that are space delimited.  Again, that
# text is passed as a command line argument to
# swift via the PW interface.  The PW
# interface converts the space delimited text to
# underscore delimited text (e.g. DJF_MAM_JJA_SON)
# which then needs to be parsed by "_" in strsplit
# before being sent to a string array.
string seasons[]  = strsplit(arg("seasons","DJF"),"_");

# Logs to ensure there is an output file
# but the actual data is going to be copied to
# gs://viking20.
file stdout_file <arg("stdout_log","stdout.log")>;
file stderr_file <arg("stderr_log","stderr.log")>;

# Supporting scripts located in the scripts
# directory on the PW interface.  FilesysMapper
# will map a list of files to an array of files.
# In this case, the list of files is contained
# in the directory scripts (the location specifier).
file scripts[]	<FilesysMapper;location="scripts">;

# ------- APP DEFINITIONS -------#

# This is the main simulation and any postprocessing
# is done here as well.
app (file o,file e) simulation (file[] scripts, int year_step, string season_step)
{
  bash "scripts/simwrap.sh" year_step season_step stdout=filename(o) stderr=filename(e);
}

# Concatenate a list of files into a single file.
# Here we need two versions - one version with a file
# array indexed by integers, _int_index_, and one with
# a file array indexed by strings, str_index_.  The
# reason for this is that one loop is by integers
# and the other loop is by strings.
app (file o) cat_file_array_int_index_app ( file[] input_array_of_files )
{
  cat filenames(input_array_of_files[*]) stdout=filename(o);
}
app (file o) cat_file_array_str_index_app ( file[string] input_array_of_files )
{
  cat filenames(input_array_of_files[*]) stdout=filename(o);
}

# ----- WORKFLOW ELEMENTS ------#

# Initialize lists of files to store stdout and stderr
# in each instance.
file simout_by_year[] <simple_mapper; location="output", prefix="simout_", suffix=".log", padding=3>;
file simerr_by_year[] <simple_mapper; location="output", prefix="simerr_", suffix=".log", padding=3>;

# We have 50 years and 4 seasons/per year so
# these loops should create 200 instances at
# most.
foreach yy in [start_year:final_year] {

	file simout_by_season[string] <simple_mapper; location="output_by_season", prefix="simout_", suffix=".log", padding=3>;
    file simerr_by_season[string] <simple_mapper; location="output_by_season", prefix="simerr_", suffix=".log", padding=3>;
	foreach ss in seasons {
  		(simout_by_season[ss],simerr_by_season[ss]) = simulation(scripts,yy,ss);
	}
	
	# Concatenate the files run in seasons
	simout_by_year[yy] = cat_file_array_str_index_app(simout_by_season);
	simerr_by_year[yy] = cat_file_array_str_index_app(simerr_by_season);
}

# Once all the simulations are done, concatenate all
# the log files.
stdout_file = cat_file_array_int_index_app(simout_by_year);
stderr_file = cat_file_array_int_index_app(simerr_by_year);

# Even though these are nested loops, to the best of my
# knowledge, all the instances are able to run entirely
# in parallel and SWIFT takes care of the log files in
# a very natural way.

