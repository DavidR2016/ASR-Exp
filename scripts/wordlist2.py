#!/usr/bin/python

import sys, os, shutil, time, csv, string, codecs


def getList(transcription_dir):
    """
    Read and clean word list
    """
  
    punctuation = [".",",","'","!","-","?",";","[n]","[s]","[um]"]
    words = []
    
    
    speaker_dirs = os.listdir(transcription_dir)
    ordered_speaker_dirs = []
    for spkdir in speaker_dirs:
	#print spkdir
        if ".svn" not in spkdir:
            ordered_speaker_dirs.append([int(spkdir[1]),spkdir])
            ordered_speaker_dirs.sort(key=lambda x:x[0],reverse=False)

    for item in ordered_speaker_dirs:
        speaker_files = os.listdir(os.path.join(transcription_dir,item[1]))      

        ordered_speaker_files = []
        for spkfile in speaker_files:
            if ".svn" not in spkfile:
		#print spkfile[0:13]
                ordered_speaker_files.append([int(spkfile[0:19].split("_")[2]),spkfile])
        ordered_speaker_files.sort(key=lambda x:x[0],reverse=False)
	
        for sfile in ordered_speaker_files:
	
            if sfile[1].split(".")[-1] == "txt": #is transcription file
                
                file_handle = codecs.open(os.path.join(transcription_dir,item[1],sfile[1]),"r","utf-8")
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
