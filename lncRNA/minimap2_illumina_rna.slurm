#!/bin/bash
#SBATCH --job-name=rna_minimap2
#SBATCH --partition=long
#SBATCH --mail-user=jmmenend@ucsc.edu
#SBATCH --nodes=1
#SBATCH --mem=500gb
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --output=rna_minimap2.%j.log
#SBATCH --time=168:00:00

reference=$1
fastq_r1=$2
fastq_r2=$3

aligned=$4

# launch conda within shell script
source /private/home/jmmenend/software/anaconda3/etc/profile.d/conda.sh

# activate minimap2 env
conda activate /private/groups/migalab/jmmenend/.conda_envs/minimap2

# launch minimap2 rna genome align 
minimap2 \
    -ax sr \
    -uf \
    -I 16G \
    ${reference} ${fastq_r1} ${fastq_r1} > ${aligned}

conda deactivate