#!/usr/bin/env sh
#BSUB -q premium 
#BSUB -P acc_LOAD
#BSUB -W 6:00
#BSUB -J dream 
#BSUB -oo %J.out.%I
#BSUB -eo %J.err.%I
#BSUB -n 8
#BSUB -R "span[hosts=1] rusage[mem=6000]"

ncpu=$LSB_DJOB_NUMPROC
if [ "$ncpu" = "" ] ; then ncpu=$(expr `nproc` / `lscpu | grep 'Thread(s) per core:' | sed 's/Thread(s) per core:\s*//'`) ; fi

module purge
ml singularity/3.6.4
unset R_LIBS
unset R_HOME
singularity exec ~/work/rna.sif Rscript --no-save --no-restore dream_cutadapt.R \
  --starf {{cookiecutter.root_folder}}/{{cookiecutter.author_name}}/rna_seq/inhouse/{{cookiecutter.study_name}}/star_cutadapt/star_gene.tsv \
  --contrastf {{cookiecutter.root_folder}}/{{cookiecutter.author_name}}/rna_seq/inhouse/{{cookiecutter.study_name}}/data/Contrasts.tsv \
  --infof {{cookiecutter.root_folder}}/{{cookiecutter.author_name}}/rna_seq/inhouse/{{cookiecutter.study_name}}/data/varPart_info.tsv \
  --formf {{cookiecutter.root_folder}}/{{cookiecutter.author_name}}/rna_seq/inhouse/{{cookiecutter.study_name}}/data/dream_form.tsv \
  --ncore $ncpu
