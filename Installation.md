# Installation

# Part 1: Background

ARIANE is built with the usual make,
make check, make install pipeline
and it depends on the NetCDF library.
ARIANE is not sensitive to which
version of NetCDF is used - here we
use 4.1.3 because its FORTRAN and C
libraries are part of the same build
instead of separate builds with more
recent versions.

See https://gist.github.com/perrette/cd815d03830b53e24c82
for a nice example of a NetCDF and dependencies install
script.

NetCDF, ARIANE, and my tcdf visualization
package are all built into a Docker container
so that ARIANE's run environment is easily
ported to nodes.  Tcdf is available at:
https://github.com/stefangary/tcdf

# Part 2: Building the container

This is only done once in a blue moon when the code of
ARIANE, netcdf (and dependencies), or tcdf is changed
and changes need to be incorporated into the container.
The script **build_ariane_container.sh** automates this
process.  Call it directly from the larval-parameter-sweep
directory.

To store the container in a repository:
 
+ first, start the container​ with a name​,
 
     - docker run -it --name=new_container_name old_container_name  /bin/bash
 
+ second, detach from the container w/ cntl​ ​p-q or open new terminal
 
+ third, commit the started container,

     - docker commit new_container_name repository/new_container_name
 
+ Create a new handle in your docker account called new_container_name
 
+ Finally, push the image to that handle

    - docker push repository/new_container_name

+ Then, one can pull that container with:

    - docker pull repository/new_container_name
    