#!/bin/bash
# Author: Charl van Heerdern (cvheerden@csir.co.za)

# Create a phn loop grammar
bash $DIR_SRC/loop_grammar.sh $LIST_MONOPHNS

# Create a monophone dictionary (ph ph)
cat $LIST_MONOPHNS | sed '/sp/d' | awk '{print $1 "\t" $1}' > $DIR_SCRATCH/mono.dict.tmp
echo -e "$SENTSTART [] sil\n$SENTEND [] sil" >> $DIR_SCRATCH/mono.dict.tmp
cat $DIR_SCRATCH/mono.dict.tmp | sort -u > $DIR_EXP/dictionaries/mono.decode.dict
rm $DIR_SCRATCH/mono.dict.tmp

bash $DIR_SRC/decode.sh $LIST_TIED $GRAMMAR $DIR_EXP/dictionaries/mono.decode.dict
