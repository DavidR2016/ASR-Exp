#!/bin/bash
# Author: Charl van Heerden (cvheerden@csir.co.za)
#
# This script increments the hmm index in one of two ways:
# (1) Given an index x:
#     - set HMM_PREV = x - 1
#     - set HMM_CURR  = x
#     - set HMM_NEXT     = x + 1
# (2) Given the flag 'auto_update', finds the hmm_dir (containing a model) with
#     the highest count (x). If found:
#     - set HMM_PREV = x - 1
#     - set HMM_CURR = x
#     - set HMM_NEXT = x + 1
#     If NOT found:
#     - set HMM_PREV = - 1
#     - set HMM_CURR  = 0
#     - set HMM_NEXT     = 1

FLAG=$1

EXPECTED_NUM_ARGS=1
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: source inc_hmm_cnt.sh <option> (NB: use source and not bash or ./)"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<option>" "customize hmm count update:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "auto_update " "- Finds the highest hmm model index (x) in model dir"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- ASSUMPTION: hmms saved as hmmDefs.mmf"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- If found:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " " * set (DIR_)HMM_PREV = x - 1"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " " * set (DIR_)HMM_CURR = x"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " " * set (DIR_)HMM_NEXT = x + 1"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- If no models found:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " " * set (DIR_)HMM_PREV = -1"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " " * set (DIR_)HMM_CURR =  0"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " " * set (DIR_)HMM_NEXT =  1"

  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "<integer>   " "- let k=integer"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " " * set (DIR_)HMM_PREV = k - 1"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " " * set (DIR_)HMM_CURR = k"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " " * set (DIR_)HMM_NEXT = k + 1"
  exit 1
fi

if [ $FLAG = 'auto_update' ]; then
  last_index=`find -L $DIR_EXP/models -iname "*.mmf" | sed 's/\/hmmDefs.mmf//g' | awk -F '_' '{print $NF}' | sort -n | tail -n 1`
  if [[ $last_index =~ ^[0-9]+$ ]]; then
    HMM_PREV=$(($last_index - 1))
    HMM_CURR=$last_index
    HMM_NEXT=$(($last_index + 1))
    echo "Setting HHM_PREV to: $HMM_PREV"
    echo "Setting HHM_CURR to: $HMM_CURR"
    echo "Setting HHM_NEXT to: $HMM_NEXT"
  else
    HMM_PREV=-1
    HMM_CURR=0
    HMM_NEXT=1
    echo "Setting HHM_PREV to: $HMM_PREV"
    echo "Setting HHM_CURR to: $HMM_CURR"
    echo "Setting HHM_NEXT to: $HMM_NEXT"
    # hmm_0 may not exist. Just make sure.
    mkdir -p $DIR_EXP/models/hmm_$HMM_CURR
  fi
fi

if [[ $FLAG =~ ^[0-9]+$ ]]; then
    HMM_PREV=$(($FLAG - 1))
    HMM_CURR=$FLAG
    HMM_NEXT=$(($FLAG + 1))
    echo "Setting HHM_PREV to: $HMM_PREV"
    echo "Setting HHM_CURR to: $HMM_CURR"
    echo "Setting HHM_NEXT to: $HMM_NEXT"
    # hmm_x may not exist. Just make sure.
    mkdir -p $DIR_EXP/models/hmm_$HMM_CURR
fi

if [ $FLAG != 'auto_update' ] && [[ ! $FLAG =~ ^[0-9]+$ ]]; then
  echo "ERROR: Invalid flag! Set to auto_update or an integer"
  exit 1
else
  export DIR_HMM_PREV=$DIR_EXP/models/hmm_$HMM_PREV
  export DIR_HMM_CURR=$DIR_EXP/models/hmm_$HMM_CURR
  export DIR_HMM_NEXT=$DIR_EXP/models/hmm_$HMM_NEXT
  mkdir -p $DIR_HMM_NEXT
fi
