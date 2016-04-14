#!/bin/bash
# Author: Charl van Heerdern (cvheerden@csir.co.za)

LOCAL_NUM_ITERATIONS=$NUM_MIXES

while [ $LOCAL_NUM_ITERATIONS -gt 1 ]; do # -gt 1, because we already have one mixture
  LOCAL_NUM_ITERATIONS=$(($LOCAL_NUM_ITERATIONS-1))
#==============================================================================
# Increment the mixtures
#==============================================================================
# Make sure the hmm dirs are up to date
  source $DIR_SRC/inc_hmm_cnt.sh auto_update
  HHEd -A -D -T 1 -V -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -M $DIR_HMM_NEXT $HED_MIX_INC $LIST_TIED
  bash $DIR_SRC/check_exit_status.sh $0 $?

#==============================================================================
# Re-estimate twice
#==============================================================================
# ./herest.sh <model list> <trn mlf> <num re-estimations>
  bash $DIR_SRC/herest.sh $LIST_TIED $MLF_TRIPHNS_TRN 2
  bash $DIR_SRC/check_exit_status.sh $0 $?
done

