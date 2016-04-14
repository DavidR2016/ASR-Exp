import sys
import shutil

if __name__ == '__main__':
    
    if len(sys.argv) < 2:
        print "Usage: " + sys.argv[0] + " inputfile"
        sys.exit()
      
    lst = open(sys.argv[1],'r')
    
    fileList = []
    
    for t in lst:
        line = t.strip()
        fileList.append(line)
    
    for f in fileList:
        dst = f + '.wav'
	print dst
        shutil.copy2(dst, 'audio')
