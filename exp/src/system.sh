#!/bin/bash

# script to run IsiNdebele ASR
ROOT_DIR=~/asr
MAIN_DIR1=$ROOT_DIR
ASR_SCRIPTS=$ROOT_DIR/asr_template

source Vars.sh

FEAT=1
PREPROC=1
DO_LISTS=1
DO_CHECK=1
DO_TRAIN=0
DO_EVAL=0

#---------------------------------------------------------
# Create necessary directories !!

for dir in  $DIR_EXP/data $DIR_EXP/data/mfccs $DIR_EXP/log $DIR_EXP/data/proc_trans $DIR_EXP/lists/; do
  if [ ! -d $dir ]; then
     mkdir -p $dir
  fi
done

#--------------------------------------------------------------------
if [ $FEAT == 1 ]; then
    echo ""
    echo "FEATURE EXTRACTION"
    #Do feture extraction normal way
    echo "creating hcopylist.lst"
    date >> $DIR_EXP/log/time.feat
    perl $ASR_SCRIPTS/utility_scripts/create_hcopy_lists.pl $MAIN_DIR1/data/audio $DIR_EXP/data/mfccs $DIR_EXP/lists/hcopylist.lst
    cd $DIR_EXP/src
    echo "running: CMVN.sh cmvn"
    bash CMVN.sh cmvn $DIR_EXP/lists/hcopylist.lst >& $DIR_EXP/log/feature.log
    date >> $DIR_EXP/log/time.feat
fi

#---------------------------------------------------------------

if [ $PREPROC == 1 ]; then
    echo ""
    echo "PREPROCESSING"
    #Do transcription preprocessing normal way
    echo "creating preproclist.lst"
    date >> $DIR_EXP/log/time.pre
    perl $ASR_SCRIPTS/utility_scripts/create_preproc_lists.pl $MAIN_DIR1/data/trans $DIR_EXP/data/proc_trans $DIR_EXP/lists/preproclist.lst
    cd $DIR_EXP/src
    echo "running: PREPROC.sh"
    bash PREPROC.sh $DIR_EXP/lists/preproclist.lst all_phases >& $DIR_EXP/log/preproc.log
    date >> $DIR_EXP/log/time.pre
fi
#---------------------------------------------------------------------

if [ $DO_LISTS == 1 ]; then
    echo "Generating train and test lists"
    date >> $DIR_EXP/log/time.lists
    bash generate_trn_tst_lists.sh 4511
    date >> $DIR_EXP/log/time.lists
fi

#-----------------------------------------------------------------------------
if [ $DO_CHECK == 1 ]; then
    echo ""
    echo "CHECKING"
    cd $DIR_EXP/src
    echo "running: CHECK.sh all_phases"
    date >> $DIR_EXP/log/time.check
    bash CHECK.sh all_phases >& $DIR_EXP/log/check.log
    date >> $DIR_EXP/log/time.check
fi

#-----------------------------------------------------------------------
if [ $DO_TRAIN == 1 ]; then
    echo ""
    echo "TRAINING"
    cd $DIR_EXP/src
    echo "running: TRAIN.sh"
    date >> $DIR_EXP/log/time.train
    bash TRAIN.sh all_phases >& $DIR_EXP/log/train.log
    echo "running: TRAIN.sh semitied"
    bash TRAIN.sh semitied >& $DIR_EXP/log/semitied.log
    date >> $DIR_EXP/log/time.train
fi
#------------------------------------------------------------------------
if [ $DO_EVAL == 1 ]; then
    echo ""
    echo "EVALUATION"
    cd $DIR_EXP/src
    echo "running: TEST.sh phone_rec"
    date >> $DIR_EXP/log/time.test
    bash TEST.sh phone_rec >& $DIR_EXP/log/test_$MAINBEAM.phone.log
    echo "running: TEST.sh word_rec_hvite"
    bash TEST.sh word_rec_hvite >& $DIR_EXP/log/test_$MAINBEAM.word.log
    echo "running: TEST.sh phones_results"
    bash TEST.sh phone_results >& $DIR_EXP/log/test_$MAINBEAM.results.phones.log
    echo "running: TEST.sh words_results"
    bash TEST.sh word_results >& $DIR_EXP/log/test_$MAINBEAM.results.words.log
    date >> $DIR_EXP/log/time.test
    
    #Do it again
    echo "running: TEST.sh phone_rec #2"
    bash TEST.sh phone_rec >& $DIR_EXP/log/test_$MAINBEAM.phone.log
    echo "running: TEST.sh phones_results #2"
    bash TEST.sh phone_results >& $DIR_EXP/log/test_$MAINBEAM.results.phones.log

fi
#-----------------------------------------------------------------------
echo "DONE."
#------------------------------------------------------------------------
