#!/usr/bin/python

#Author : Manaileng Mabu
#Email  : manailengmj@gmail.com
#Tell   : +27152682243
#Cell   : +27798595080

import sys
import os

###########################################################################
def checkFile():
	if os.path.exists('words_dict.txt'):
		print "",
	else:
		print "ERROR: words dictionary could not be located!!"
		sys.exit()

##########################################################################
def openFile():
	words = []
	wDict = open('words_dict.txt','r')
	
	for ln in wDict:
		wrd = ln.strip()
		words.append(ln)
	return words

##########################################################################
def checkS(strn):
	words = openFile()	
	
	inc = 0
	for w in words:
		if strn in w:
			print "\'", strn, "\'", " is a permissable word"
			inc = 1
			break
	if inc == 0:
		print "\'", strn, "\'", " is not a permissable word"
		pos = suggest(strn)		
		print "Did you mean ", pos, " ?"

##########################################################################
def suggest(w):
	posbls = []

	return w	
	

##########################################################################
if __name__ == '__main__':
	
	if len(sys.argv) < 2:
		print "usage: speller.py string"
        	sys.exit()
    	
	checkFile()

    	strn = sys.argv[1]

    	checkS(strn)
