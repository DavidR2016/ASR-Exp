#!/usr/bin/env python

__author__ = "Marelie Davel"
__email__  = "mdavel@csir.co.za"

"""
Create list of all audio and transcription files

@param mfcc_dir:     Directory with processed audio files (.mfc)
@param trans_dir:    Directory with processed transcriptions (.txt)
@param list_dir      Output directory for audio_all.lst and trans_all.lst
"""

import sys, os.path, fnmatch

#------------------------------------------------------------------------------

def generate_complete_lists(mfcc_dir, trans_dir, list_dir):
    """
    Create list of all audio and transcription files

    @param mfcc_dir:     Directory with processed audio files (.mfc)
    @param trans_dir:    Directory with processed transcriptions (.txt)
    @param list_dir      Output directory for audio_all.lst and trans_all.lst
    """

    audio_out_name = os.path.join(list_dir, "audio_all.lst")
    trans_out_name = os.path.join(list_dir, "trans_all.lst")

    try:
        audio_out = open(audio_out_name,"w")
    except IOError:
        print "Error: unable to write to " + audio_out_name
    for (dir_path, dir_names, file_names) in os.walk(mfcc_dir):
      for file_name in fnmatch.filter(file_names,'*.mfc'):
        audio_out.write(os.path.join(dir_path,file_name) + "\n")
    audio_out.close

    try:
        trans_out = open(trans_out_name,"w")
    except IOError:
        print "Error: unable to write to " + audio_out_name
    for (dir_path, dir_names, file_names) in os.walk(trans_dir):
      for file_name in fnmatch.filter(file_names,'*.txt'):
        trans_out.write(os.path.join(dir_path,file_name) + "\n")
    trans_out.close

#------------------------------------------------------------------------------

if __name__ == "__main__":

    if len(sys.argv) == 4:
        mfcc_dir = str(sys.argv[1])
        trans_dir = str(sys.argv[2])
        list_dir = str(sys.argv[3])
        print "Generating complete lists"
        generate_complete_lists(mfcc_dir, trans_dir, list_dir)
    else:
        print "Usage: generate_complete_lists.py <in:mfcc_dir> <in:trans_dir> <out:list_dir>"
        print "       <in:mfcc_dir>  = directory with processed audio files (.mfc)"
        print "       <in:trans_dir> = directory with processed transcriptions (.txt)"
        print "       <out:list_dir> = output directory for audio_all.lst and trans_all.lst"

#------------------------------------------------------------------------------

