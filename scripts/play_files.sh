#!/bin/bash

if [ $# -lt 1 ]; then
 echo "usage: play_files.sh source_dir"
 exit
fi

for fn in `find $1/audio -iname "*.wav"`; do

#find $1/trans -iname "*.TXT"` 

play $fn

done
