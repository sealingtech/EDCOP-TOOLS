#!/bin/bash
# Configuring Moloch script, only change the $VARIABLES
# Please use the Master's IP for the ESURL
# Only change the 3 variables below:
CONTAINERINT="net0"
ESURL="nodelogs"
CLUSTERPASSWORD="sealingtech"

/data/moloch/bin/Configure << EOF
$CONTAINERINT
no
$ESURL:30000
$CLUSTERPASSWORD
EOF 
