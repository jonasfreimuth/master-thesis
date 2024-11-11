# Master Thesis Bioinformatics

This is the repo with all the source material for my bioinformatics master
thesis "Cancer Transcriptome Cleaning by Deconvolution".

You can find the submitted thesis `PDF` in the
[Final Thesis release](https://github.com/jonasfreimuth/master-thesis/releases/tag/final-thesis).

## Building the Document

### Quick start

If [Guix](https://guix.gnu.org/) is installed, building the document via
the `quick_start.sh` script is easy:

```sh
bash quick_start.sh
```

Otherwise, you need to ensure the packages defined in `manifest.scm` are
installed prior to running the quick start script.

### Manual Build

First, the archived run summary resources need to be unpacked:

```sh
tar -xzf "run_summary_archive.tar.gz"
```

Then, the the thesis document can be rendered using the `render_book.R`
script:

```sh
Rscript --vanilla render_book.R
```

That will output both an `PDF` and `HTML` version into the project
dir.

