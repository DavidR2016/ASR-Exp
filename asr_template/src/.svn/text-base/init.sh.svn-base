#!/bin/bash
# Author: Charl van Heerden (cvheerden@csir.co.za)

#==============================================================================
# Setup environment
#==============================================================================
mkdir -p $DIR_EXP
if [ ! -d $DIR_EXP ]; then
  echo "ERROR(init.sh): Failed to created DIR_EXP <$DIR_EXP>"
  exit 1;
fi

mkdir -p $DIR_EXP/models
mkdir -p $DIR_EXP/grammar
mkdir -p $DIR_EXP/config
mkdir -p $DIR_EXP/dictionaries
mkdir -p $DIR_EXP/lists
mkdir -p $DIR_EXP/mlfs
#mkdir -p $DIR_EXP/logs
mkdir -p $DIR_EXP/results

#==============================================================================
# Sort the dictionary
# Requirements:
# - DICT (set in Vars.sh)
# - htksortdict (see src dir from template)
#==============================================================================
type -P htksortdict &>/dev/null || { echo "ERROR(init.sh): htksortdict not found (maybe you need to compile it from $DIR_SRC?)" >&2; exit 1;}
if [ ! -s $DICT ]; then
  echo "ERROR(init.sh): DICT <$DICT> not found!"
  exit 1;
fi

cat $DICT > $DIR_SCRATCH/tmp.dict
echo "$SENTEND sil" >> $DIR_SCRATCH/tmp.dict
echo "$SENTSTART sil" >> $DIR_SCRATCH/tmp.dict
echo "SIL-ENCE sil" >> $DIR_SCRATCH/tmp.dict
htksortdict $DIR_SCRATCH/tmp.dict $DICT_BASE
bash $DIR_SRC/check_exit_status.sh $0 $?
rm $DIR_SCRATCH/tmp.dict

#==============================================================================
# Check that lists exist. For finer details, run ./CHECK.sh lists
# If they do exist, copy them to the DIR_EXP
#==============================================================================
if [ ! -s $LST_AUDIO_TRN_ORIG ] || [ -z $LST_AUDIO_TRN_ORIG ]; then
  echo "ERROR(init.sh): LST_AUDIO_TRN_ORIG <$LST_AUDIO_TRN_ORIG> not found!"
  exit 1;
fi

if [ ! -s $LST_AUDIO_TST_ORIG ] || [ -z $LST_AUDIO_TST_ORIG ]; then
  echo "ERROR(init.sh): LST_AUDIO_TST_ORIG <$LST_AUDIO_TST_ORIG> not found!"
  exit 1;
fi

if [ ! -s $LST_TRANS_TRN_ORIG ] || [ -z $LST_TRANS_TRN_ORIG ]; then
  echo "ERROR(init.sh): LST_TRANS_TRN_ORIG <$LST_TRANS_TRN_ORIG> not found!"
  exit 1;
fi

if [ ! -s $LST_TRANS_TST_ORIG ] || [ -z $LST_TRANS_TST_ORIG ]; then
  echo "ERROR(init.sh): LST_TRANS_TST_ORIG <$LST_TRANS_TST_ORIG> not found!"
  exit 1;
fi

cp $LST_AUDIO_TRN_ORIG $LIST_AUDIO_TRN 
cp $LST_AUDIO_TST_ORIG $LIST_AUDIO_TST
cp $LST_TRANS_TRN_ORIG $LIST_TRANS_TRN 
cp $LST_TRANS_TST_ORIG $LIST_TRANS_TST


#==============================================================================
# Create monophone list (if it doesn't exist)
#==============================================================================
if [ ! -s $LIST_MONOPHNS ]; then
  echo "INIT: Creating monophones lines"
  perl $DIR_SRC/create_monophone_list.pl $LIST_MONOPHNS $DICT_BASE
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: Monophone list exists. Using as is."
fi

#==============================================================================
# Create questions file for tying (if it doesn't exist)
#==============================================================================
if [ ! -s $QUESTIONS_FILE ]; then
  echo "INIT: Creating questions file"
  perl $DIR_SRC/create_quests_file.pl $QUESTIONS_FILE $LIST_MONOPHNS
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: Questions file exists. Using as is."
fi

#==============================================================================
# Add sp to monophones.lst
#==============================================================================
echo "INIT: Adding sp to $LIST_MONOPHNS_SP"
cat $LIST_MONOPHNS > $LIST_MONOPHNS_SP
echo "sp" >> $LIST_MONOPHNS_SP

#==============================================================================
# Create all config files
#==============================================================================
if [ ! -s $CFG_HCOPY ]; then
  echo "INIT: Creating $CFG_HCOPY"
  bash $DIR_SRC/create_configs.sh hcopy $CFG_HCOPY
else
  echo "INIT: $CFG_HCOPY already exists. Using as is."
fi

if [ ! -s $CFG_HEREST ]; then
  echo "INIT: Creating $CFG_HEREST"
  bash $DIR_SRC/create_configs.sh herest $CFG_HEREST
else
  echo "INIT: $CFG_HEREST already exists. Using as is."
fi

if [ ! -s $CFG_HVITE ]; then
  echo "INIT: Creating $CFG_HVITE"
  bash $DIR_SRC/create_configs.sh hvite $CFG_HVITE
else
  echo "INIT: $CFG_HVITE already exists. Using as is."
fi

if [ ! -s $CFG_HCOMPV ]; then
  echo "INIT: Creating $CFG_HCOMPV"
  bash $DIR_SRC/create_configs.sh hcompv $CFG_HCOMPV
else
  echo "INIT: $CFG_HCOMPV already exists. Using as is."
fi

#==============================================================================
# Create all led, ded, hed files
#==============================================================================
TMP_VAR=$LED_MKPHONES
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh mkphns_led $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$LED_MKPHONES_SP
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh mkphns_sp_led $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$LED_MKWORDS
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh mkwords_led $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$LED_MKBI
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh mkbi_led $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$LED_MKTRI
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh mktri_led $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$LED_MKBI_XWORD
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh mkbixword_led $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$LED_MKTRI_XWORD
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh mktrixword_led $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$LED_MERGE
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh merge_led $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$HED_SIL
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh sil_hed $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$HED_MIX_INC
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh mix_inc_hed $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$HED_REGTREE
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh regtree_hed $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$DED_GLOBAL_MONO
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh globol_mono_ded $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$DED_GLOBAL_WORD
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh global_word_ded $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$DED_GLOBAL_BI
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh global_bi_ded $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$DED_GLOBAL_TRI
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh global_tri_ded $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$DED_REALIGN
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh realign_ded $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$DED_GLOBAL_TEST
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh global_tst_ded $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

# TODO(Charl): DIR_CFG RENAME!!!
TMP_VAR=$DIR_EXP/config/proto_0.pcf
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  bash $DIR_SRC/create_configs.sh pcf $TMP_VAR
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

TMP_VAR=$DIR_EXP/models/proto
if [ ! -s $TMP_VAR ]; then
  echo "INIT: Creating $TMP_VAR"
  perl $DIR_SRC/make_proto_hmm_set.pl $DIR_EXP/config/proto_0.pcf
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: $TMP_VAR already exists. Using as is."
fi

#==============================================================================
# Create all led, ded, hed files
#==============================================================================
if [ ! -s $LIST_WORDS_TRN ]; then
  echo "INIT: Creating $LIST_WORDS_TRN"
  perl $DIR_SRC/create_wordlist.pl $LIST_TRANS_TRN $LIST_WORDS_TRN
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: $LIST_WORDS_TRN already exists. Using as is."
fi

if [ ! -s $LIST_WORDS_TST ]; then
  echo "INIT: Creating $LIST_WORDS_TST"
  perl $DIR_SRC/create_wordlist.pl $LIST_TRANS_TST $LIST_WORDS_TST
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: $LIST_WORDS_TST already exists. Using as is."
fi

if [ ! -s $LIST_WORDS_ALL ]; then
  echo "INIT: Creating $LIST_WORDS_ALL"
  echo "$SENTEND" > $LIST_WORDS_ALL
  echo "$SENTSTART" >> $LIST_WORDS_ALL
  echo "SIL-ENCE" >> $LIST_WORDS_ALL
  cat $LIST_WORDS_TRN $LIST_WORDS_TST | sort -u >> $LIST_WORDS_ALL
else
  echo "INIT: $LIST_WORDS_ALL already exists. Using as is."
fi

if [ ! -s $MLF_WORDS_ALL ]; then
  echo "INIT: Creating $MLF_WORDS_ALL"
  cat $LIST_TRANS_TST $LIST_TRANS_TRN > $DIR_SCRATCH/tmp.lst
  perl $DIR_SRC/create_mlf_from_text_files.pl $DIR_SCRATCH/tmp.lst $MLF_WORDS_ALL
  bash $DIR_SRC/check_exit_status.sh $0 $?
  rm $DIR_SCRATCH/tmp.lst
else
  echo "INIT: $MLF_WORDS_ALL already exists. Using as is."
fi

if [ ! -s $MLF_WORDS_TST ]; then
  echo "INIT: Creating $MLF_WORDS_TST"
  perl $DIR_SRC/create_mlf_from_text_files.pl $LIST_TRANS_TST $MLF_WORDS_TST
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: $MLF_WORDS_TST already exists. Using as is."
fi

if [ ! -s $MLF_WORDS_TRN ]; then
  echo "INIT: Creating $MLF_WORDS_TRN"
  perl $DIR_SRC/create_mlf_from_text_files.pl $LIST_TRANS_TRN $MLF_WORDS_TRN
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: $MLF_WORDS_TRN already exists. Using as is."
fi

if [ ! -s $MLF_PHNS_TRN ]; then
  echo "INIT: Creating $MLF_PHNS_TRN"
  HLEd -A -D -T 1 -V -l '*' -d $DICT_BASE -i $MLF_PHNS_TRN $LED_MKPHONES $MLF_WORDS_TRN
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: $MLF_PHNS_TRN already exists. Using as is."
fi 

if [ ! -s $MLF_PHNS_TST ]; then
  echo "INIT: Creating $MLF_PHNS_TST"
  HLEd -A -D -T 1 -V -l '*' -d $DICT_BASE -i $MLF_PHNS_TST $LED_MKPHONES $MLF_WORDS_TST
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: $MLF_PHNS_TST already exists. Using as is."
fi 

if [ ! -s $MLF_PHNS_ALL ]; then
  echo "INIT: Creating $MLF_PHNS_ALL"
  HLEd -A -D -T 1 -V -l '*' -d $DICT_BASE -i $MLF_PHNS_ALL $LED_MKPHONES $MLF_WORDS_ALL
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: $MLF_PHNS_ALL already exists. Using as is."
fi 

# Create dict with sp at end of every pronunciation
cat $DICT_BASE | awk '{print $0 " sp"}' | sed 's/sil sp/sil/g' > $DICT_SP

if [ ! -s $MLF_PHNS_SP_TRN ]; then
  echo "INIT: Creating $MLF_PHNS_SP_TRN"
  HLEd -A -D -T 1 -V -l '*' -d $DICT_SP -i $MLF_PHNS_SP_TRN $LED_MKPHONES_SP $MLF_WORDS_TRN
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: $MLF_PHNS_SP_TRN already exists. Using as is."
fi 

if [ ! -s $MLF_PHNS_SP_TST ]; then
  echo "INIT: Creating $MLF_PHNS_SP_TST"
  HLEd -A -D -T 1 -V -l '*' -d $DICT_SP -i $MLF_PHNS_SP_TST $LED_MKPHONES_SP $MLF_WORDS_TST
  bash $DIR_SRC/check_exit_status.sh $0 $?
else
  echo "INIT: $MLF_PHNS_SP_TST already exists. Using as is."
fi 

# You would use this in your recipe if you wanted to create a biphone system
#TMP_VAR=$HED_MKBI
#if [ ! -s $TMP_VAR ]; then
#  echo "INIT: Creating $TMP_VAR"
#  bash $DIR_SRC/create_configs.sh mkbi_hed $TMP_VAR
#else
#  echo "INIT: $TMP_VAR already exists. Using as is."
#fi

