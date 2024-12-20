#!/bin/bash

# pdftotext is a part of Xpdf command line tools: https://www.xpdfreader.com/download.html

function extract_issue() {
  issue_name=felix_$1
  if [ ! -e "$pdf_root/$issue_name.pdf" ]; then
    return 1
  fi
  dest="$output_dir/$1/"
  mkdir -p $dest

  echo "extracting Issue $1"
  pdftotext -raw "$pdf_root/$issue_name.pdf" "$dest/$issue_name.txt" || exit

  cd $dest || exit
  awk '{i++}length {print > i".txt"}' RS='\f' $issue_name.txt
  rm -f $issue_name.txt
  cd ~- || exit
}

function extract_range(){
  start=$1
  finish=$2
  seq $start $finish | parallel -j "$(nproc)" extract_issue
}

pdf_root="${3:-./}"
output_dir="${4:-text/}"

mkdir -p $output_dir

export -f extract_issue
export pdf_root output_dir

extract_range $1 $2
