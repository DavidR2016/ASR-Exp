#!/bin/bash

source Vars.sh

find $DIR_EXP/data/mfccs -iname "*.mfc" > $DIR_EXP/lists/audio_all.lst
find $DIR_EXP/data/proc_trans -iname "*.txt" > $DIR_EXP/lists/trans_all.lst

perl $DIR_ROOT/asr_template/utility_scripts/select_eval_set.pl $DIR_EXP/lists/audio_all.lst $DIR_EXP/lists/trans_all.lst 2 $DIR_EXP/lists
