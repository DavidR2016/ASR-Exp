#!/bin/bash
# Author: Charl van Heerden (cvheerden@csir.co.za)
#
# This is a light-weight wrapper around HVite
# Requires:
# - mfc list
# - num procs

if [ ! -f Vars.sh ]; then
  echo ""
  echo "This does not seem to be an existing experiment! Read the instructions!"
  echo ""
else
  source Vars.sh
fi

EXPECTED_NUM_ARGS=2
E_BAD_ARGS=65

if [ $# -lt $EXPECTED_NUM_ARGS ] || [ ! -f Vars.sh ]; then
  echo "Usage: bash hvite_parallel.sh <list_audio> <num procs> (<grammar> <dict>)"
  echo ""
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "NB: TO BE USED WITHIN AN EXISTING EXPERIMENT!!!"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo ""
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "list_audio      " "- List of mfcc files to be decoded"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "num_procs       " "- Number of processes to spawn"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "                " ""

  echo "Description: Splits the provided 'list_audio' into 'num_procs' hvite processes. Results and lists"
  echo "             are created in $DIR_SCRATCH/hvite_parallel. To create complete mlf, simply do:"
  echo "             cat $DIR_SCRATCH/hvite_parallel/*.mlf > $DIR_EXP/results/some_random_name.mlf"
  echo ""
  echo "             Default behaviour is to do phone recognition. To do word recognition, provide a "
  echo "             grammar and dictionary (for phone rec, a flat grammar is created)."
  echo ""
  exit $E_BAD_ARGS
fi

LOCAL_LIST_AUDIO=$1
NUM_PROCS=$2
LOCAL_GRAMMAR=""
LOCAL_DICT=""
THIS_EXPECTED_NUM_ARGS=$EXPECTED_NUM_ARGS

if [ $# -gt $EXPECTED_NUM_ARGS ]; then
  LOCAL_GRAMMAR=$3
  LOCAL_DICT=$4
fi

source $DIR_SRC/inc_hmm_cnt.sh auto_update
# See if this model uses transforms
XFORM=""
  for i in $(cat $DIR_HMM_CURR/hmmDefs.mmf | grep "XFORM" | awk '{print $2}' | sed 's/\"//g' | xargs -I {} basename {})
  do
    ADD=`find -L $DIR_EXP/models -iname "$i"`
    XFORM="$XFORM -J "`dirname $ADD`
  done

echo "Num args: '$#' : '$THIS_EXPECTED_NUM_ARGS'"
if [ $# -eq $THIS_EXPECTED_NUM_ARGS ]; then
  # Create a phn loop grammar
  echo "Creating loop grammar"
  bash $DIR_SRC/loop_grammar.sh $LIST_MONOPHNS

  # Create a monophone dictionary (ph ph)
  cat $LIST_MONOPHNS | sed '/sp/d' | awk '{print $1 "\t" $1}' > $DIR_SCRATCH/mono.dict.tmp
  echo -e "$SENTSTART sil\n$SENTEND sil" >> $DIR_SCRATCH/mono.dict.tmp
  cat $DIR_SCRATCH/mono.dict.tmp | sort -u > $DIR_EXP/dictionaries/mono.decode.dict
  rm $DIR_SCRATCH/mono.dict.tmp
  LOCAL_DICT=$DIR_EXP/dictionaries/mono.decode.dict
  LOCAL_GRAMMAR=$GRAMMAR
  echo "Created dict at $LOCAL_DICT"
fi

source $DIR_SRC/inc_hmm_cnt.sh auto_update
cd $DIR_SCRATCH
mkdir -p hvite_parallel
rm hvite_parallel/*
cd hvite_parallel
perl $DIR_SRC/split.pl $LOCAL_LIST_AUDIO $NUM_PROCS $DIR_SCRATCH/hvite_parallel
cnt=1
for list in `ls *`
do
  result=$cnt.mlf
  /usr/bin/time --portability --output=hvite.$cnt.time.log HVite -C $CFG_HVITE -A -D -T 1 -V -H $DIR_HMM_CURR/hmmDefs.mmf -H $DIR_HMM_CURR/macros $XFORM -S $list -t $MAINBEAM -i $DIR_SCRATCH/hvite_parallel/$cnt.mlf -w $LOCAL_GRAMMAR -o N -p $INS_PENALTY -s $GRAMMAR_SCALE $LOCAL_DICT $LIST_TIED 2>&1 > hvite.$cnt.log &
  cnt=$(($cnt + 1))
done
