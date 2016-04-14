#!/bin/bash

#Simple script that creates .led file that merges repeated phonemes

gawk '{printf"ME %s %s %s\n",$1,$1,$1}' < $LIST_MONOPHNS > $LED_MERGE

