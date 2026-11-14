# Paannotate for R

Paannotate imports gene-expression tables, compares expression across studies, and supports gene-set analysis. This source tree contains the data-free 1.0.4.9001 preview.

## Install

Open R or RStudio and paste the following into the console. Replace OWNER with the GitHub account or organization that hosts this repository.

```r
install.packages("remotes", repos = "https://cloud.r-project.org")
remotes::install_github("OWNER/paannotate-r", dependencies = FALSE, upgrade = "never")
library(paannotate)
pa_help()
```

For raw-count workflows, install edgeR through Bioconductor.

```r
install.packages("BiocManager", repos = "https://cloud.r-project.org")
BiocManager::install("edgeR", update = FALSE)
```

Use `pa_check_setup()` to check additional packages for features such as enrichment and Excel export. The standalone preview was tested on Apple silicon with R 4.4.1.

The source tree contains no Whiteley data, prebuilt Whiteley profiles or metadata dictionaries. Features that rely on those bundled resources need the applicable resources separately. Generic workflows accept user-supplied input files.
