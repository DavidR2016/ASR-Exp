#!/bin/bash
# Author: Charl van Heerden (cvheerden@csir.co.za)
# 
# This script will call others scripts to try to determine if your
# ASR setup is sufficient to run through.
#
# IMPORTANT:
#  - Make sure to set ALL variables under "REQUIRED" in Vars.sh
#  - Make sure all scripts under DIR_SRC are executables (cmod a+x)

source Vars.sh

FLAG=$1

#============================================================
# Check that the number of arguments are correct
#============================================================
EXPECTED_NUM_ARGS=1
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: ./CHECK.sh <option>"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<option>" "customize checking:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "all_phases  " "- Perform all checks"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "variables " "- Check that all expected variables are set"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "software  " "- Check that all expected software is available in the PATH"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "lists     " "- Check that all required lists exist. Will also check:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Every audio file has a transcription"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Every transcription has an audio file"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Every transcription has only one line of text"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- No empty transcriptions"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Check that every audio file is > 200 bytes"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "dicts     " "- Check that all words have a pronunciation: Will also check:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- No empty pronunciations"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- No monophones with < 3 examples in lists"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "textformat" "- Check for text that may break HTK"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Checks phoneset for illegal characters"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Checks transcriptions for illegal characters"
  exit $E_BAD_ARGS
fi

#============================================================
# Check required variables
#============================================================
if [ $FLAG = 'variables' ] || [ $FLAG = 'all_phases' ]; then
  if [ -z $DIR_SRC ] || [ ! -d $DIR_SRC ]; then
    echo "ERROR: DIR_SRC invalid (set it in Vars.sh)"
  fi

  if [ -z $DIR_CFG ] || [ ! -d $DIR_CFG ]; then
    echo "ERROR: DIR_CFG invalid (set it in Vars.sh)"
  fi

  if [ -z $LST_AUDIO_TRN_ORIG ] || [ ! -s $LST_AUDIO_TRN_ORIG ]; then
    echo "ERROR: LST_AUDIO_TRN_ORIG invalid (set it in Vars.sh)"
  fi

  if [ -z $LST_AUDIO_TST_ORIG ] || [ ! -s $LST_AUDIO_TST_ORIG ]; then
    echo "ERROR: LST_AUDIO_TST_ORIG invalid (set it in Vars.sh)"
  fi

  if [ -z $LST_TRANS_TRN_ORIG ] || [ ! -s $LST_TRANS_TRN_ORIG ]; then
    echo "ERROR: LST_TRANS_TRN_ORIG invalid (set it in Vars.sh)"
  fi

  if [ -z $LST_TRANS_TST_ORIG ] || [ ! -s $LST_TRANS_TST_ORIG ]; then
    echo "ERROR: LST_TRANS_TST_ORIG invalid (set it in Vars.sh)"
  fi

  if [ -z $DICT ] || [ ! -s $DICT ]; then
    echo "ERROR: DICT invalid (set it in Vars.sh)"
  fi

  if [ -z $DIR_EXP ] || [ ! -d $DIR_EXP ]; then
    echo "WARNING: DIR_EXP invalid (set it in Vars.sh). It will be created if you run TRAIN.sh!"
  fi

  if [ -z $DIR_SCRATCH ] || [ ! -d $DIR_SCRATCH ]; then
    echo "WARNING: DIR_SCRATCH invalid (set it in Vars.sh). It will be created if you run TRAIN.sh!"
  fi
fi

#============================================================
# Check required software
#============================================================
if [ $FLAG = 'software' ] || [ $FLAG = 'all_phases' ]; then

  # HTK binaries
  type -P HCompV &>/dev/null || { echo "ERROR: HCompV not found." >&2; }
  type -P HLEd &>/dev/null || { echo "ERROR: HLEd not found." >&2; }
  type -P HHEd &>/dev/null || { echo "ERROR: HHEd not found." >&2; }
  type -P HERest &>/dev/null || { echo "ERROR: HERest not found." >&2; }
  type -P HResults &>/dev/null || { echo "ERROR: HResults not found." >&2; }
  type -P HVite &>/dev/null || { echo "ERROR: HVite not found." >&2; }

  # Required perl scripts
  type -P $DIR_SRC/create_monophone_list.pl &>/dev/null || { echo "ERROR: create_monophone_list.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/create_quests_file.pl &>/dev/null || { echo "ERROR: create_quests_file.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/create_mlf_from_text_files.pl &>/dev/null || { echo "ERROR: create_mlf_from_text_files.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/prune_list_after_alignment.pl &>/dev/null || { echo "ERROR: prune_list_after_alignment.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/make_proto_hmm_set.pl &>/dev/null || { echo "ERROR: make_proto_hmm_set.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/mkclscript.pl &>/dev/null || { echo "ERROR: mkclscript.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/check_every_audio_has_text_and_vv.pl &>/dev/null || { echo "ERROR: check_every_audio_has_text_and_vv.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/check_num_monophone_examples.pl &>/dev/null || { echo "ERROR: check_num_monophone_examples.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/check_transcripts_have_content.pl &>/dev/null || { echo "ERROR: check_transcripts_have_content.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/check_valid_dict_pronunciations.pl &>/dev/null || { echo "ERROR: check_valid_dict_pronunciations.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/check_words_in_dict.pl &>/dev/null || { echo "ERROR: check_words_in_dict.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/create_wordlist.pl &>/dev/null || { echo "ERROR: create_wordlist.pl not found (should be in $DIR_SRC)." >&2; }
  type -P $DIR_SRC/makesp.pl &>/dev/null || { echo "ERROR: makesp.pl not found (should be in $DIR_SRC)." >&2; }
  
  # Required bash scripts
  type -P $DIR_SRC/create_init_models.sh &>/dev/null || { echo "ERROR: create_init_models.sh not found (should be in $DIR_SRC)." >&2; }


  # Other binaries
  type -P htksortdict &>/dev/null || { echo "ERROR: htksortdict not found (maybe you need to compile it from $DIR_SRC?)" >&2; }

  type -P ngram-count &>/dev/null || { echo "WARNING (you only need this if you want to train an ngram language model): ngram-count not in PATH (did you install it? If not, see http://www.speech.sri.com/projects/srilm)" >&2; }
 
  # Binaries required for decoding with Juicer (and building CoLoG) 
  type -P juicer &>/dev/null || { echo "WARNING (you only need this if decoding with juicer): juicer not in PATH (did you install it? See http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }
  type -P gramgen &>/dev/null || { echo "WARNING (you only need this if decoding with juicer): gramgen not in PATH (did you install is? See http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }
  type -P lexgen &>/dev/null || { echo "WARNING (you only need this if decoding with juicer): lexgen not in PATH (did you install is? See http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }
  type -P cdgen &>/dev/null || { echo "WARNING (you only need this if decoding with juicer): cdgen not in PATH (did you install is? See http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }
fi

#============================================================
# Check required lists
#============================================================
if [ $FLAG = 'lists' ] || [ $FLAG = 'all_phases' ]; then
  # Check (a), (b)
  perl $DIR_SRC/check_every_audio_has_text_and_vv.pl $LST_AUDIO_TRN_ORIG $LST_TRANS_TRN_ORIG
  perl $DIR_SRC/check_every_audio_has_text_and_vv.pl $LST_AUDIO_TST_ORIG $LST_TRANS_TST_ORIG

  # Check that transcripts have content (and only one line per file)
  perl $DIR_SRC/check_transcripts_have_content.pl $LST_TRANS_TRN_ORIG
  perl $DIR_SRC/check_transcripts_have_content.pl $LST_TRANS_TST_ORIG

  # Check audio files size
  perl $DIR_SRC/check_feature_obs.pl $LST_AUDIO_TRN_ORIG $MIN_OBS
  perl $DIR_SRC/check_feature_obs.pl $LST_AUDIO_TST_ORIG $MIN_OBS

fi

#============================================================
# Check dict
#============================================================
if [ $FLAG = 'dicts' ] || [ $FLAG = 'all_phases' ]; then
  perl $DIR_SRC/check_valid_dict_pronunciations.pl $DICT

  perl $DIR_SRC/check_words_in_dict.pl $LST_TRANS_TRN_ORIG $DICT
  perl $DIR_SRC/check_words_in_dict.pl $LST_TRANS_TST_ORIG $DICT

  perl $DIR_SRC/check_num_monophone_examples.pl $LST_TRANS_TRN_ORIG $DICT
fi

#============================================================
# Check transcription and dictionary format
#============================================================
if [ $FLAG = 'textformat' ] || [ $FLAG = 'all_phases' ]; then
  perl $DIR_SRC/check_for_things_that_break_htk.pl $LST_TRANS_TRN_ORIG $DICT
  perl $DIR_SRC/check_for_things_that_break_htk.pl $LST_TRANS_TST_ORIG $DICT
fi


echo "Checking done!"
