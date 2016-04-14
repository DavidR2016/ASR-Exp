#!/bin/bash

if [ $# -lt 3 ]; then
	echo "Usage: $0 DIR_MFCCS DIR_TRANS DIR_LISTS"
	exit 1
fi

DIR_MFCCS=$1
DIR_TRANS=$2
DIR_LISTS=$3

find $DIR_MFCCS -iname "*.mfc" > $DIR_LISTS/audio_all.lst
find $DIR_TRANS -iname "*.txt" > $DIR_LISTS/trans_all.lst
