#!/bin/bash
# Author: Charl van Heerdern (cvheerden@csir.co.za)
#
# Create a simple loop grammar for HVite

LOCAL_LIST_TOKENS=$1

EXPECTED_NUM_ARGS=1
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: ./loop_grammar.sh <loop items>"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "loop items  " "- Text file with tokens that should be in your vocabulary (one item per line)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- $SENTSTART will be used as sentence start token, and $SENTEND as sentence end"
  exit 1
fi

mkdir -p $DIR_EXP/models/grammar
HBuild -t $SENTSTART $SENTEND $LOCAL_LIST_TOKENS $GRAMMAR
bash $DIR_SRC/check_exit_status.sh $0 $?
