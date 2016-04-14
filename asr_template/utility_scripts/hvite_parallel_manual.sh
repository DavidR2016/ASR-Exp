#!/bin/bash

#TM parallel done manually

LOCAL_LIST_AUDIO=$1 
NUM_PROCS=$2

cd /media/DATA/tmp
mkdir -p hvite_parallel
rm hvite_parallel/*
cd hvite_parallel
perl /home/thipe/hlt/sepedi/asr_template/src/split.pl $LOCAL_LIST_AUDIO $NUM_PROCS /media/DATA/tmp/hvite_parallel
cnt=1
for list in `ls *`
do
  result=$cnt.mlf
  /usr/bin/time --portability --output=hvite.$cnt.time.log HVite -C /media/DATA/nchlt_sepedi/nchlt_sepedi_baseline_1/config/hvite.cfg -A -D -T 1 -V -H /media/DATA/nchlt_sepedi/nchlt_sepedi_baseline_1/models/hmm_39/hmmDefs.mmf -H /media/DATA/nchlt_sepedi/nchlt_sepedi_baseline_1/models/hmm_39/macros -J /media/DATA/nchlt_sepedi/nchlt_sepedi_baseline_1/models/hmm_36 -S /media/DATA/ -t 200 -i /media/DATA/tmp/hvite_parallel/$cnt.mlf -w /media/DATA/dicts/loop.grammar.txt-2 -o N -p 15.5 -s 1.0 /media/DATA/dicts/cs_nso_1.2_all.dict /media/DATA/nchlt_sepedi/nchlt_sepedi_baseline_1/lists/tiedlist.lst 2>&1 > /media/DATA/tmp/hvite_parallel/hvite.$cnt.log &
  cnt=$(($cnt + 1))
done
