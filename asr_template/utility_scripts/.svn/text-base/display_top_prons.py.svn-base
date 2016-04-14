#!/usr/bin/env python

__author__ = "Marelie Davel"
__email__  = "mdavel@csir.co.za"

"""
Display the dictionary pronunciations of the most frequent words occuring in a speech corpus

@param in_trans_list:    List of transcription filenames
@param in_dict:          Pronunciation dictionary
@param top_n:            Number of words to verify
@param out_name:         Name of output file for results
"""

import sys, operator, codecs

#------------------------------------------------------------------------------

def display_top_prons(trans_list_name, dict_name, top_n, out_name):
    """Display the dictionary pronunciations of the most frequent words occuring in a speech corpus"""

    #Read dictionary
    pron_dict = {}
    try:
        dict_file = codecs.open(dict_name,"r","utf8")
    except IOError:
        print "Error: Error reading from file " + dict_name
        sys.exit(1)
    for ln in dict_file:
        ln = ln.strip()
        parts = ln.split("\t")
        if len(parts) != 2:
            print "Error: dictionary format error line %s" % ln
        word = parts[0]
        pron = parts[1]
        if pron_dict.has_key(word):
            pron_dict[word].append(pron)
        else:
            pron_dict[word] = []
            pron_dict[word].append(pron)
    dict_file.close()

    #Read and cnt words in transcriptions
    counts = {}
    try:
        list_file = codecs.open(trans_list_name,"r","utf8")
    except IOError:
        print "Error: Error reading from file " + trans_list_name
        sys.exit(1)
    for trans_name in list_file:
        trans_name = trans_name.strip()
        try:
            trans_file = codecs.open(trans_name,"r","utf8")
        except IOError:
            print "Error: Error reading from file " + trans_name
            sys.exit(1)
        for ln in trans_file:
            ln = ln.strip()
            parts = ln.split(" ")
            for word in parts:
                if counts.has_key(word):
                    counts[word] = counts[word]+1
                else:
                    counts[word] = 1
        trans_file.close()
    list_file.close()

    #Now write top pronunciations to file
    try:
        out_file = codecs.open(out_name,"w","utf8")
    except IOError:
        print "Error: Error writing to file " + out_name
        sys.exit(1)
    top_words = sorted(counts.items(),key=operator.itemgetter(1),reverse=True)
    n = 0;
    for (w,c) in top_words:
        if n < top_n:
            if pron_dict.has_key(w):
                for var_pron in pron_dict[w]:
                    out_file.write("%d\t%-20s\t%s\n" % (c,w,var_pron) )
                n = n+1
            else:
                print "Error: unknown word %s" % word
        else:
            break
    out_file.close()


#------------------------------------------------------------------------------

if __name__ == "__main__":

    if len(sys.argv) == 5:
        trans_list_name = str(sys.argv[1])
        dict_name = str(sys.argv[2])
        top_n = int(sys.argv[3])
        out_name = str(sys.argv[4])

        print "Displaying the %d most frequent words" % top_n
        display_top_prons(trans_list_name, dict_name, top_n, out_name)

    else:
        print "\nDisplay the dictionary pronunciations of the most frequent words in a speech corpus."
        print "Usage: display_top_prons.py <in:trans_list> <in:dict> <n> <out:results>"
        print "       <in:trans_list>  list of transcription filenames"
        print "       <in:dict>        pronunciation dictionary"
        print "       <n>              number of words to verify"
        print "       <out:results>    name of output file for results"

#------------------------------------------------------------------------------
