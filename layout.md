# Title

## Introduction

* A lot of bulk expression data around
* Contains an unknown fraction of non-cancer expression
* If cancer expression and microenvironment expression could be separated,
  that’d be good
* Characterization of bulk as linear combination of average cell type expression
  plus varying levels of noise, technical and biological → Let’s do linear
  deconvolution!

## Materials / Methods

### Data

* Dataset by [Wu et. al](https://www.nature.com/articles/s41588-021-00911-1)
* Using all available BRCA project data from TCGA (ver. 1.30.4 INCLUDE
  `MANIFEST.txt`)
  * Using STAR count data
    * Using sums of counts per `gene_name`!
    * _Some sort of normalization_ + log + scale

### General workflow

1. Reference construction
1. Deconvolution

### Random simulation

### scRNA-seq based simulation

* Use a pseudo-bulks by summing scRNA expression of individual tumors
* Details
  * scRNA data log-normed with scuttle
  * Reference
    * Averaging of cell expression belonging to one cell type
    * Marker selection (Probably only necessary for saving on resources)?
  * Pseudobulk
    * Summing up all transcripts of a sample (Using log-normed counts! Done
      because there is an inherent disconnect between scRNA-seq derived
      pseudobulk data and actual bulk RNA-seq data, due to drop-outs, etc.
      Therefore, this represents the best case for accuracy.)
  * Deconvolution
    * Using nnls (Simple)
    * Using
      * summed log norm counts for the pseudobulk
      * averaged log norm counts for the reference
    * Transcript predictions computed (Deconvoluted cell type prop * reference
      matrix)
    * Residuals computed as pseudobulk expression - transcript predictions
      (both min-max transformed, as they are not on the same scale due to the
      sum vs averaging methodology)
      * absolute values (they are supposed to be a measure for bulk
        expression, and so can’t be negative. It’s about the deviation, the
        sign is not relevant)
      * Adaptive log normalization procedure (Residuals are of a weird
        distribution WHY?)
    * Correlations computed (bulk expr - cancer expr as baseline, bulk expr -
      residuals as diagnosis, cancer expr - residuals as analysis)
      * All correlates also adaptive log transformed in the same way

### Verification

* Deconvolving with _some sort of_ reference
  * Using nnls
  * Only intersect of transcripts (`gene_name`) between reference and bulk
* Calculating transcript predictions
  * Reference * cell type prop predictions
  * Reference adaptive log transformed (see section on simulation)
    * Transcript predictions are scaled (Need to be on the same scale as bulk
      expression)
* Calculating residuals
  * Bulk expression - transcript predictions
* Residuals qc plots
  * Bulk expression v transcript prediction plot
  * Bulk expression v residuals plot
* Model training
  * Currently PAM50 subtype is predicted
  * Using bulk and split and no-split residuals as predictors
  * Doing UMAP as pre-training qc
    * Currently not looking good, barely any separation.
  * Doing heatmaps separated between classes
    * Can’t really say anything, except classes don’t look much different
  * Doing repeated cross-validation (4-fold, 10 repeats, SMOTE up-sampling)
  * Training SVM, linear kernel

## Results

### Random simulation

![metric_summary_plot](./cancer-cleaning-output/notebook/random_deconv_exploration_output/metric_summary_plot.png)  
*Analysis of the deconvolution results. Each subplot represents a combination of
relative biological noise level (first line per column), bulk model (second line
per column), and reference type (row). For each combination, the root mean
squared error (RMSE) or R² value is given in the top right corner. A: Average
root mean squared error (RMSE) between true cell type abundances and abundances
predicted by the deconvolution model. B: Average R² values of simulated bulk
gene expression with fitted values of the deconvolution model. C: Average R²
values of simulated bulk gene expression with residual values of the
deconvolution model. D: Average R² values of simulated cancer cell type gene
expression with residual values of the deconvolution model.*

### scRNA-seq based simulation

* Generally good correlation, but little difference between split and no split
* Correlation seems to be driven by inherent correlation between cell-type
  expression & bulk expression, with residuals generally following bulk
  expression patterns.

### Verification

* Sometimes residuals better, sometimes bulk better, generally ~70% accuracy.

## Discussion

### Random simulation

### scRNA-seq based simulation

* Issue of correlation between bulk expression & cancer expression
* Deconvolution residuals just replicate the association -> no difference in
  cancer splitting and therefore no improvement over using bulk RNA sequencing
  to be expected.

### Verification

### Outlook

* Might be sensible to try more advanced deconvolution approaches, i.e. SQUID
  (Cobos, Panah, et al. 2023)

## Supplementary plots

### Random simulation

![ground_truth_plot](./cancer-cleaning-output/notebook/random_deconv_exploration_output/ground_truth_plot.png)  
*Exploration of a randomly picked example of the generated ground truth data per
parameter noise ratio. A: Boxplot of per cell type reference expression by
relative biological noise level. B: Boxplot of per ground truth type bulk
expression by relative biological noise level. C: Relationship of cancer
expression to total bulk expression by relative biological noise level.*

![analysis_plot](./cancer-cleaning-output/notebook/random_deconv_exploration_output/analysis_plot.png)  
*Analysis of a randomly picked example of the deconvolution results. Each
subplot represents a combination of relative biological noise level (first line
per column), bulk model (second line per column), and reference type (row). For
each combination, the root mean squared error (RMSE) or R² value is given in the
top right corner. A: Actual versus predicted cell type abundances. B: Boxplot of
the deconvolution model residuals. C: Simulated bulk gene expression vs. fitted
values of the deconvolution model. D: Simulated bulk gene expression vs.
residuals of the deconvolution model. E: Simulated cancer cell type gene
expression vs. residuals of the deconvolution model.*

### scRNA-seq based simulation

### Verification
