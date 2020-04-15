#!/bin/bash
echo $PWD
cd "/home/caps/lab/movie/$1"
echo $PWD
read
files=$PWD/*png
for f in $files; do
  mv "$f" "$PWD/${f%??????????????}png"
done
