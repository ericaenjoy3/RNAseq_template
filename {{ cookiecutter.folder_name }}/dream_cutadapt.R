#!/usr/bin/env Rscript

libs <- c("data.table", "limma", "affy", "ggplot2", 
  "RColorBrewer", "grDevices", "scales", "GGally", "ape",
  "pheatmap", "ComplexHeatmap", "circlize", "ggrepel",
  "tidyverse", "ggpubr",  
  "NbClust", "variancePartition", "edgeR", 
  "BiocParallel", "argparse")
sapply(libs, library, character.only = TRUE, quietly = TRUE)

# RNA Library
script_path <- '/sc/arion/projects/LOAD/nextflow/rna_nf/R/RNA/R'
fs <- dir(script_path, "*.R", recursive = TRUE, full.names = TRUE)
fs <- fs[!grepl("old$|RNAClass\\.R|RNAConst\\.R", fs)]
nfs <- c(sapply(c('RNAClass.R', 'RNAConst.R'), function(f)file.path(script_path, f)), fs)
sapply(nfs, function(f, script_path)source(f))

parser <- ArgumentParser()
parser$add_argument("--starf", type = "character", required = TRUE,
                                          help = "the STAR read count file.")
parser$add_argument("--contrastf", type = "character", required = TRUE,
                                          help = "the contrast file")
parser$add_argument("--infof", type = "character", required = FALSE, 
					  default = "varPart_info.tsv",
                                          help = "the info file.")
parser$add_argument("--formf", type = "character", required = FALSE,
					  default = "dream_form.tsv",
                                          help = "the form file.")
parser$add_argument("--ncore", type = "integer", required = FALSE,
                                          help = "the number of cores provided.")
args <- parser$parse_args()
attach(args)

dout <- dirname(starf)

dat <- dream_all(starf, infof, formf, contrastf, dout, 
    protein.it = TRUE, ncore = ncore)

