#!/bin/bash
#SBATCH --job-name=g01b
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=180g
#SBATCH --time=14-00:00:00
#SBATCH --account=alev0
#SBATCH --partition=standard
#SBATCH --licenses=stata-mp@slurmdb:1
#SBATCH --mail-user=emkang@umich.edu
#SBATCH --mail-type=ALL

# Load stata
module load stata-mp/17

# Go to working directory
cd "/nfs/turbo/lsa-emkang/Replication_files_final"

# Run code
stata-mp -b ./code/g01_crosswalk_b.do