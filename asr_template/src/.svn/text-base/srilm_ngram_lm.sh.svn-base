#!/bin/bash
# Author: Charl van Heerden (cvheerden@csir.co.za)
#
# Uses sri's lm toolkit to train an ngram language model

LOCAL_TRN_LIST=$1
LOCAL_NGRAM_ORDER=$2
LOCAL_VOCAB=""

EXPECTED_NUM_ARGS=2
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: bash srilm_ngram_lm.sh <list trn> <ngram order>"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "list trn    " "- List of text files to use for training an lm"

  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "ngram order " "- if ngram order=3, a trigram language model will be trained."
  exit 1
fi

# Make sure srilm is installed
type -P ngram-count &>/dev/null || { echo "ERROR: ngram-count not in PATH (did you install it? If not, see http://www.speech.sri.com/projects/srilm)" >&2; }

if [ ! -s $VOCABULARY ]; then
  $LOCAL_VOCAB="-write-vocab $VOCABULARY"
fi

# Create a temporary text file containing text from all files in LOCAL_TRN_LIST
if [ -s $DIR_SCRATCH/lm_text ]; then
  rm $DIR_SCRATCH/lm_text
fi

for i in $(cat $LOCAL_TRN_LIST)
do
  cat $i >> $DIR_SCRATCH/lm_text
done

ngram-count -order $LOCAL_NGRAM_ORDER $LOCAL_VOCAB -lm $GRAMMAR -text $DIR_SCRATCH/lm_text
bash $DIR_SRC/check_exit_status.sh $0 $?
rm $DIR_SCRATCH/lm_text
