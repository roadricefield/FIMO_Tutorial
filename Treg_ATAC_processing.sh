#!/bin/sh

index="${HOME}/mm10_index/mm10_index" #Path to your bowtie2 mouse genome index
adapter="${HOME}/miniconda3/share/trimmomatic/adapters/NexteraPE-PE.fa" #Path to your trimmomatic adapter "NexteraPE-PE.fa"

R1="./ENCFF175VOD.fastq"
R2="./ENCFF447BGX.fastq"
file_name="Treg_ATAC"

mkdir fastQC
mkdir fastQC/raw
mkdir fastQC/trimmed

#gunzip
gunzip *.gz

#fastQC
fastqc --nogroup --threads 2 -o ./fastQC/raw ./${R1} ./${R2}

#Adapter trimming with trimmomatic
trimmomatic PE -threads 8 -phred33 $R1 $R2 ./trimmed_R1.fastq ./unpaired_R1.fastq ./trimmed_R2.fastq ./unpaired_R2.fastq \
ILLUMINACLIP:${adapter}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

#fastQC for trimmed
fastqc --nogroup --threads 2 -o ./fastQC/trimmed ./trimmed_R1.fastq ./trimmed_R2.fastq

#Mapping with bowtie2
bowtie2 -p 8 -t -x ${index} -1 ./trimmed_R1.fastq -2 ./trimmed_R2.fastq -S ./mapped.sam

#Convert sam to bam with samtools
samtools view -@ 8 -bS ./mapped.sam -o ./mapped.bam

#Sort bam with samtools
samtools sort -@ 8 ./mapped.bam -o ./${file_name}.bam

#Make index
samtools index -@ 8 ./${file_name}.bam

# collect insert size
picard CollectInsertSizeMetrics I=${file_name}.bam O=${file_name}_insert_size.txt H=${file_name}_insert_histgram.pdf HISTOGRAM_WIDTH=2000

#Remove intermediate files
rm -rf ./trimmed_R1.fastq ./trimmed_R2.fastq ./unpaired_R1.fastq ./unpaired_R2.fastq ./mapped.sam ./mapped.bam

#Make bigwig with bamCoverage
bamCoverage -b ./${file_name}.bam -p 8 --ignoreDuplicates --normalizeUsing RPGC --effectiveGenomeSize 2652783500 --binSize 1 -o ./${file_name}.bigwig

#Peak call by MACS2
macs2 callpeak -f BAM -t ./${file_name}.bam -g mm --outdir MACS2 -n ${file_name}

#Convert xls into bed
cat ./MACS2/Treg_ATAC_peaks.xls | grep -v '^#' | sed '/^$/d' | sed '1d' | awk -v 'OFS=\t' '{print $1, $2, $3}' > ./MACS2/Treg_ATAC_peaks.bed