# Paannotate for R

Paannotate imports gene-expression tables, compares expression across studies, and supports gene-set analysis. This source tree contains the data-free 1.0.4.9001 preview.

## Install
Download the tar.gz file (the only other file in this repo). Know where on your computer it is.


```r
install.packages("path/to/where/the/tar.gz/file/is/on/your/computer/paannotate_1.0.4.tar.gz", repos=NULL, type="source")
install.packages(c("BiocManager", "readxl", "openxlsx", "pheatmap", "yaml"))
BiocManager::install(c("edgeR", "limma", "fgsea", "goseq"))


```
library(paannotate)

