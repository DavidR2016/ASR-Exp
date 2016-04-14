#!/bin/bash
# Author: Charl van Heerdern (cvheerden@csir.co.za)
#
# Does forced alignment given the latest models and saves the aligned mlf
# to results/aligned.mlf

LOCAL_LIST_MODELS=$1
LOCAL_MLF_REF=$2
LOCAL_LIST_AUDIO=$3
LOCAL_DICT=$4
LOCAL_MLF_RESULT=$5


EXPECTED_NUM_ARGS=5
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: ./forced_alignment.sh <model list> <reference mlf> <audio list> <dict>"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "model list    " "- List of physical hmms (usually tiedlist)"

  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "reference mlf " "- MLF to align to"

  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "audio list    " "- Text file with list of extracted feature files"
  
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "dict          " "- Pronunciation dictionary"

  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "alignment mlf " "- MLF to contain alignment result"
  exit 1
fi

# (1) Find the latest hmm (will be stored in DIR_HMM_CURR)
source $DIR_SRC/inc_hmm_cnt.sh auto_update

# (2) See if this model uses transforms
XFORM=""
for i in $(cat $DIR_HMM_CURR/hmmDefs.mmf | grep "XFORM" | awk '{print $2}' | sed 's/\"//g')
do
  XFORM="$TFORM -J "`dirname $i`
done

HVite -C $CFG_HVITE -A -D -T $TRACE_HVITE -V $PARAMS_ALIGN -b SIL-ENCE -l "*" -y lab -t 0.0 -o N -H $DIR_HMM_CURR/hmmDefs.mmf -H $DIR_HMM_CURR/macros $XFORM -S $LOCAL_LIST_AUDIO -I $LOCAL_MLF_REF -i $LOCAL_MLF_RESULT $LOCAL_DICT $LOCAL_LIST_MODELS
bash $DIR_SRC/check_exit_status.sh $0 $?
