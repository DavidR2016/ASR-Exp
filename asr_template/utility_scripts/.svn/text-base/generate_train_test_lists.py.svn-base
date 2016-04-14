#!/usr/bin/env python

__author__ = "Christiaan van der Walt, Marelie Davel"
__email__  = "cvdwalt@csir.co.za, mdavel@csir.co.za"

"""
Generate transcription and audio lists (complete, train, test) for Lwazi data

@param audio_list:  List of all MFCC files to select from
@param trans_list:  List of all transcriptions to select from
@param out_dir:     Directory where subset lists will be created
@param mfcc_dir:    Optional directory with processed audio files (.mfc), used to generatee <audio_list> if provided"
@param trans_dir:   Optional directory with processed transcriptions (.txt), used to generatee <trans_list> if provided"

The number of test male and female speakers can be specified within the script. The rest of the
data is used for training.

The assumption is made that the filenames in the audio and transcription lists are in the format
    speaker-id_language_gender_phone-type_utterance-no.file_ext
where file_ext is 'wav' or 'mfc'
The gender of a speaker is based on the filename only

Random.seed is intialised to ensure that the audio and transcription lists match
(The specific random seed can be set in generate_.*_subset_lists.py)
"""

import sys, os.path
from generate_complete_lists import generate_complete_lists
from generate_lwazi_subset_lists import generate_subset_lists

#------------------------------------------------------------------------------

NUM_REQUIRED_MALE = 20
NUM_REQUIRED_FEMALE = 20

#------------------------------------------------------------------------------

def generate_lwazi_partitions(audio_list, trans_list, out_dir):

    #First create files in temporary location
    tmp_prefix = os.path.join(out_dir,"tmp_list")
    try:
        generate_subset_lists(audio_list, trans_list, NUM_REQUIRED_MALE, \
            NUM_REQUIRED_FEMALE, tmp_prefix)
    except:
        print "Error generating subset lists - exiting"
        exit(1)

    #Now move to required names
    required_names = ["trans_trn.lst", "trans_tst.lst", "audio_trn.lst", "audio_tst.lst"]
    rename_pairs = {}
    rename_pairs["trans_trn.lst"] = "%s.trans.train" % tmp_prefix
    rename_pairs["trans_tst.lst"] = "%s.trans.test" % tmp_prefix
    rename_pairs["audio_trn.lst"] = "%s.audio.train" % tmp_prefix
    rename_pairs["audio_tst.lst"] = "%s.audio.test" % tmp_prefix


    for to_name in required_names:
        from_name = rename_pairs[to_name]
        to_full_name = os.path.join(out_dir, to_name)
        try:
            os.rename(from_name, to_full_name)
        except:
            print "Error: Error renaming %s to %s" % (from_name, to_full_name)
            sys.exit(1)

#------------------------------------------------------------------------------

if __name__ == "__main__":

    if len(sys.argv) == 4:
        audio_list = str(sys.argv[1])
        trans_list = str(sys.argv[2])
        out_dir = str(sys.argv[3])

        print "Generating train/test lists."
        generate_lwazi_partitions(audio_list, trans_list, out_dir)
        print "List generation complete."

    elif len(sys.argv) == 6:
        audio_list = str(sys.argv[1])
        trans_list = str(sys.argv[2])
        out_dir = str(sys.argv[3])
        mfcc_dir = str(sys.argv[4])
        trans_dir = str(sys.argv[5])

        print "Generating intial lists."
        try:
            generate_complete_lists(mfcc_dir,trans_dir,out_dir)
        except:
            print "Error generating complete lists - exiting"
            exit (1)

        print "Generating train/test lists."
        generate_lwazi_partitions(audio_list, trans_list, out_dir)
        print "List generation complete."

    else:
        print "Usage: generate_lwazi_train_test_lists.py <audio_list> <trans_list> \
<out_dir> [<mfcc_dir>] [<trans_dir>]"
        print "       <audio_list> = list of MFCC files to select from"
        print "       <trans_list> = list of transcriptions to select from"
        print "       <out_dir>    = output directory for subset lists"
        print "       <mfcc_dir>   = optional directory with processed audio files (.mfc)"
        print "                      used to generatee <audio_list> if provided"
        print "       <trans_dir>  = optional directory with processed transcriptions (.txt)"
        print "                      used to generatee <trans_list> if provided"

#------------------------------------------------------------------------------
