#!/usr/bin/env bash

function sort_bibfile {
    local tmp_file=$(mktemp)
    bibtool -s $1 > "$tmp_file" && mv "$tmp_file" "$1"
}

sort_bibfile $1