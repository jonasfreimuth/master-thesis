**Simple diagram of deconvPure's process on non-representative, simulated data
from a normal distribution.** First, a bulk mixture is deconvoluted via
non-negative least squares and using a modified reference matrix. For normal
cell type deconvolution, the reference would contain average expression profiles
of all cell types, but here the expression profile for cancer cells is not
included. From the difference of bulk expression and the deconvolution model's
fitted values, residuals are then computed that highly correlate with the total
expression profile of cancer cells within the bulk.
