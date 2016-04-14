#!/usr/bin/python

import sys, os, shutil, time, csv, string, codecs


def getList(transcription_dir):
    """
    Read and clean word list
    """
  
    punctuation = [".",",","!","?",";","[n]","[s]","[um]"]
    words = []
    
    
    speaker_dirs = os.listdir(transcription_dir)
    ordered_speaker_dirs = []
    for spkdir in speaker_dirs:
	#print spkdir
        if ".svn" not in spkdir:
            ordered_speaker_dirs.append(spkdir)
            ordered_speaker_dirs.sort(key=lambda x:x[0],reverse=False)
    
    #print ordered_speaker_dirs

    ordered_speaker_files = []

    for item in ordered_speaker_dirs:	
        ordered_speaker_files.append(item)
        ordered_speaker_files.sort(key=lambda x:x[0],reverse=False)	

#    print ordered_speaker_files
	
    for sfile in ordered_speaker_files:
	file_handle = codecs.open(os.path.join(transcription_dir,sfile),"r","utf-8")

	for line in file_handle:
		raw_words = line.strip().split()
		    
                for word in raw_words:
                    #Remove punctiation
                    for symbol in punctuation:
                        if symbol in word:
                            word = string.replace(word, symbol, '') #delete symbol from word
                    if word not in words:
                    	words.append(word)  
	file_handle.close()
	
  
    #Clean up
    while "" in words:
        words.remove("")
    print "done"
    return words
    
def generateOutput(output_file, words):
    """
    Output all words in system classified according to wordlists
    """
    
    file_handle = codecs.open(output_file,"w","utf-8")
    for word in words:
        file_handle.write(word+"\n")
    file_handle.close()

    
if __name__ == "__main__":
    if len(sys.argv) < 2:
            print "USAGE: wordlist.py [transcription directory] [output file]"
            sys.exit(0)

    transcription_dir = sys.argv[1]
    output_file = sys.argv[2]
    
    words = getList(transcription_dir)
    generateOutput(output_file, words)
