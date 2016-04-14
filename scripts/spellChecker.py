#!/usr/bin/python

import enchant
import sys

def checkS(strn):
    checker = enchant.Dict("en_US")

    if checker.check(strn):
        print "\'",strn,"\' is a correct word"
    else:
        print "\'",strn,"\' is not a correct word"
        print "Possible correct words"
        for w in checker.suggest(strn):
            print w.strip(),

if __name__ == '__main__':

    if len(sys.argv) < 2:
        print "usage: spellChecker.py string"
        sys.exit()

    strn = sys.argv[1]

    checkS(strn)
