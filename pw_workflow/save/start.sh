#!/bin/bash

export SWIFT_HEAP_MAX=4G
export SWIFT_USERHOME=/tmp/swifthome
export GLOBUS_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
export GLOBUS_TCP_PORT_RANGE=9000,9500

export WORKER_LOGGING_LEVEL=DEBUG
export WORKER_LOG_DIR="/tmp/swiftwork"

export PATH=$PATH:/swift-pw-bin/swift-svn/bin

swift main.swift