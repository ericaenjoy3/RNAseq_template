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
parser$add_argument("--salmonf", type = "character", required = TRUE,
                                          help = "the salmon TPM file.")
parser$add_argument("--infof", type = "character", required = FALSE, 
                                          default = "varPart_info.tsv",
                                          help = "the info file.")
parser$add_argument("--formf", type = "character", required = FALSE,
                                          default = "varPart_form.tsv",
                                          help = "the form file.")
args <- parser$parse_args()
attach(args)

dout <- dirname(salmonf)

info <- fread(infof, header = TRUE)

dat <- fread(salmonf)
tpm.value <- as.matrix(dat[, -1, with = FALSE])
rownames(tpm.value) <- dat[, gene]
grps <- gsub("_\\d", "", colnames(tpm.value))
tpm.grp <- t(apply(tpm.value, 1, function(vec)tapply(vec, factor(grps, levels = unique(grps)), mean)))

tpm.obj <- new("tpm",
  tpm.value = tpm.value,
  tpm.grp = tpm.grp,
  grps = grps)

dat_pca <- PCAplot(tpm.obj,
  pdffout = file.path(dout,"gene_2DPCAplot.png"),
  fout = NULL, excl.col = NULL, ntop = Inf, isLog = FALSE, pcadim = 'None', small = 0.05)

dat_pca_top <- PCAplot(tpm.obj,
  pdffout = file.path(dout,"gene_2DPCAplot_top500.png"),
  fout = NULL, excl.col = NULL, ntop = 500, isLog = FALSE, pcadim = 'None', small = 0.05)

info_pca <- varPartInfo(info, list(dat_pca, dat_pca_top), fout = file.path(dirname(dout), 'data', 'varPart_info_pca.tsv'))

genefilter.obj <- rmLow(tpm.obj, thresh = 1)
genevar.obj <- rmNonVar(genefilter.obj, probs = 0.9)

varPart(genevar.obj, 
    info_pca, 
    formf, 
    dout,
    log2.it = TRUE, 
    small = 0.05)

