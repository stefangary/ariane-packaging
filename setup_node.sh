#!/bin/bash -norc
#==========================
# This software is distributed
# under the terms of GNU GPL v3
# and any future versions.
# Copyright, Stefan Gary 2018
#==========================
# Set up a node for parallel
# ARIANE runs.
#
# This will not be necessary
# once an image is taken of
# the VM and saved for
# deployment later.
#===============================================

#---------------------------------------------
# 0) Download key environment files from GitHub
#---------------------------------------------
# (You need to do this first so you can access
#  THIS script!!)
#git clone https://github.com/stefangary/larval-parameter-sweep.git
#
#---------------------------------------------
# 1) Update the software
#---------------------------------------------
sudo apt-get -y update
sudo apt-get -y upgrade

#---------------------------------------------
# 2) Install some OPTIONAL but useful software
#---------------------------------------------
# Useful for development.  Comment this out
# when it comes time for production.
sudo apt-get -y install htop
sudo apt-get -y install emacs

#---------------------------------------------
# 3) Install Docker
#---------------------------------------------

#---------------------------------------------
# 4) Pull Docker repository
#---------------------------------------------
# Need manual command line intervention for
# private repository.




