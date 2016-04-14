#!/bin/bash

#Author : Manaileng Mabu
#Email  : manailengmj@gmail.com
#Tell   : +27152682243
#Cell   : +27798595080

src=$1

num=1

for fl in `find $src -iname "*.WAV"`; do
 #$num=$num+1
 #expr $num   = $num + 1

 basename $fl
done
