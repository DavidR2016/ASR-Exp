import sys

if __name__ == '__main__':
    
    if len(sys.argv) < 2:
        print "Usage: " + sys.argv[0] + " inputfile "
        sys.exit()
      
    trans = open(sys.argv[1],'r')
        
    fileList = []
    l = []
    
    for t in trans:
        line = t.strip()
        fileList.append(line)
    
    for f in fileList:
        x = f[:7]
        y = f[12:]
        #print x," ",y
        l.append(x + "  " + y + '\n')
                
    toF = open('promptList.txt','w')
    toF.writelines(l)
    toF.close()
