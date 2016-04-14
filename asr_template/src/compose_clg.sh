#!/bin/bash
# Author: Charl van Heerden (cvheerden@csir.co.za)

LOCAL_C=$1
LOCAL_L=$2
LOCAL_G=$3

SEMIRING=log

EXPECTED_NUM_ARGS=3
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: bash compose_clg.sh <C.fst> <L.fst> <G.fst>"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "C.fst " "- Context dependency transducer (can build using cdgen)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "L.fst " "- Lexicon transducer (can build using lexgen)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "G.fst " "- Grammar transducer (can build using gramgen)"
  exit 1
fi

type -P gramgen &>/dev/null || { echo "ERROR: gramgen not in PATH (did you install it? If not, see http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }
type -P lexgen &>/dev/null || { echo "ERROR: lexgen not in PATH (did you install it? If not, see http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }
type -P cdgen &>/dev/null || { echo "ERROR: cdgen not in PATH (did you install it? If not, see http://juicer.amiproject.org/juicer/). Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/home/cvheerden/local/lib'" >&2; }

# Check that the fst's corresponding symbol tables exist
Cisyms=`echo $LOCAL_C | sed 's/\.fst/\.isyms/g'`
Lisyms=`echo $LOCAL_L | sed 's/\.fst/\.isyms/g'`
Gisyms=`echo $LOCAL_G | sed 's/\.fst/\.isyms/g'`
Cosyms=`echo $LOCAL_C | sed 's/\.fst/\.osyms/g'`
Losyms=`echo $LOCAL_L | sed 's/\.fst/\.osyms/g'`
Gosyms=`echo $LOCAL_G | sed 's/\.fst/\.osyms/g'`

if [ ! -s $Cisyms ] || [ ! -s $Lisyms ] || [ ! -s $Gisyms ]; then
  echo "ERROR: Input symbol table(s) missing!"
  exit 1
fi

if [ ! -s $Cosyms ] || [ ! -s $Losyms ] || [ ! -s $Gosyms ]; then
  echo "ERROR: Output symbol table(s) missing!"
  exit 1
fi

# Process C
echo "Processing C"
LOCAL_FST=$LOCAL_C
fstcompile --arc_type=$SEMIRING --fst_type=const $LOCAL_FST | \
fstarcsort | \
fstconnect | \
fstinvert > $DIR_SCRATCH/tmp.fst
fstencode -encode_labels $DIR_SCRATCH/tmp.fst $DIR_SCRATCH/codex | \
fstdeterminize | \
fstminimize > $DIR_SCRATCH/tmp2.fst
fstencode -decode $DIR_SCRATCH/tmp2.fst $DIR_SCRATCH/codex | \
fstinvert > $DIR_EXP/grammar/Cproc.fst
bash $DIR_SRC/check_exit_status.sh $0 $?
# Cleanup
rm $DIR_SCRATCH/codex
rm $DIR_SCRATCH/tmp.fst
rm $DIR_SCRATCH/tmp2.fst
echo `fstinfo $DIR_EXP/grammar/Cproc.fst | grep "of arcs"`

# Process L
echo "Processing L"
LOCAL_FST=$LOCAL_L
fstcompile --arc_type=$SEMIRING --fst_type=const $LOCAL_FST | \
fstarcsort | \
fstclosure > $DIR_EXP/grammar/Lproc.fst
bash $DIR_SRC/check_exit_status.sh $0 $?
echo `fstinfo $DIR_EXP/grammar/Lproc.fst | grep "of arcs"`

# Process G
echo "Processing G"
LOCAL_FST=$LOCAL_G
fstcompile --arc_type=$SEMIRING --fst_type=const $LOCAL_FST | \
fstarcsort | \
fstdeterminize > $DIR_EXP/grammar/Gproc.fst
bash $DIR_SRC/check_exit_status.sh $0 $?
echo `fstinfo $DIR_EXP/grammar/Gproc.fst | grep "of arcs"`

# Compose LG (LoG)
echo "LoG"
#fstminimize | \
fstcompose $DIR_EXP/grammar/Lproc.fst $DIR_EXP/grammar/Gproc.fst > $DIR_SCRATCH/tmp.fst
fstencode -encode_labels $DIR_SCRATCH/tmp.fst $DIR_SCRATCH/codex | \
fstdeterminize | \
fstminimize | \
fstepsnormalize | \
fstpush --push_weights > $DIR_SCRATCH/tmp2.fst
fstencode -decode $DIR_SCRATCH/tmp2.fst $DIR_SCRATCH/codex | \
fstarcsort > $DIR_SCRATCH/tmp.fst

# Relabel the fst to remove disambiguation symbols
perl $DIR_SRC/create_relabel_pairs.pl $DIR_EXP/grammar/L.isyms $DIR_EXP/grammar/L.isyms.new > $DIR_SCRATCH/relabel_pairs.txt
mv $DIR_EXP/grammar/L.isyms.new $DIR_EXP/grammar/L.isyms
fstrelabel --relabel_ipairs=$DIR_SCRATCH/relabel_pairs.txt $DIR_SCRATCH/tmp.fst | \
fstprint > $DIR_SCRATCH/tmp2.fst

fstcompile --arc_type=$SEMIRING --fst_type=const $DIR_SCRATCH/tmp2.fst | \
fstarcsort > $DIR_EXP/grammar/LG.fst
bash $DIR_SRC/check_exit_status.sh $0 $?
rm $DIR_SCRATCH/codex
rm $DIR_SCRATCH/tmp.fst
rm $DIR_SCRATCH/tmp2.fst

# Compose CLG (CoLG)
echo "CoLG"
fstcompose $DIR_EXP/grammar/Cproc.fst $DIR_EXP/grammar/LG.fst > $DIR_EXP/grammar/CLG.tmp.fst
fstprint $DIR_EXP/grammar/CLG.tmp.fst > $DIR_EXP/grammar/CLG.fst
bash $DIR_SRC/check_exit_status.sh $0 $?

cp $DIR_EXP/grammar/C.isyms $DIR_EXP/grammar/CLG.isyms
cp $DIR_EXP/grammar/G.osyms $DIR_EXP/grammar/CLG.osyms
