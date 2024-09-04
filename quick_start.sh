#!/bin/bash

# check if guix is available
if command -v guix &> /dev/null
then
    manifest_path="./manifest.scm"
    channels_path="./channels.scm"

    echo "
Using guix environment created from $manifest_path & \
$channels_path..."
    
    guix time-machine -C "$channels_path" -- shell -m "$manifest_path" -- \
        Rscript --vanilla ./render_book.R
else
    echo "Using plain bash..."
    
    Rscript --vanilla ./render_book.R
fi