import sys

if __name__ == '__main__':
    
    if len(sys.argv) < 2:
        print "Usage: " + sys.argv[0] + " inputfile "
        sys.exit()
      
    trans = open(sys.argv[1],'r')
        
    fileList = []
    frmF = []
    toF = []
    
    for t in trans:
        line = t.strip()
        fileList.append(line)
    
    for f in fileList:
        x = f[12:]
        frmF.append(x + '\n')
    
    for ln in frmF:
    	#print ln,"\t"
    	#for w in ln:
    	#	print ln 
                        
    myF = open('Wordlist.txt','w')
    myF.writelines(l)
    myF.close()
