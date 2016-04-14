#!/bin/bash
# Author: Charl van Heerden (cvheerden@csir.co.za)
# 
# This script will call others scripts to perform phone or word recognition
# given a trained ASR system
#
# IMPORTANT:
#  - set ALL variables in Vars.sh
#  - make sure you have audio and transcription trn+tst lists
#  - make sure you have a valid pronunciation dictionary
#  - do ./CHECK.sh all_phases to test your setup

source Vars.sh

FLAG=$1

#==============================================================================
# Check that the number of arguments are correct
#==============================================================================
EXPECTED_NUM_ARGS=1
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: ./TEST.sh <flag>"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<option>" "customize evaluation:"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "phone_rec       " "- Do phoneme recognition"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "word_rec_hvite  " "- Do word recognition using HTK"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "word_rec_juicer " "- Do word recognition using Juicer"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "phone_results   " "- Uses hresults to calculate accuracy"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "word_results    " "- Uses hresults to calculate accuracy"

  exit $E_BAD_ARGS
fi

#==============================================================================
# Some Basic checks
#==============================================================================
if [ ! -d $DIR_SRC ]; then
  echo -e "ERROR: Please set <DIR_SRC> in Vars.sh to valid directory"
  exit 1 
fi

if [ ! -d $DIR_EXP ]; then
  echo "ERROR: $DIR_EXP MUST exist. Exiting!"
  exit 1;
fi

#==============================================================================
# DO PHONE RECOGNITION
#==============================================================================
if [ $FLAG = 'phone_rec' ]; then
  echo "TEST: Starting phone recognition"
  bash $DIR_SRC/phone_recognition.sh
fi

#==============================================================================
# DO WORD RECOGNITION USING HVITE
#==============================================================================
if [ $FLAG = 'word_rec_hvite' ]; then
  echo "TEST: Starting word recognition using HTK"
  bash $DIR_SRC/word_recognition.sh
fi

#==============================================================================
# DO WORD RECOGNITION USING JUICER
#==============================================================================
if [ $FLAG = 'word_rec_juicer' ]; then
  echo "TEST: Starting word recognition using Juicer"
  bash $DIR_SRC/word_recognition_juicer.sh
fi

#==============================================================================
# PHONE HRESULTS
#==============================================================================
if [ $FLAG = 'phone_results' ]; then
  echo "TEST: Starting word recognition"
  HResults -A -D -T 1 -V -s -p -z sil -I $MLF_PHNS_TST $LIST_MONOPHNS $DIR_EXP/results/test_results.mlf
fi

#==============================================================================
# WORD HRESULTS (-p off, since conf matrix would be too large)
#==============================================================================
if [ $FLAG = 'word_results' ]; then
  echo "TEST: Starting word recognition"
  HResults -A -D -T 1 -V -s -z sil -I $MLF_WORDS_TST $LIST_WORDS_TRN $DIR_EXP/results/test_results.mlf
fi
