#!/bin/bash

# Add some headings to the output file
#echo -e "The command run was: nice -n 0 .... bash SVM/scripts/run_libsvm_rbf.sh " > time_SVM3.txt

echo -e "The command run was: nice -n 0 .... bash asr/exp/src/system.sh" > time_ASR_ASR.txt
#echo -e "Seconds\t%CPU\tUser(s)\tSystem(s)\tfs-inputs\tfs-outputs\tcs-vol.\tcs-invol.\tD-size(kb)\tAvgMem(kb)\tMaxMem(kb)" >> time_SVM2.txt
echo -e "Seconds\t%Real_hrs\t%real_sec\t%System\t%User\t%CPU\t%Avg_res\t%Max_res\t%Avg_mem\t%fs-inputs\t%fs-outputs" >> time_ASR_ASR.txt
# Repeat timed experiment
for i in `seq 1`; do 
	nice -n 0 /usr/bin/time -o time_ASR_ASR.txt -a -f "%E\t%e\t%S\t%U\t%P\t%t\t%M\t%K\t%I\t%O\t"\
	bash system.sh
done

