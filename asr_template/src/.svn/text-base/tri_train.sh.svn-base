#!/bin/bash
# Author: Charl van Heerdern (cvheerden@csir.co.za)

#==============================================================================
# Create full list of triphones
#==============================================================================

if [ ! -s $LIST_FULL ]; then
  echo "TRAIN TRI: Creating $LIST_FULL"
  perl -e '
  while($phone = <>) {
    chomp $phone;
    push @plist, $phone;
  }
  
  print "sil\nsp\n";
  for($i = 0; $i < scalar(@plist); $i++) {
    for($j = 0; $j < scalar(@plist); $j++) {
      if($plist[$j] ne "sil") {
        for($k = 0; $k < scalar(@plist); $k++) {
          print "$plist[$i]-$plist[$j]+$plist[$k]\n";
        }
      }
    }
  }' < $LIST_MONOPHNS > $LIST_FULL
else
 echo "TRAIN TRI: LIST FULL ($LIST_FULL) exists. Using as is."
fi

#==============================================================================
# Create triphone mlf from aligned transcriptions
#==============================================================================
if [ ! -s $MLF_TRIPHNS_TRN_BACKUP ]; then
  HLEd -A -D -T 1 -V -l '*' -n $LIST_TRI -i $MLF_TRIPHNS_TRN_BACKUP $LED_MKTRI_XWORD $MLF_PHNS_ALIGN_TRN
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "TRI_TRAIN: $MLF_TRIPHNS_TRN_BACKUP already exists. Using as is."
fi

#==============================================================================
# Create triphone mlf
#==============================================================================
if [ ! -s $MLF_TRIPHNS_TRN ]; then
  HLEd -A -D -T 1 -V -l '*' -i $MLF_TRIPHNS_TRN $LED_MKTRI_XWORD $MLF_PHNS_ALIGN_TRN 
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "TRI_TRAIN: $MLF_TRIPHNS_TRN already exists. Using as is."
fi

#==============================================================================
# Create mktri.hed
# Required: $LIST_TRI
#==============================================================================
TMP_VAR=$HED_MKTRI
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh mktri_hed $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

#==============================================================================
# Create triphone hmms
#==============================================================================
source $DIR_SRC/inc_hmm_cnt.sh auto_update
HHEd -A -D -T 1 -V -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -M $DIR_HMM_NEXT $HED_MKTRI $LIST_MONOPHNS_SP 
bash $DIR_SRC/check_exit_status.sh $0 $?
source $DIR_SRC/inc_hmm_cnt.sh auto_update

#==============================================================================
# Re-estimate twice
#==============================================================================
# ./herest.sh <model list> <trn mlf> <num re-estimations>
bash $DIR_SRC/herest.sh $LIST_TRI $MLF_TRIPHNS_TRN 2
bash $DIR_SRC/check_exit_status.sh $0 $?
source $DIR_SRC/inc_hmm_cnt.sh auto_update

#==============================================================================
# Create trees.hed
#==============================================================================
echo "RO 100.0 $STATS" > $HED_TREE
echo "TR 0" >> $HED_TREE
cat $QUESTIONS_FILE >> $HED_TREE
echo "TR 2" >> $HED_TREE
perl $DIR_SRC/mkclscript.pl TB 100 $LIST_MONOPHNS >> $HED_TREE
bash $DIR_SRC/check_exit_status.sh $0 $?
echo "TR 1" >> $HED_TREE
echo "AU $LIST_FULL" >> $HED_TREE
echo "CO $LIST_TIED" >> $HED_TREE
echo "ST $TREES" >> $HED_TREE

#==============================================================================
# Tie the triphones
#==============================================================================
HHEd -A -D -T 1 -V -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -M $DIR_HMM_NEXT $HED_TREE $LIST_TRI 
bash $DIR_SRC/check_exit_status.sh $0 $?
source $DIR_SRC/inc_hmm_cnt.sh auto_update

#==============================================================================
# Re-estimate twice
#==============================================================================
# ./herest.sh <model list> <trn mlf> <num re-estimations>
bash $DIR_SRC/herest.sh $LIST_TIED $MLF_TRIPHNS_TRN 2
bash $DIR_SRC/check_exit_status.sh $0 $?
source $DIR_SRC/inc_hmm_cnt.sh auto_update

