#!/bin/bash

# Create test grammar from prompts
grammar="\$grammar ="
while read line; do tmp=`echo $line | sed 's/^[[:digit:]]\+\s\+//g' | sed 's/$/ |/g'`;grammar="$grammar $tmp"; done < /home/thipe/hlt/sepedi/asr_template/experiment_template/nchlt_loop_grammar/wordlist.txt
while read line; do echo $line | sed 's/^[[:digit:]]\+\s\+//g'; done < /home/thipe/hlt/sepedi/asr_template/experiment_template/nchlt_loop_grammar/wordlist.txt > /home/thipe/hlt/sepedi/asr_template/experiment_template/nchlt_loop_grammar/wordlist.no_counts
grammar=`echo $grammar | sed 's/ |$/;/g'`
echo $grammar > /home/thipe/hlt/sepedi/asr_template/experiment_template/nchlt_loop_grammar/wordlist_grammar.txt
echo "( SENT-START \$grammar SENT-END )" >> /home/thipe/hlt/sepedi/asr_template/experiment_template/nchlt_loop_grammar/wordlist_grammar.txt
# TODO: Check for characters which break HParse?
HParse /home/thipe/hlt/sepedi/asr_template/experiment_template/nchlt_loop_grammar/wordlist_grammar.txt /home/thipe/hlt/sepedi/asr_template/experiment_template/nchlt_loop_grammar/wordlist.loop_grammar.txt
