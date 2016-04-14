#!/usr/bin/env python

__author__ = "Marelie Davel, Christiaan van der Walt"
__email__  = "mdavel@csir.co.za, cvdwalt@csir.co.za"

"""
Select a randomised speaker-based subset from a given audio and trans list

@param in_audio_list:    List of MFCC filenames to select from
@param in_trans_list:    List of transcription filenames to select from
@param num_male:         Number of male speakers required
@param num_female:       Number of female speakers required
@param out_prefix:       Prefix of files to be created, namely \
<prefix>.audio.train, <prefix>.audio.test, <prefix>.trans.train and <prefix>.trans.test"

Lwazi naming conventions assumed.
If same input, same random sample will always be selected. 
If a different sample is required, set RANDOM_SEED.
"""

import os, sys, re, random

RANDOM_SEED = 0

#------------------------------------------------------------------------------

def generate_subset_lists(in_audio_name, in_trans_name, num_male, num_female, out_prefix):
    """Select matching speaker-based subsets from a given audio and trans list """

    audio_data = read_list(in_audio_name)
    audio_name_format = re.compile(r'.*/(\d+)_.*_(.*)_.*_(\d+)\.mfc')
    (train_data, test_data) = generate_subset(audio_data, num_male, num_female, audio_name_format)
    write_list(train_data, "%s.audio.train" % out_prefix)
    write_list(test_data, "%s.audio.test" % out_prefix)

    trans_data = read_list(in_trans_name)
    trans_name_format = re.compile(r'.*/(\d+)_.*_(.*)_.*_(\d+)\.txt')
    (train_data, test_data) = generate_subset(trans_data, num_male, num_female, trans_name_format)
    write_list(train_data, "%s.trans.train" % out_prefix)
    write_list(test_data, "%s.trans.test" % out_prefix)

#------------------------------------------------------------------------------

def generate_subset(in_list, num_male, num_female, item_format):
    """Select a speaker-based subset from a given list """

    utterance_ids = {}
    speaker_ids = []
    speaker_files= {}        #file names associated with a specific speaker ID
    male_keys = []
    female_keys = []

    #split the filenames and read relevant info into dictionaries according to speaker
    in_list.sort()
    for item in in_list:
        full_name = item.strip()
        matched = item_format.match(full_name)
        if matched:
            spk_id = matched.group(1)
            gender = matched.group(2)
            utt_id = matched.group(3)
        else:
            print "Error: format error in line " + full_name
            exit(1)

        if utterance_ids.has_key(spk_id):
            #speaker already known
            utterance_ids[spk_id].append(utt_id)
            speaker_files[spk_id].append(full_name)
        else:
            #first time the speaker is encountered
            speaker_ids.append(spk_id)
            utterance_ids[spk_id]=[]
            utterance_ids[spk_id].append(utt_id)
            speaker_files[spk_id]=[]
            speaker_files[spk_id].append(full_name)
            if gender == 'male':
                male_keys.append(spk_id)
            elif gender == 'female':
                female_keys.append(spk_id)
            elif gender == 'na':
                print "Warning: unknown gender " + gender
            else:
                print "Error: unknown gender " + gender
                exit(1)

    #Check if enough speakers to proceed
    if len(male_keys) < num_male:
        msg = "Available male speakers (%d) less than size of test set (%d) required" \
            % (len(male_keys), num_male)
        print msg
        exit(1)
    if len(female_keys) < num_female:
        msg = "Available female speakers (%d) less than size of test set (%d) required" \
            % (len(female_keys), num_female)
        print msg
        exit(1)

    #create test set by randomly selecting from full list
    random.seed(RANDOM_SEED)
    male_selected = random.sample(male_keys, num_male)
    female_selected = random.sample(female_keys, num_female)

    test_speakers = list(male_selected)
    test_speakers.extend(female_selected)
    test_files = []
    for spk in test_speakers:
        for fn in speaker_files[spk]:
            #print "Test set: adding %s for spk %s" % (fn,spk)
            test_files.append(fn)

    #create training set by using all remaining speaker IDs
    train_speakers = speaker_ids
    train_files = []
    for spk in test_speakers:
        train_speakers.remove(spk)
    for spk in train_speakers:
        for fn in speaker_files[spk]:
            #print "Train set: adding %s for spk %s" % (fn,spk)
            train_files.append(fn)

    return (train_files, test_files)

#------------------------------------------------------------------------------

def read_list(in_name):
    """Read text from a file into a list."""
    try:
        in_file = open(in_name,"r")
    except IOError:
        print "IOError: Error reading from file " + in_name
        sys.exit(IOError)
    data = []
    for ln in in_file:
        data.append(ln)
    in_file.close()
    return data

#------------------------------------------------------------------------------

def write_list(in_list, out_name):
    """Write a list to file, with each element on a separate line."""

    try:
        out_file = open(out_name,"w")
    except IOError:
        print "IOError: Error writing to file " + out_name
        sys.exit(1)
    for ln in in_list:
        out_file.write(str(ln) + "\n")
    out_file.close()

#------------------------------------------------------------------------------

if __name__ == "__main__":

    if len(sys.argv) == 6:
        in_audio_list = str(sys.argv[1])
        in_trans_list = str(sys.argv[2])
        num_male = int(sys.argv[3])
        num_female = int(sys.argv[4])
        out_prefix = str(sys.argv[5])

        print "Generating subset lists"
        generate_subset_lists(in_audio_list, in_trans_list, num_male, num_female, \
            out_prefix)

    else:
        print "Usage: generate_lwazi_subset_lists.py <in:audio_list> <in:trans_list> \
<num_male> <num_female> <out:prefix>"
        print "       <in:audio_list>  = list of MFCC files to select from"
        print "       <in:trans_list>  = list of transcriptions to select from"
        print "       <num_male>       = number of male speakers required"
        print "       <num_female>     = number of female speakers required"
        print "       <out:prefix>     = create the following files:"
        print "                           <prefix>.audio.train <prefix>.audio.test"
        print "                           <prefix>.trans.train <prefix>.trans.test"
        print "                          containing audio and transcription, train and test sets."
        print "       Lwazi filename format assumed"

#------------------------------------------------------------------------------
