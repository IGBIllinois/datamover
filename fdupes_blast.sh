#!/bin/bash

#PBS -j oe
#PBS -N fdupes_blast
#PBS -q default
#PBS -M dslater@igb.illinois.edu
#PBS -m abe
#PBS -d /home/a-m/datamover/log

module load fdupes

DIRECTORY="/home/mirrors/NCBI/BLAST_DBS"
fdupes -rH $DIRECTORY
