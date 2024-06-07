# Pulling Data + Wrangling: (From Arang's Datasheet)

Launch some sort of computing session (ALL COMPUTATION SHOULD BE DONE IN ONE OF THESE!!!):
```
# EXAMPLE:
srun --job-name=interactive_medium \
        --nodes=1 \
        --cpus-per-task=16 \
        --mem=256G \
        --time=12:00:00 \
        --partition=medium \
        --pty bash
```

cd into working directory:
```
cd /private/groups/migalab/jmmenend/RNA_workflow
```

Fetch files:
```
wget ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_RNAseq/AshkenazimTrio/HG002_NA24385_son/Mason_ONT-directRNA/reads/HG002_GM24385_directRNA_ONT_Mason_20230526.fastq.gz   
wget ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_RNAseq/AshkenazimTrio/HG002_NA24385_son/Mason_ONT-directRNA/reads/HG002_GM26105_directRNA_ONT_Mason_20230526.fastq.gz   
wget ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_RNAseq/AshkenazimTrio/HG002_NA24385_son/Mason_ONT-directRNA/reads/HG002_GM27730_directRNA_ONT_Mason_20230526.fastq.gz  
```

Unzip all of the fastq files:   
`for gzip in *.gz; do gzip -d $gzip; done`   

# Running alignment: (Following FLAIR just cuz its easiest... I hope)

### Installing FLAIR    

**This assumes you already have some conda software installed!!!**    

Only need to be run once to create env:    
`conda create -p /private/groups/migalab/jmmenend/.conda_envs/flair -c conda-forge -c bioconda flair # DO NOT RUN`    

Activates FLAIR environment:    
`conda activate /private/groups/migalab/jmmenend/.conda_envs/flair # should just be able to run this to load from my environment`

### Launching Alignments
Run alignment slurm script:   
`sbatch minimap2_rna_genome.slurm <ref.fasta> <input.fastq> <output.sam>`

**Script contains:**   
```
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
fastq=$2
aligned=$3

# launch conda within shell script
source /private/home/jmmenend/software/anaconda3/etc/profile.d/conda.sh

# activate minimap2 env
conda activate /private/groups/migalab/jmmenend/.conda_envs/minimap2

# launch minimap genome align
minimap2 \
    -ax splice \
    -uf \
    -k14 \
    -I 16G \
    ${reference} ${fastq} > ${aligned}
    
#example of transcriptome align
#minimap2 \
#    -ax map-ont \
#    -N 100 \
#    -I 16G \
#    ${reference} ${fastq} > ${aligned}

conda deactivate
```

### Create GTF/Transcriptome File from HG002 Q100 GFF Annotations
```
conda activate /private/groups/migalab/jmmenend/.conda_envs/gffread

# do this for both MAT/PAT Haplotypes
gffread ${hg002_gff} -T -o ${hg002_gtf}

# create transcriptome from GTF file
gffread -F -w ${transcriptome_fasta_output} -g ${genome_fasta} ${gtf}
```

Should result in 6 alignment files per sample:
 * Genome
    - Diploid
    - Maternal
    - Paternal
 * Transcriptome
    - Diploid
    - Maternal
    - Paternal


# Transcript Counting:
```
# count transcript
featureCounts -L --primary -T 32 -a ref/hg002v1.0.1.MAT+PAT.liftoff.polished.sqanti3.sorted.addFeatures.addTags.modiAttribute.gtf -o counts/HG002_directRNA_ONT_Mason_20230526.minimap2_featureCounts.tsv alignments/HG002_GM24385_directRNA_ONT_Mason_20230526.minimap2_genome.bam alignments/HG002_GM24385_directRNA_ONT_Mason_20230526.minimap2_transcriptome.bam alignments/HG002_GM26105_directRNA_ONT_Mason_20230526.minimap2_genome.bam alignments/HG002_GM26105_directRNA_ONT_Mason_20230526.minimap2_transcriptome.bam alignments/HG002_GM27730_directRNA_ONT_Mason_20230526.minimap2_genome.bam alignments/HG002_GM27730_directRNA_ONT_Mason_20230526.minimap2_transcriptome.bam

# convert to count matrix
awk 'NR>1 {OFS="\t"} {printf "%s ", $1; for (i=7; i<=NF; i++) printf "%s ", $i; print ""}' HG002_directRNA_ONT_Mason_20230526.minimap2_featureCounts.tsv > HG002_directRNA_ONT_Mason_20230526.minimap2_featureCounts_quant.tsv


```


