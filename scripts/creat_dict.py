#!/usr/bin/python

#Author : Manaileng Mabu
#Email  : manailengmj@gmail.com
#Tell   : +2715 268 2243
#Cell   : +2779 859 5080

import sys

def createDict(inFile):
	wordList = []
    	flst = []
    	wrd = ""
    
    	for ln in inFile:
        	line = ln.strip()
        	wordList.append(line)
        
	for wrd in wordList:
    		chars = ''
    		word = wrd
    		#print word
    		for char in wrd:
    			chars = chars + char + ' '
    			#print chars,
    		word = word +'\t\t\t' + chars
    		#print word
    		flst.append(word + '\n')	     
                
    	toF = open('Dict.txt','w')
    	toF.writelines(flst)
    	toF.close()

if __name__ == '__main__':
        
    if len(sys.argv) < 2:
        print "Usage: " + str(sys.argv[0]) + " inputfile (.txt)"
        sys.exit()
      
    inFile = open(sys.argv[1],'r')
        
    createDict(inFile)
