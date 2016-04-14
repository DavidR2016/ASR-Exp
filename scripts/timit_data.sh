#!/bin/bash

#Author : Manaileng Mabu
#Email  : manailengmj@gmail.com
#Tell   : +27152682243
#Cell   : +27798595080

args=2

if [ $# -lt $args ]; then
 echo "usage: timit_data.sh source_dir destination_dir"
 echo "source_dir is the TIMIT directory"
 echo "destination_dir is the directory to store the audio and transcription files"
 exit
fi

src=$1
dst=$2

#=======================================
# Create necesary directories

for dir in $dst/data $dst/data/audio; do
 if [ ! -d $dir ]; then
  mkdir -p $dir
 fi
done
#======================================

num=0000
for fl in `find $src -iname "*.WAV"`; do
 expr $num = $num + 1
done

#cp $src/????/???/?????/*.WAV $dst/data/audio
#cp $src/?????/???/?????/*.WAV $dst/data/audio

#cp $src/????/???/?????/*.TXT $dst/data/trans
#cp $src/?????/???/?????/*.TXT $dst/data/trans
