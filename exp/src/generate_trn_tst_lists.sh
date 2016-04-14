#!/bin/bash

source Vars.sh

NUM=$1
C=0

echo "$0: generating train and test lists"
echo "creating audio list"
for ln in `ls $DIR_EXP/data/mfccs/*.mfc`; do
	if [ $C -le $NUM ]; then
		echo $ln >> $DIR_EXP/lists/audio_trn.lst
	else
		echo $ln >> $DIR_EXP/lists/audio_eval.lst
	fi
	C=$(expr $C + 1)
done

echo "creating trans list"
C=0

for ln in `ls $DIR_EXP/data/proc_trans/*.txt`; do
	if [ $C -le $NUM ]; then
		echo $ln >> $DIR_EXP/lists/trans_trn.lst
	else
		echo $ln >> $DIR_EXP/lists/trans_eval.lst
	fi
	C=$(expr $C + 1)
done

