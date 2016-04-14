#!/bin/bash

source Vars.sh

FLAG=$1

if [ $FLAG = 'bghmm' ] || [ $FLAG = 'all_phases' ]; then
  # Initialize
  bash TRAIN.sh init

  # Create empty mlf
  echo "#!MLF!#"  > $MLF_WORDS_TRN
  echo "\"*.lab\""   >> $MLF_WORDS_TRN
  echo "bghmm"   >> $MLF_WORDS_TRN
  echo "."       >> $MLF_WORDS_TRN

  # Replace mono mlf with bghmm
  cp $MLF_WORDS_TRN $MLF_PHNS_TRN

  # Replace mono lst with bghmm
  echo "bghmm" > $LIST_MONOPHNS

  echo "INFO ($0): Estimating initial HMM parameters"

  source $DIR_SRC/inc_hmm_cnt.sh auto_update

  HCompV -A -T $TRACE -C $CFG_HCOMPV -S $LIST_AUDIO_TRN -m -f $VFLOORS_SCALE -M $DIR_HMM_CURR $PROTO_RAW
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

  LOCAL_NUM_ITERATIONS=$(($NUM_MIXES * 2))

  while [ $LOCAL_NUM_ITERATIONS -gt 1 ]; do # -gt 1, because we already have one mixture
    LOCAL_NUM_ITERATIONS=$(($LOCAL_NUM_ITERATIONS-1))
  #==============================================================================
  # Increment the mixtures
  #==============================================================================
  # Make sure the hmm dirs are up to date
    source $DIR_SRC/inc_hmm_cnt.sh auto_update
    HHEd -A -D -T 1 -V -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -M $DIR_HMM_NEXT $HED_MIX_INC $LIST_MONOPHNS
    bash $DIR_SRC/check_exit_status.sh $0 $?

  #==============================================================================
  # Re-estimate twice
  #==============================================================================
  # ./herest.sh <model list> <trn mlf> <num re-estimations>
    bash $DIR_SRC/herest.sh $LIST_MONOPHNS $MLF_PHNS_TRN 2
    bash $DIR_SRC/check_exit_status.sh $0 $?
  done
fi

if [ $FLAG = 'semitied' ] || [ $FLAG = 'all_phases' ]; then
  sed '/RC/d' $HED_REGTREE
  if [ -z $HADAPT_BASECLASS ] || [ -z $HADAPT_SEMITIEDMACRO ]; then
    echo "WARNING: HADAPT_BASECLASS and/or HADAPT_SEMITIEDMACRO not set!"
    echo "WARNING: Setting HADAPT_BASECLASS and HADAPT_SEMITIEDMACRO automatically!"
    source $DIR_SRC/inc_hmm_cnt.sh auto_update
    export HADAPT_BASECLASS=$DIR_HMM_CURR/regtree_2.base
    export HADAPT_SEMITIEDMACRO=$DIR_HMM_CURR/SEMITIED
  fi

  if [ ! -s $HED_REGTREE ]; then
    echo "INIT: Creating $HED_REGTREE"
    bash $DIR_SRC/create_configs.sh regtree_hed $HED_REGTREE
  else
    echo "INIT: $HED_REGTREE already exists. Using as is."
  fi

  if [ ! -s $CFG_SEMITIED ]; then
    echo "INIT: Creating $CFG_SEMITIED"
    bash $DIR_SRC/create_configs.sh semit $CFG_SEMITIED
  else
    echo "INIT: $CFG_SEMITIED already exists. Using as is."
  fi
  #==============================================================================
  # Estimate semitied transform
  #==============================================================================
  source $DIR_SRC/inc_hmm_cnt.sh auto_update
  HHEd -A -D -V -T 1 -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -w /dev/null -M $DIR_HMM_CURR $HED_REGTREE $LIST_MONOPHNS 
  bash $DIR_SRC/check_exit_status.sh $0 $?
  
  HERest -A -D -T 1 -V -C $CFG_SEMITIED -S $LIST_AUDIO_TRN -I $MLF_PHNS_TRN -u stw -t $HEREST_PRUNE -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -K $DIR_HMM_CURR -M $DIR_HMM_NEXT -s $STATS $LIST_MONOPHNS
  bash $DIR_SRC/check_exit_status.sh $0 $?
  source $DIR_SRC/inc_hmm_cnt.sh auto_update

  # TODO: HERest expects -K and -J to be before -M. Decision for now: do HERest explicitely instead of complicating herest.sh
  SEMITIED=`find $DIR_EXP/models -iname "SEMITIED"`
  DIR_TRANS=`dirname $SEMITIED`
  HERest -A -D -T 1 -V -S $LIST_AUDIO_TRN -I $MLF_PHNS_TRN -t $HEREST_PRUNE -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -J $DIR_TRANS -M $DIR_HMM_NEXT -s $STATS $LIST_MONOPHNS -C $CFG_SEMITIED
  bash $DIR_SRC/check_exit_status.sh $0 $?

  source $DIR_SRC/inc_hmm_cnt.sh auto_update
  HERest -A -D -T 1 -V -S $LIST_AUDIO_TRN -I $MLF_PHNS_TRN -t $HEREST_PRUNE -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -J $DIR_TRANS -M $DIR_HMM_NEXT -s $STATS $LIST_MONOPHNS -C $CFG_SEMITIED
  bash $DIR_SRC/check_exit_status.sh $0 $?
fi

if [ $FLAG = 'merge' ]; then
  EXPECTED_NUM_ARGS=5
  E_BAD_ARGS=65

  if [ $# -ne $EXPECTED_NUM_ARGS ]; then
    echo "Usage: ./TRAIN_BACKGROUND_MODEL.sh merge <target_hmm> <target_macro> <target_regtree.base> <target_semitied>"
    exit $E_BAD_ARGS
  fi
  
  # Add this model to an existing, well trained model
  TARGET_HMM=$2
  TARGET_MACRO=$3
  TARGET_REGTREE=$4
  TARGET_SEMITIED=$5
  source $DIR_SRC/inc_hmm_cnt.sh auto_update
  SRC_HMM=$DIR_HMM_CURR/hmmDefs.mmf
  SRC_SEMITIED=`find $DIR_EXP/models -iname "SEMITIED"`
  SRC_REGTREE=`find $DIR_EXP/models -iname "regtree_2.base"`
  

  # -----------------------------------------------------------
  # BACKUP
  # -----------------------------------------------------------
  # Before merging, make a backup of all models that are going to be changed...
  # Backup in src, otherwise automatic incrementation picks up models and SEMIT
  mkdir -p $DIR_EXP/src/model_backups/src
  mkdir -p $DIR_EXP/src/model_backups/tgt
  cp $SRC_HMM $DIR_EXP/src/model_backups/src/
  cp $DIR_HMM_CURR/macros $DIR_EXP/src/model_backups/src/
  cp $SRC_SEMITIED $DIR_EXP/src/model_backups/src/
  cp $SRC_REGTREE $DIR_EXP/src/model_backups/src/

  cp $TARGET_HMM $DIR_EXP/src/model_backups/tgt/
  cp $TARGET_MACRO $DIR_EXP/src/model_backups/tgt/
  cp $TARGET_REGTREE $DIR_EXP/src/model_backups/tgt/
  cp $TARGET_SEMITIED $DIR_EXP/src/model_backups/tgt/ 

  # -----------------------------------------------------------
  # HMM MERGING
  # -----------------------------------------------------------
  echo "Merging hmms..."
  # Remove the transition matrix (last 7 lines of the file)
  sed -i -n -e :a -e '1,7!{P;N;D;};N;ba' $DIR_HMM_CURR/hmmDefs.mmf
  sed -i 's/<NUMSTATES> 5/<NUMSTATES> 6/g' $DIR_HMM_CURR/hmmDefs.mmf

  # Replace the transition matrix with a 6x6 matrix(TODO: How important are the weights?)
  echo "<STATE> 5" >> $DIR_HMM_CURR/hmmDefs.mmf
  echo "~s \"ST_REPLACE_ME_PLEASE\"" >> $DIR_HMM_CURR/hmmDefs.mmf
  echo "<TRANSP> 6" >> $DIR_HMM_CURR/hmmDefs.mmf
  echo " 0.000000e+00 1.000000e-01 0.000000e+00 0.000000e+00 1.000000e-01 8.000000e-01" >> $DIR_HMM_CURR/hmmDefs.mmf
  echo " 0.000000e+00 9.905799e-01 9.420095e-03 0.000000e+00 0.000000e+00 0.000000e+00" >> $DIR_HMM_CURR/hmmDefs.mmf
  echo " 0.000000e+00 0.000000e+00 9.925113e-01 7.488732e-03 0.000000e+00 0.000000e+00" >> $DIR_HMM_CURR/hmmDefs.mmf
  echo " 0.000000e+00 0.000000e+00 0.000000e+00 8.000000e-01 1.000000e-01 1.000000e-01" >> $DIR_HMM_CURR/hmmDefs.mmf
  echo " 0.000000e+00 1.000000e-01 0.000000e+00 0.000000e+00 8.000000e-01 1.000000e-01" >> $DIR_HMM_CURR/hmmDefs.mmf
  echo " 0.000000e+00 0.000000e+00 0.000000e+00 0.000000e+00 0.000000e+00 0.000000e+00" >> $DIR_HMM_CURR/hmmDefs.mmf
  echo "<ENDHMM>" >> $DIR_HMM_CURR/hmmDefs.mmf

  source $DIR_SRC/inc_hmm_cnt.sh auto_update

  SP_STATE=`grep -n -A 4 "~h \"sp\"" $TARGET_HMM | tail -n 1 | sed 's/^.*\(ST.*\)\"$/\1/g'`
  echo "$SRC_HMM"
  sed -i "s/ST_REPLACE_ME_PLEASE/$SP_STATE/g" $SRC_HMM
  sed -i '1,4d' $SRC_HMM
  cat $SRC_HMM >> $TARGET_HMM

  # Rename the sp model
  sed -i 's/~h "sp"/~h "sp_renamed"/g' $TARGET_HMM

  # Rename the background model
  sed -i 's/~h "bghmm"/~h "sp"/g' $TARGET_HMM

  # -----------------------------------------------------------
  # REGTREE MERGING
  # -----------------------------------------------------------
  echo "Merging regtrees..."
  # (1) sp.state[2] -> sp.state[5]
  sed -i 's/<NUMCLASSES> 40/<NUMCLASSES> 41/' $TARGET_REGTREE
  sed -i 's/sp.state\[2\]/sp.state\[5\]/g' $TARGET_REGTREE
  # (2) bghmm -> sp
  sed -i 's/bghmm/sp/g' $SRC_REGTREE
  sed -i 's/<CLASS> 1/<CLASS> 41/' $SRC_REGTREE
  sed -i '1,4d' $SRC_REGTREE
  cat $SRC_REGTREE >> $TARGET_REGTREE
  
  # -----------------------------------------------------------
  # SEMITIED MERGING
  # -----------------------------------------------------------
  echo "Merging semitied transforms..."
  echo "<CLASSXFORM> 41 41" >> $TARGET_SEMITIED
  sed -i 's/<NUMXFORMS> 40/<NUMXFORMS> 41/' $TARGET_SEMITIED

  sed -i '1,6d' $SRC_SEMITIED
  sed -i -n -e :a -e '1,2!{P;N;D;};N;ba' $SRC_SEMITIED
  sed -i 's/<LINXFORM> 1/<LINXFORM> 41/' $SRC_SEMITIED
  
  f2="$(<$SRC_SEMITIED)"
  awk -vf2="$f2" '/^<XFORMWGTSET>$/{print f2;print;next}1' $TARGET_SEMITIED > $TARGET_SEMITIED.tmp
  mv $TARGET_SEMITIED.tmp $TARGET_SEMITIED

  # -----------------------------------------------------------
  # FINALLY, REMOVE ALL PATHS POINTING TO SEMIT. DOESN'T SEEM TO MATTER IF NOT USING -E (ie using
  # parent transforms), since the actual transform used seems to come from -J. It does try to find
  # the exact model being pointed to, although it doesn't apply it during scoring...
  # -----------------------------------------------------------
  # Change the hmmDefs.mmf
  sed -i -r "s/(<PARENTXFORM>~a ).*(SEMITIED)\"/\1\"\2\"/g" $TARGET_HMM
  # Change the macros
  sed -i -r "s/(<PARENTXFORM>~a ).*(SEMITIED)\"/\1\"\2\"/g" $TARGET_MACRO
  # Change the SEMITIED
  sed -i -r "s/(~a ).*(SEMITIED)\"/\1\"\2\"/g" $TARGET_SEMITIED
fi
