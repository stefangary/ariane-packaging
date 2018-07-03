#!/bin/bash -norc
#===========================
# This software is distributed under
# the terms of the GNU GPL, v3 and
# any later version.
# Copyright, Stefan Gary
#===========================
# Build the ARIANE container
#===========================

# Copy over the container contents
gsutil rsync -r gs://viking20/ariane_container/ ./ariane_container/

# Build the container
cd ariane_container
# Always need to manually specify execute permissions
# on scripts stored on gs://viking20?
chmod a+x test.sh
chmod a+x install_netCDF4.sh
docker build -t ariane_container .
