#!/bin/bash
#PBS -j oe
#PBS -N diamond
#PBS -q default
#PBS -M dslater@igb.illinois.edu
#PBS -m abe
#PBS -l nodes=1:ppn=24
#PBS -d /home/a-m/datamover/blast

module load diamond/0.8.5

diamond makedb --in nr -d nr

