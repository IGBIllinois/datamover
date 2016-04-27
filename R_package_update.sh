#!/bin/bash
#PBS -j oe
#PBS -N R_package_update
#PBS -q default
#PBS -M dslater@igb.illinois.edu
#PBS -m abe
#PBS -d /home/a-m/datamover/log

module load R/experimental

echo -n "Time Started: "
date "+%Y-%m-%d %k:%M:%S"

Rscript /home/a-m/datamover/bin/R_package_update.R

echo -n "Time Finished: "
date "+%Y-%m-%d %k:%M:%S"
