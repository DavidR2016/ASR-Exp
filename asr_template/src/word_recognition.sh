#!/bin/bash
# Author: Charl van Heerdern (cvheerden@csir.co.za)

# Create a word loop grammar (TODO: One would typically use a BI or TRIGRAM word model here)
bash $DIR_SRC/loop_grammar.sh $LIST_WORDS_TRN

bash $DIR_SRC/decode.sh $LIST_TIED $GRAMMAR $DICT_SP

# Using HVite to do bigram recognition could be done as follows

# Build a bigram word network
#HBuild -t $SENTSTART $SENTEND $LOCAL_LIST_TOKENS -n $GRAMMAR $DIR_EXP/grammar/loop_grammar.txt
#HBuild -s '<s>' '</s>' -n /home/cvheerden/work/asr/beta/test_data/experiment4/grammar/grammar.txt /home/cvheerden/work/asr/beta/test_data/experiment4/lists/words_trn.lst /home/cvheerden/work/asr/beta/test_data/experiment4/grammar/loop_grammar.txt

# Do recognition using the bigram network
#bash $DIR_SRC/decode.sh $LIST_TIED $DIR_EXP/grammar/loop_grammar.txt $DICT_SP
