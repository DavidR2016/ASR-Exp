#!/bin/bash
# Author: Charl van Heerden (cvheerden@csir.co.za)
#
# This is a light-weight wrapper around HERest
# Requires:
# - phone list
# - mlf
# - number of iterations

LOCAL_PHN_LST=$1
LOCAL_MLF=$2
LOCAL_NUM_ITERATIONS=$3

EXPECTED_NUM_ARGS=3
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: bash herest.sh <option>"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<option>" "3 options have to be provided:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "phone list      " "- Listing all models to be re-estimated"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "mlf             " "- MLF containing transcriptions of audio files (corresponding to phone list)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "num iterations  " "- Number of re-estimations to be done"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "extras(optional)" "- Any additional arguments can be passed as a single 4th variable"
  exit 1
fi

while [ $LOCAL_NUM_ITERATIONS -gt 0 ]; do
  source $DIR_SRC/inc_hmm_cnt.sh auto_update
  # (2) See if this model uses transforms
  XFORM=""
  for i in $(cat $DIR_HMM_CURR/hmmDefs.mmf | grep "XFORM" | awk '{print $2}' | sed 's/\"//g' | xargs -I {} basename {})
  do
    ADD=`find $DIR_EXP/models -iname "$i"`
    XFORM="$XFORM -J "`dirname $ADD`
  done

  if [ $NUM_HEREST_PROCS -eq 1 ]; then
    HERest -A -D -T 1 -V -S $LIST_AUDIO_TRN -I $LOCAL_MLF -t $HEREST_PRUNE -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf $XFORM -M $DIR_HMM_NEXT -s $STATS $LOCAL_PHN_LST
    bash $DIR_SRC/check_exit_status.sh $0 $?
  else
    cd $DIR_SCRATCH
    mkdir -p herest_lists
    cd herest_lists
    rm *
    perl $DIR_SRC/split.pl $LIST_AUDIO_TRN $NUM_HEREST_PROCS $DIR_SCRATCH/herest_lists
    #split -l $NUM_MFCS_PER_PROC $LIST_AUDIO_TRN
    cnt=1
    for list in `ls *`
    do
      HERest -A -D -T 1 -V -p $cnt -S $list -I $LOCAL_MLF -t $HEREST_PRUNE -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf $XFORM -M $DIR_HMM_NEXT -s $STATS $LOCAL_PHN_LST 2>1 > log.$cnt &
      cnt=$(($cnt + 1))
    done
    #while [ `ls $DIR_HMM_NEXT/*.acc | wc -l` -lt $NUM_HEREST_PROCS ]; do sleep 5; done
    # TODO: confirm that this works as expected
    wait
    bash $DIR_SRC/check_exit_status.sh $0 $?

    acc_files=""
    for acc in `ls $DIR_HMM_NEXT/*.acc`
    do
      acc_files="$acc_files $acc"
    done
    cat log.*
    HERest -A -D -T 1 -V -p 0 -I $LOCAL_MLF -t $HEREST_PRUNE -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf $XFORM -M $DIR_HMM_NEXT -s $STATS $LOCAL_PHN_LST $acc_files
    bash $DIR_SRC/check_exit_status.sh $0 $?
    rm $DIR_HMM_NEXT/*.acc
  fi
  LOCAL_NUM_ITERATIONS=$(($LOCAL_NUM_ITERATIONS-1))
done
