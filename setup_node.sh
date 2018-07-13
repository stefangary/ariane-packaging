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
sudo apt-get -y install sysstat
sudo apt-get -y install emacs
git config --global user.email "stefanfgary@gmail.com"
git config --global user.name "stefanfgary"

#---------------------------------------------
# 3) Install Docker
#---------------------------------------------
# a) Download key for Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# b) Add Docker repo to APT sources:
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Note: $(lsb_release -cs) works in bash, but it is interpreted as a
# variable in tcsh, so if you have to use tcsh, try:
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu trusty stable"
# where trusty can be replaced with xenial, etc. WARNING - if you
# upgrade Ubuntu, you will need to change this line in the repo.

# c) Next, update the package database with the Docker packages:
sudo apt-get -y update

# d) Check which repo you are installing from
#    (Can comment this out later once you are certain it works.)
#    Look for https urls directly from Docker.
#apt-cache policy docker-ce

# e) Finally, actually install:
sudo apt-get install -y docker-ce

# f) Check docker is running
#    (Comment out later once you are certain it works)
#sudo systemctl status docker

#---------------------------------------------
# 4) Pull Docker repository
#---------------------------------------------
# Need manual command line intervention for
# private repository.
#sudo docker login
#sudo docker pull stefanfgary/ariane
