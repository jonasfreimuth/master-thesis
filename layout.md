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

* sc RNA-seq: Dataset by
  [Wu et. al](https://www.nature.com/articles/s41588-021-00911-1)
* Clinical data: Using all available BRCA project data from TCGA (ver. 1.30.4
  INCLUDE `MANIFEST.txt`)
  * Using STAR count data
    * Using sums of counts per `gene_name`!
    * Raw counts, FPKM (upper-quartile norm'd)
    * Optionally log + scaled
* Survival data: TCGA-BRCA derived survival endpoints from
  [Liu et al.](https://doi.org/10.1016/j.cell.2018.02.052)

### General workflow

1. Reference construction
1. Deconvolution

### Random simulation

### scRNA-seq based simulation

* Normalizing the reference and bulk probably not necessary for `nnls`
  * See Cobos et al. (2023) Fig. 3.

* Use a pseudo-bulks by summing scRNA expression of individual tumors
* Details
  * scRNA data log-normed with scuttle

  * Reference
    * Averaging of cell expression belonging to one cell type
    * Marker selection
      * Using wilcox test
        * via Seurat (v5.0.1)
        * using `Presto` implementation
        * previous normalization via `NormalizeData`, method relative counts
          (`RC`)
        * Using bonferroni method for p-value adjustment
        * Cutoff: Adjusted p-value under 0.05
      * Outlier distance (similar to Hampel filter)
        * Gene is defined as a marker for a cell type if its expression is more
          than three median absolute deviations away from the median _average_
          expression (i.e. this runs on the reference matrix)
        * No scaling constant (We can't assume normality, this is just
          arbitrary)
      * Using random genes as markers
        * Cutoff: None, at threshold 1 all genes are used.

  * Pseudobulk
    * Summing up all transcripts of a sample (Using log-normed counts! Done
      because there is an inherent disconnect between scRNA-seq derived
      pseudobulk data and actual bulk RNA-seq data, due to drop-outs, etc.
      Therefore, this represents the best case for accuracy.)

  * Deconvolution
    * Using nnls (Simple)
    * Using
      * summed log norm counts for the pseudobulk
      * averaged counts for the reference
    * Transcript predictions computed (Deconvoluted cell type abundance *
      reference matrix)
    * Residuals computed as pseudobulk expression - transcript predictions
      * absolute values (they are supposed to be a measure for bulk
        expression, and so can’t be negative. It’s about the deviation, the
        sign is not relevant)
    * Correlations computed
      * bulk expr vs. cancer expr: baseline
      * bulk expr vs. residuals: diagnosis
      * cancer expr vs. residuals: analysis
      * All correlates log transformed

### Verification

#### Prediction of an intrinsic categorical variable

* PAM50 subtype
* Performing same deconvolution procedure as during pseudobulk simulation ->
  obtaining residuals as training data
* Model training
  * Using TCGA bulk data and residuals (derived from references including and
    not including cancer) as predictors
    * [Dimensions of training data]
    * Filtered to only include "Primary solid Tumor" samples
  * Doing repeated cross-validation (4-fold, 10 repeats, SMOTE up-sampling)
  * Pre-processing: Decorrelation via PCA, excluding zero variance genes
  * Training SVM, linear kernel
* Using model accuracy [what exactly] to assess performance

#### Prediction of a clinical variable

* Progression free interval [Why?]
* Training random survival forests
* Using same sample data as in previous section but filtered to fit survival
  data
  * Filtered to only include "Primary solid Tumor" samples
  * Using unique samples (Multiple tumor samples from the same patient are
    present in the TCGA data.)
* Tuning model for best out-of-sample error using fast survival forest fitting
  via sub-sampling.
  * Using 200 trees
* Using optimal parameters to fit a full model.
* Using reported Harrell's C (1 - model error) to assess performance.

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
