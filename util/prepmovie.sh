#!/bin/bash
echo $PWD
`cd /home/caps/lab/movie/$1`
echo $PWD
read
for f in *png; do
  mv "$f" "${f%??????????????}png"
done
