#!/bin/bash

#--------------------------------------------------------------------------
# Author: Marelie Davel (marelie.davel@gmail.com)
#--------------------------------------------------------------------------

# Select matching MLFs prior to results evaluation:
# - in recognised & reference MLF
# - only in recognised MLF
# - only in reference MLF

#TODO: Form of Vars.sh for utility scripts still required
DIR_ASR_TEMPLATE=~/hlt/asr/asr_template

#--------------------------------------------------------------------------

EXPECTED_NUM_ARGS=3
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Select matching MLFs prior to results evaluation"
  echo "Usage: ./select_matching_mlfs.sh <in:rec_mlf> <in:ref_mlf> <out:prefix>"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "rec_mlf         " "- recognised MLF"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "ref_mlf         " "- reference MLF"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "prefix          " "- results prefix"
  echo "       Find items ocurring in both MLFs, as well as missing items"
  echo "       Currently assumes recognised items labelled .rec and reference items labelled .lab"
  echo "       Output: <prefix>.labels.rec"
  echo "               <prefix>.labels.ref"
  echo "               <prefix>.labels.rec_found_in_ref"
  echo "               <prefix>.labels.ref_found_in_rec"
  echo "               <prefix>.labels.rec_missing_from_ref"
  echo "               <prefix>.labels.ref_missing_from_rec"
  echo "               <prefix>.rec_found_in_ref.mlf"
  echo "               <prefix>.ref_found_in_rec.mlf"
  exit $E_BAD_ARGS
fi

rec_mlf=$1
ref_mlf=$2
out=$3

#--------------------------------------------------------------------------

  # Create label files
  grep "\.rec\"" $rec_mlf | gawk -F "/" '{print $NF}' | sed 's/\.rec\"$//' | sort -u > $out.labels.rec
  grep "\.lab\"" $ref_mlf | gawk -F "/" '{print $NF}' | sed 's/\.lab\"$//' | sort -u > $out.labels.ref

  # Create MLFs for matching files
  $DIR_ASR_TEMPLATE/utility_scripts/select_sub_mlf.pl $out.labels.rec $ref_mlf lab $out.rec_found_in_ref.mlf | grep Warning | cut -d" " -f2 | sort > $out.labels.rec_missing_from_ref
  $DIR_ASR_TEMPLATE/utility_scripts/select_sub_mlf.pl $out.labels.ref $rec_mlf rec $out.ref_found_in_rec.mlf | grep Warning | cut -d" " -f2 | sort > $out.labels.ref_missing_from_rec

  # Create label files for matching files
  grep "\.rec\"" $out.ref_found_in_rec.mlf | gawk -F "/" '{print $NF}' | sed 's/\.rec\"$//' | sort > $out.labels.ref_found_in_rec
  grep "\.lab\"" $out.rec_found_in_ref.mlf | gawk -F "/" '{print $NF}' | sed 's/\.lab\"$//' | sort > $out.labels.rec_found_in_ref

#--------------------------------------------------------------------------

