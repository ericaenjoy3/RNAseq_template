#!/usr/bin/env sh
#BSUB -q express
#BSUB -P acc_LOAD
#BSUB -W 1:00
#BSUB -J varPart 
#BSUB -oo %J.out.%I
#BSUB -eo %J.err.%I
#BSUB -n 1
#BSUB -R "span[hosts=1] rusage[mem=48000]"

ml purge; ml singularity/3.6.4;
unset R_LIBS;
singularity exec ~/work/rna.sif Rscript --no-save --no-restore varPart_cutadapt.R \
  --salmonf {{cookiecutter.root_folder}}/{{cookiecutter.author_name}}/rna_seq/inhouse/{{cookiecutter.study_name}}/salmon_cutadapt/gene_merge.tsv 
