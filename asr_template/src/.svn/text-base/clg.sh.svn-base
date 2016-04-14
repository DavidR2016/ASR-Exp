#!/bin/bash
# Author: Charl van Heerden (cvheerden@csir.co.za)
#
# Uses Juicer to do decoding (http://juicer.amiproject.org/juicer/)
# Useful blog: http://nsh.nexiwave.com/2010/05/speech-decoding-engines-part-1-juicer.html

LOCAL_TRN_LIST=$1

EXPECTED_NUM_ARGS=1
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: bash clg.sh "
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "list trn    " "- List of text files to used for training an lm"
  exit 1
fi

# Make sure srilm is installed
type -P juicer &>/dev/null || { echo "ERROR: juicer not in PATH (did you install it? If not, see http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }
type -P gramgen &>/dev/null || { echo "ERROR: gramgen not in PATH (did you install it? If not, see http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }
type -P lexgen &>/dev/null || { echo "ERROR: lexgen not in PATH (did you install it? If not, see http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }
type -P cdgen &>/dev/null || { echo "ERROR: cdgen not in PATH (did you install it? If not, see http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }

# (1) Build G fst (grammar fst)

perl $DIR_SRC/reduce_dict.pl $LOCAL_TRN_LIST $DICT_SP > $DIR_EXP/dictionaries/reduced_dict.dict
perl $DIR_SRC/add_disambiguation_symbols.pl $DIR_EXP/dictionaries/reduced_dict.dict $DIR_EXP/dictionaries/reduced_ambig_dict.dict
mv $DIR_EXP/dictionaries/reduced_ambig_dict.dict $DIR_EXP/dictionaries/reduced_dict.dict

# Add the SENTSTART and SENTEND words to this dict
echo -e "$SENTSTART sil\n$SENTEND sil" >> $DIR_EXP/dictionaries/reduced_dict.dict
bash $DIR_SRC/check_exit_status.sh $0 $?

# For LG composition, we need to sort out homophones. We thus add #n to words having similar pronunciations
perl $DIR_SRC/create_monophone_list.pl $DIR_SCRATCH/monophones.lst $DIR_EXP/dictionaries/reduced_dict.dict

echo "Building G"
gramgen -gramType ngram -lmFName $GRAMMAR -lexFName $DIR_EXP/dictionaries/reduced_dict.dict -fsmFName $DIR_EXP/grammar/G.fst -inSymsFName $DIR_EXP/grammar/G.isyms -outSymsFName $DIR_EXP/grammar/G.osyms -sentStartWord $SENTSTART -sentEndWord $SENTEND
bash $DIR_SRC/check_exit_status.sh $0 $?

echo "Building L"
# Because the dictionary already has a "sp" at the end of every word, it isn't necessary to define -pauseMonophone
lexgen -lexFName $DIR_EXP/dictionaries/reduced_dict.dict  -monoListFName $DIR_SCRATCH/monophones.lst -fsmFName $DIR_EXP/grammar/L.fst -inSymsFName $DIR_EXP/grammar/L.isyms -outSymsFName $DIR_EXP/grammar/L.osyms -sentStartWord $SENTSTART -sentEndWord $SENTEND
bash $DIR_SRC/check_exit_status.sh $0 $?

echo "Building C"
# TODO(Charl): Add semitied transforms functionality to Juicer
cdgen -htkModelsFName $DIR_EXP/models/hmm_33/hmmDefs.mmf -tiedListFName $LIST_TIED -monoListFName $LIST_MONOPHNS_SP -fsmFName $DIR_EXP/grammar/C.fst -inSymsFName $DIR_EXP/grammar/C.isyms -outSymsFName $DIR_EXP/grammar/C.osyms -cdSepChars -+ -cdType xwrdtri -silMonophone "sil" -pauseMonophone "sp"
# Don't add this now, since we want to remove the disambiguation symbols from LG before composing with C
#-lexInSymsFName $DIR_EXP/grammar/L.isyms
bash $DIR_SRC/check_exit_status.sh $0 $?

#juicer -writeBinaryFiles -sentStartWord "<s>" -sentEndWord "</s>" -mainBeam 50 -tiedListFName lists/tiedlist.lst -cdSepChars +- -inputFormat htk -lexFName reduced_dict.dict -inputFName train.lst -fsmFName final.fst -inSymsFName final.isyms -outSymsFName final.osyms -htkModelsFName models/hmm_33/hmmDefs.mmf
