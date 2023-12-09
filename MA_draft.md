# Master thesis draft

## Introduction

* A lot of bulk expression data around
* Contains an unknown fraction of non-cancer expression
* If cancer expression and microenvironment expression could be separated, that’d be good
* Characterization of bulk as linear combination of average cell type expression
  plus varying levels of noise, technical and biological → Let’s do linear
  deconvolution!

## Materials / Methods

* Dataset by [Wu et. al](https://www.nature.com/articles/s41588-021-00911-1)
* Using scRNA data to construct a reference
* Simulation
  * For simulation data: Use a pseudo-bulks by summing scRNA expression of
    individual tumors
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
* Verification
  * Using all available BRCA project data from TCGA (ver. 1.30.4 INCLUDE
    `MANIFEST.txt`)
  * Using STAR count data
    * Using sums of counts per `gene_name`!
    * _Some sort of normalization_ + log + scale
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

* Simulation
  * Generally good correlation, but little difference between split and no
    split,
  * Correlation seems to be driven by inherent correlation between cell-type
    expression & bulk expression, with residuals generally following bulk
    expression patterns.
* Validation
  * Sometimes residuals better, sometimes bulk better, generally ~70%
    accuracy.

## Discussion

* Simulation
  * Issue of correlation between bulk expression & cancer expression
  * Deconvolution residuals just replicate the association -> no difference in
    cancer splitting and therefore no improvement over using bulk RNA
    sequencing to be expected.

## Introduction

Due to its relatively low cost, bulk RNA sequencing has seen widespread adoption
in clinical cancer studies [Hong et al., 2020]. However, a tumor tissue sample
comprises not only cancerous cells, but also others, like normal tissue cells
(possibly due to imprecision during the biopsy) or immune cells (like tumor
infiltrating lymphocytes). These cells constitute the tumor microenvironment,
whose influence on disease progression and treatment response is not yet
entirely understood. When sequencing tumor tissue samples, the transcripts
expressed in these non-tumor cells get incorporated into the expression data,
which can represent confounding for downstream predictive modeling taking the
bulk RNA-seq data as input.

[Deal with whether the expression contains information useful for downstream prediction tasks]

Cell type deconvolution already exists as a way to estimate the cell-type
proportion. One of the basic approaches consists of solving a system of linear
equations, minimizing the euclidean [check this] distance between the transcript
predictions and the bulk data. Under the assumption that cancer cells vary
stronger in their expression than the other cells in the microenvironment, we
can expect the residuals to contain much of this excess variation, thus
representing a way to “clean” the bulk cancer expression of the expression of
non-cancer cells. This method requires average expression profiles.

* Average expression profiles derived from scRNA-seq data
* Issue of increasing distance between actual cell expression and average
  expression profile.
* A way to possibly “boost” the signal of pure cancer expression, would be to
  not include the cancer cell type in the reference. This would of course
  decrease the accuracy of the deconvolution model for predicting cell type
  proportions, but would in theory increase the variance in expression due to
  cancer cells that is not explained by the model, and which would therefore end
  up in the residuals. [I think however that it’s not straightforward which
  portions end up in the residuals. There is still a fraction of each expression
  which gets “misattributed” to another cell type, but which counts as accounted
  for and thus is not present in the residuals.]

Research questions:

* Can the residuals from basic linear deconvolution methods be used to infer
  information about the tumor and inform treatment?
* Are the residuals gathered this way superior to using plain bulk data?
* Is there a difference [what sort?] in the usefulness of the residuals when the
  cancer reference is not included?

## Methods


## References

Shalek AK, Satija R, Adiconis X, Gertner RS, Gaublomme JT, Raychowd‑ hury R, et
al. Single‑cell transcriptomics reveals bimodality in expressionand splicing in
immune cells. Nature. 2013;498:236–40.

Pan Y, Lu F, Fei Q, Yu X, Xiong P, Yu X, et al. Single‑cell RNA
sequencingreveals compartmental remodeling of tumor‑infiltrating immune
cellsinduced by anti‑CD47 targeting in pancreatic cancer. J Hematol Oncol.
2019;12:124.

Macosko EZ, Basu A, Satija R, Nemesh J, Shekhar K, Goldman M, et al. Highly
parallel genome‑wide expression profiling of individual cells using nanoliter
droplets. Cell. 2015;161:1202–14.

[TO IMPORT]

Li, X., Wang, CY. From bulk, single-cell to spatial RNA sequencing. _Int J Oral
Sci_ **13**, 36 (2021). <https://doi.org/10.1038/s41368-021-00146-0>
