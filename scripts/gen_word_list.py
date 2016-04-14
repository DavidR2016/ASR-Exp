#!/usr/bin/python

#Author : Manaileng Mabu
#Email  : manailengmj@gmail.com
#Tell   : +27152682243
#Cell   : +27798595080

import sys


def genWordList1(wordList):
	for word in wordList:
		inc = 0
		for c in word:		
			if c != '\t':
				inc = inc + 1
			else:
				break
		wrd = word[:inc]
		lst.append(wrd)
	
	return lst

def genWordList2(lst):
	
	flst = []	
	
	for word in lst:
		wrd = word[:20]
		flst.append(wrd + '\n')
	
	return flst


if __name__ == '__main__':
	
	
    if len(sys.argv) < 2:
        print "Usage: " + sys.argv[0] +" inputfile "
        sys.exit()
      
    inFile = open(sys.argv[1],'r')
        
    wordList = []
    lst = []
    flst = []
    wrd = ""
    
    for ln in inFile:
        line = ln.strip()
        wordList.append(line)
    
    lst = genWordList1(wordList)
     
    flst = genWordList2(lst)
                
    toF = open('WordsList.txt','w')
    toF.writelines(flst)
    toF.close()
