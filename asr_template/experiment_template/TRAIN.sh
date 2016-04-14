#!/bin/bash
# Author: Charl van Heerden (cvheerden@csir.co.za)
#         Neil Kleynhans (ntkleynhans@csir.co.za)
#
# This script will call others scripts to train a cross-word triphone ASR
# system.
#
# IMPORTANT:
#  - set ALL variables in Vars.sh
#  - make sure you have audio and transcription trn+tst lists
#  - make sure you have a valid pronunciation dictionary
#  - do ./CHECK.sh all_phases to test your setup

source Vars.sh

FLAG=$1

#============================================================
# Check that the number of arguments are correct
#============================================================
EXPECTED_NUM_ARGS=1
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: ./TRAIN.sh <flag>"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<option>" "customize training:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "all_phases" "- Train a system from scratch"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "init" "- Setup your experiment directory structure"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Sort & copy dictionary"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Copy lists"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Create monophone list from dict (except if specified in Vars.sh)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Create basic questions file (except if specified in Vars.sh)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Add sp to monophone list"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Add SENT-(START,END) & SIL-ENCE to dictionary"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Create all config files (except if specified in Vars.sh)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Create all .led, .hed, .ded files (except if specified in Vars.sh)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Create all word lists (except if specified in Vars.sh)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Create all required mlf's (except if specified in Vars.sh)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "    " "- Create proto hmm (except if specified in Vars.sh)"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "train_mono" "- Train a flat start monophone ASR system"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Transcriptions will be re-aligned, and bad alignments removed (see LOG)"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "train_tri"  "- Given the monophone system, trains a single mixture cross-word triphone ASR system"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Decision tree will be created to handle unseen triphones"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "inc_mixes"  "- Given the triphone system, increase the number of mixtures to NUM_MIXES in Vars.sh (default=7)"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "semitied"   "- Learns semi-tied transforms. To configure, see Vars.sh"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "grammar "   "- Train a grammar that can be used for decoding"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "clg     "   "- Compose a CLG using Juicer utility functions. See JUICER REAME for details!!"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "sri_word_ngram "   "- Train an ngram model using SRI's ngram-count"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "align_train   "   "- Do forced alignment on training data with the latest available models (NB: will not be run under all_phases)"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "align_test   "   "- Do forced alignment on testing data with the latest available models (NB: will not be run under all_phases)"

  exit $E_BAD_ARGS
fi

#============================================================
# Some Basic checks - TODO: These are becoming enough to move to new script
#============================================================
if [ ! -d $DIR_SRC ]; then
  echo -e "ERROR: Please set <DIR_SRC> in Vars.sh to valid directory"
  exit 1 
fi

if [ ! -d $DIR_EXP ]; then
  echo -e "WARNING: DIR_EXP doesn't exist. It will be created (<$DIR_EXP>)"
  mkdir -p $DIR_EXP
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create $DIR_EXP. Exiting!"
    exit 1;
  fi
fi

if [ ! -d $DIR_SCRATCH ]; then
  echo -e "WARNING: Creating <DIR_SCRATCH> in Vars.sh"
  mkdir -p $DIR_SCRATCH
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create $DIR_SCRATCH. Exiting!"
    exit 1;
  fi
fi

#TODO: should fix this up (HACK)
DIR_LOG=$DIR_EXP/log
mkdir -p $DIR_LOG

#============================================================
# INIT
#============================================================
if [ $FLAG = 'init' ] || [ $FLAG = 'all_phases' ]; then
  echo "INITIALIZING"
  bash $DIR_SRC/init.sh 2>&1 | tee -a $DIR_LOG/init.log
  if [ $? -ne 0 ]; then
    echo "ERROR: INIT failed for some reason. Please check the logs!"
    exit 1;
  fi
fi

#============================================================
# TRAIN MONOPHONE SYSTEM
#============================================================
if [ $FLAG = 'train_mono' ] || [ $FLAG = 'all_phases' ]; then
  echo "TRAINING MONOPHONE SYSTEM"
  bash $DIR_SRC/mono_train.sh 2>&1 | tee -a $DIR_LOG/mono_train.log
  if [ $? -ne 0 ]; then
    echo "ERROR: MONOPHONE TRAINING failed for some reason. Please check the logs!"
    exit 1;
  fi
fi

#============================================================
# TRAIN TRIPHONE SYSTEM
#============================================================
if [ $FLAG = 'train_tri' ] || [ $FLAG = 'all_phases' ]; then
  echo "TRAINING TRIPHONE SYSTEM"
  bash $DIR_SRC/tri_train.sh 2>&1 | tee -a $DIR_LOG/tri_train.log
fi

#============================================================
# INCREASE MIXTURES
#============================================================
if [ $FLAG = 'inc_mixes' ] || [ $FLAG = 'all_phases' ]; then
  echo "INCREASING MIXTURES TO <$NUM_MIXES>"
  bash $DIR_SRC/tri_inc_mixes.sh 2>&1 | tee -a $DIR_LOG/tri_inc_train.log
fi

#============================================================
# SEMITIED TRANSFORMS
#============================================================
if [ $FLAG = 'semitied' ] || [ $FLAG = 'all_phases' ]; then
  echo "SEMITIED TRANSFORMS"
  bash $DIR_SRC/semit.sh 2>&1 | tee -a $DIR_LOG/semit.log
fi

#============================================================
# TRAIN LM
#============================================================
if [ $FLAG = 'grammar' ] || [ $FLAG = 'all_phases' ]; then
  echo "LEARNING A GRAMMAR"
  bash $DIR_SRC/loop_grammar.sh $LIST_MONOPHNS 2>&1 | tee -a $DIR_LOG/loop_grammer.log
fi

#============================================================
# UTILITY FUNCTIONS
# These functions are not part of "all_phases", but are
# available as useful alternatives/additions to the ASR training
# process
#============================================================

#============================================================
# Compose CLG
#============================================================
if [ $FLAG = 'clg' ]; then
  echo "Composing CLG"
  if [ ! -s $LIST_LM_TRN ] || [ -z $LIST_LM_TRN ]; then
    echo "WARNING: LIST_LM_TRN not specified. Using LIST_TRANS_TRN!"
    LIST_LM_TRN=$LIST_TRANS_TRN
  fi
  bash $DIR_SRC/clg.sh $LIST_LM_TRN
  bash $DIR_SRC/compose_clg.sh $DIR_EXP/grammar/C.fst $DIR_EXP/grammar/L.fst $DIR_EXP/grammar/G.fst
fi

#============================================================
# TRAIN SRI NGRAM WORD LM
#============================================================
if [ $FLAG = 'sri_word_ngram' ]; then
  echo "TRAINING AN SRI WORD NGRAM"

  if [ ! -s $LIST_LM_TRN ] || [ -z $LIST_LM_TRN ]; then
    echo "WARNING: LIST_LM_TRN not specified. Using LIST_TRANS_TRN!"
    LIST_LM_TRN=$LIST_TRANS_TRN
  fi
  bash $DIR_SRC/srilm_ngram_lm.sh $LIST_LM_TRN $LM_NGRAM_ORDER
fi

#============================================================
# DO ALIGNMENT
#============================================================
if [ $FLAG = 'align_train' ]; then
  echo "FORCED ALIGNMENT"
  #forced_alignment.sh <model list> <reference mlf> <audio list> <dict>
  bash $DIR_SRC/forced_alignment.sh $LIST_TIED $MLF_WORDS_TRN $LIST_AUDIO_TRN $DICT_SP $MLF_ALIGN_TRN 2>&1 | tee -a $DIR_LOG/force_alignments.log
fi

if [ $FLAG = 'align_test' ]; then
  echo "FORCED ALIGNMENT"
  #forced_alignment.sh <model list> <reference mlf> <audio list> <dict>
  bash $DIR_SRC/forced_alignment.sh $LIST_TIED $MLF_WORDS_TST $LIST_AUDIO_TST $DICT_SP $MLF_ALIGN_TST 2>&1 | tee -a $DIR_LOG/force_alignments.log
fi

