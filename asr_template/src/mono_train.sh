#!/bin/bash
# Author: Neil Kleynhans (ntkleynhans@csir.co.za)
#         Charl van Heerden (cvheerden@csir.co.za)

#==============================================================================
# Setup environment
# Assumption: You start at hmm_0
#==============================================================================

#==============================================================================
# Use raw proto MMF to set means & variances using HCompV
#==============================================================================

echo "INFO ($0): Estimating initial HMM parameters"

source $DIR_SRC/inc_hmm_cnt.sh auto_update

shuf $LIST_AUDIO_TRN | head -n $NUM_FILES_HCOMPV > $DIR_SCRATCH/hcompv.lst
HCompV -T $TRACE -C $CFG_HCOMPV -S $DIR_SCRATCH/hcompv.lst -m -f $VFLOORS_SCALE -M $DIR_HMM_CURR $PROTO_RAW
bash $DIR_SRC/check_exit_status.sh $0 $?

#==============================================================================
# Use proto file (output previous step) to clone monophone models
#==============================================================================

echo "INFO ($0): Cloning monophone HMMs"

bash $DIR_SRC/create_init_models.sh
bash $DIR_SRC/check_exit_status.sh $0 $?

#==============================================================================
# Using the initial hmmDefs.mmf & macros files, perform 3 re-estimations
#==============================================================================

echo "INFO ($0): Re-estimating HMM parameters (3 iterations)"

bash $DIR_SRC/herest.sh $LIST_MONOPHNS $MLF_PHNS_TRN 3
bash $DIR_SRC/check_exit_status.sh $0 $?

#==============================================================================
# Insert 3 state "sp" model
#==============================================================================

echo "INFO ($0): Creating SP HMM"

source $DIR_SRC/inc_hmm_cnt.sh auto_update

cp $DIR_HMM_CURR/hmmDefs.mmf $DIR_HMM_NEXT
cp $DIR_HMM_CURR/macros $DIR_HMM_NEXT

perl $DIR_SRC/makesp.pl $DIR_HMM_CURR/hmmDefs.mmf >> $DIR_HMM_NEXT/hmmDefs.mmf
bash $DIR_SRC/check_exit_status.sh $0 $?

#==============================================================================
# Tying "sp" and "sil" center states
#==============================================================================

echo "INFO ($0): Tying SP and SIL HMM center states"

source $DIR_SRC/inc_hmm_cnt.sh auto_update

HHEd -T $TRACE -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -M $DIR_HMM_NEXT $HED_SIL $LIST_MONOPHNS_SP
bash $DIR_SRC/check_exit_status.sh $0 $?

source $DIR_SRC/inc_hmm_cnt.sh auto_update

#==============================================================================
# Using the current hmmDefs.mmf & macros files, perform 2 re-estimations
#==============================================================================

echo "INFO ($0): Re-estimating HMM parameters (2 iterations)"

bash $DIR_SRC/herest.sh $LIST_MONOPHNS_SP $MLF_PHNS_SP_TRN 2
bash $DIR_SRC/check_exit_status.sh $0 $?

#==============================================================================
# Use models to realign and select best pronunciation for training
#==============================================================================

echo "INFO ($0): ReAlign training data"

source $DIR_SRC/inc_hmm_cnt.sh auto_update

if [ $NUM_HEREST_PROCS -eq 1 ]; then
  HVite -T 1 -l '*' -o SWT -b SIL-ENCE -a -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -i $MLF_PHNS_ALIGN_TRN -m -t $THR_HVITE_PRUNE -y lab -I $MLF_WORDS_TRN -S $LIST_AUDIO_TRN $DICT_SP $LIST_MONOPHNS_SP
else
  cd $DIR_SCRATCH
  mkdir -p hvite_lists
  cd hvite_lists
  rm *
  perl $DIR_SRC/split.pl $LIST_AUDIO_TRN $NUM_HEREST_PROCS $DIR_SCRATCH/hvite_lists
  cnt=1
  for list in `ls *`
  do
    HVite -T 1 -l '*' -o SWT -b SIL-ENCE -a -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -i $list.mlf -m -t $THR_HVITE_PRUNE -y lab -I $MLF_WORDS_TRN -S $list $DICT_SP $LIST_MONOPHNS_SP 2>&1 > $list.log &
  done
  wait
  cat *.mlf > $MLF_PHNS_ALIGN_TRN
  cat *.log
fi
# TODO: Will exit status still reflect an error in one of the childs?
bash $DIR_SRC/check_exit_status.sh $0 $?

#==============================================================================
# Use models to realign and select best pronunciation for testing data
#==============================================================================

echo "INFO ($0): ReAlign testing data"

if [ $NUM_HEREST_PROCS -eq 1 ]; then
  HVite -l '*' -o SWT -b SIL-ENCE -a -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -i $MLF_PHNS_ALIGN_TST -m -t $THR_HVITE_PRUNE -y lab -I $MLF_WORDS_TST -S $LIST_AUDIO_TST $DICT_SP $LIST_MONOPHNS_SP
else
  cd $DIR_SCRATCH
  mkdir -p hvite_lists
  cd hvite_lists
  rm *
  perl $DIR_SRC/split.pl $LIST_AUDIO_TST $NUM_HEREST_PROCS $DIR_SCRATCH/hvite_lists
  cnt=1
  for list in `ls *`
  do
    HVite -l '*' -o SWT -b SIL-ENCE -a -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -i $list.mlf -m -t $THR_HVITE_PRUNE -y lab -I $MLF_WORDS_TST -S $list $DICT_SP $LIST_MONOPHNS_SP 2>&1 > $list.log &
  done
  wait
  cat *.mlf > $MLF_PHNS_ALIGN_TST
  cat *.log

fi
bash $DIR_SRC/check_exit_status.sh $0 $?

#==============================================================================
# Remove pruned files from lists
#==============================================================================
echo "WARNING ($0): Possibly removing test sentences which were difficult to align. You should check to ensure the results are sane..."

perl $DIR_SRC/prune_list_after_alignment.pl $MLF_PHNS_ALIGN_TRN $MLF_PHNS_ALIGN_TST $LIST_AUDIO_TRN $LIST_AUDIO_TST
bash $DIR_SRC/check_exit_status.sh $0 $?

#==============================================================================
# Using the current hmmDefs.mmf & macros files, perform 2 re-estimations
#==============================================================================

echo "INFO ($0): Re-estimating HMM parameters (2 iterations)"

bash $DIR_SRC/herest.sh $LIST_MONOPHNS_SP $MLF_PHNS_ALIGN_TRN 2
bash $DIR_SRC/check_exit_status.sh $0 $?

