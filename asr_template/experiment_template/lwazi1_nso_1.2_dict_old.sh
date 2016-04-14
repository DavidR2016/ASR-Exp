#!/bin/bash

#-----------------------------------------------------------------------------
# Script that creates dictionary for Lwazi 1.0 Sepedi second generation system
#-----------------------------------------------------------------------------

DIR_G2P=~/hlt/sepedi/Dictionaries.Lwazi.Nso.1.2/g2p
DIR_TRANSCRIPTS=/media/DATA/nchlt_sepedi_cs_20111200_20111213/transcriptions
DIR_DICT_SCRIPTS=~/LWAZI/asr.sprint.Dec.2010/scripts

DIR_ROOT=/media/DATA
DIR_ASR_SCRIPTS=~/hlt/sepedi/asr_template

NEW_WORDS=$DIR_ROOT/dicts/corpus.words
NEW_DICT=$DIR_ROOT/dicts/corpus.dict

#Manually select functions to be performed
DO_ALL=0
DO_TRANSCRIPTS=0
DO_WORDLIST=0
DO_CHECK_RULES=1 #Add rules if necessary (missing graphemes)
DO_DICT=1

#-----------------------------------------------------------------------------

die_if_error(){
  $DIR_ASR_SCRIPTS/src/check_exit_status.sh $0 $? || exit $?
}

echo "Create directories, if necessary"
#mkdir -p $DIR_ROOT/processed_trans
mkdir -p $DIR_ROOT/dicts
#mkdir -p $DIR_ROOT/lists
#mkdir -p $DIR_ROOT/tmp

#-----------------------------------------------------------------------------

#if [ $DO_TRANSCRIPTS == 1 ] || [ $DO_ALL == 1 ]; then
#  echo "Preprocess transcriptions"
#  $DIR_ASR_SCRIPTS/utility_scripts/create_preproc_lists.pl $DIR_TRANSCRIPTS $DIR_ROOT/processed_trans $DIR_ROOT/lists/preprocess.lst
#  die_if_error
#
#  cd $DIR_ROOT/nso_lwazi_baseline/src
#  ./PREPROC.sh $DIR_ROOT/lists/preprocess.lst all_phases
#  die_if_error
#fi

#-----------------------------------------------------------------------------

if [ $DO_WORDLIST == 1 ] || [ $DO_ALL = 1 ]; then
  echo "Create word list"
  gawk '{print $2}' < $DIR_ROOT/nchlt_sepedi_cs_20111200_20111213/lists/preproclist.lst > $DIR_ROOT/nchlt_sepedi_cs_20111200_20111213/lists/txt.lst
  $DIR_ASR_SCRIPTS/src/create_wordlist.pl $DIR_ROOT/nchlt_sepedi_cs_20111200_20111213/lists/txt.lst $NEW_WORDS
  die_if_error
fi
#------------------------------------------------------------------------------

if [ $DO_CHECK_RULES == 1 ] || [ $DO_ALL = 1 ]; then
  echo "Check if rule set matches"
  $DIR_DICT_SCRIPTS/graphs_from_words.pl $NEW_WORDS $NEW_WORDS.graphs
  die_if_error
  $DIR_DICT_SCRIPTS/check_rules.pl gra $DIR_G2P/sepedi.rules $NEW_WORDS.graphs $NEW_WORDS.g-check
  die_if_error
  cat $NEW_WORDS.g-check
fi

#-----------------------------------------------------------------------------
# Added rules for the missing grapheme not belonging to this language
cp $DIR_G2P/sepedi.rules $DIR_ROOT/tmp
echo "2;;;;0;0" >> $DIR_ROOT/tmp/sepedi.rules
echo "c;;;P;0;0" >> $DIR_ROOT/tmp/sepedi.rules
echo "v;;;B;0;0" >> $DIR_ROOT/tmp/sepedi.rules
echo "q;;;P;0;0" >> $DIR_ROOT/tmp/sepedi.rules
echo "x;;;x;0;0" >> $DIR_ROOT/tmp/sepedi.rules
echo "z;;;s;0;0" >> $DIR_ROOT/tmp/sepedi.rules

sort $DIR_ROOT/tmp/sepedi.rules > $DIR_ROOT/tmp/sepedi.rules.sorted


#-----------------------------------------------------------------------------
#	Added mapping for problematic "x"

cp $DIR_G2P/sepedi.map.phones $DIR_ROOT/tmp
echo "x	k_> s" >> $DIR_ROOT/tmp/sepedi.map.phones

#-----------------------------------------------------------------------------------

if [ $DO_DICT == 1 ] || [ $DO_ALL == 1 ]; then
  echo "Remove problem words"
  sed -i /^h$/d $NEW_WORDS
  sed -i s/š/1/g $NEW_WORDS
  echo "New word list in $NEW_WORDS"

  echo "Create dictionary"
  $DIR_DICT_SCRIPTS/create_dict.pl $NEW_WORDS $DIR_ROOT/tmp/sepedi.rules.sorted $DIR_G2P/sepedi.gnulls $NEW_DICT.tmp1 -p $DIR_ROOT/tmp/sepedi.map.phones rtl
  die_if_error
  echo "h	h" >> $NEW_DICT.tmp1

  echo "Map to HTK-compatible phonemes and sort"
  $DIR_DICT_SCRIPTS/remap_dict.pl pho $NEW_DICT.tmp1 /home/thipe/LWAZI/asr/dicts/g2p/sampa2htk.map ltr $NEW_DICT.tmp2
  die_if_error
  sed s/1/š/g $NEW_DICT.tmp2 > $NEW_DICT.tmp3
  htksortdict $NEW_DICT.tmp3 $NEW_DICT
  die_if_error

  echo "New dictionary in $NEW_DICT"
  cp -v $NEW_DICT $DIR_ROOT/dicts/cs_nso_1.2.dict

fi

#-----------------------------------------------------------------------------
