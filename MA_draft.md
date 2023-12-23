# Master thesis draft

## Introduction

Due to its relatively low cost, bulk RNA sequencing has seen widespread adoption
in clinical cancer studies [Hong et al., 2020]. However, a tumor tissue sample
comprises not only cancerous cells, but also others, like normal tissue cells
(possibly due to imprecision during the biopsy) or immune cells (like tumor
infiltrating lymphocytes). These cells constitute the tumor microenvironment,
whose influence on disease progression and treatment response is not yet
entirely understood. When sequencing tumor tissue samples, the transcripts
expressed in these non-tumor cells get incorporated into the expression data
[Li & Wang, 2021], which can represent confounding for downstream predictive
modeling taking the bulk RNA-seq data as input.

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

Li, X., Wang, CY. From bulk, single-cell to spatial RNA sequencing. _Int J Oral
Sci_ **13**, 36 (2021). <https://doi.org/10.1038/s41368-021-00146-0>
