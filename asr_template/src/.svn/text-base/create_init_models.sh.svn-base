#!/bin/bash
#Author: Neil Kleynhans (ntkleynhans@csir.co.za)
# x

#Check if monophones.lst exists
if [ ! -f $LIST_MONOPHNS ]; then
    echo "ERROR ($0): Cannot find monophone list file: " $LIST_MONOPHNS
    exit 1;
fi

if [ -f $DIR_HMM_CURR/hmmDefs.mmf ]; then
    rm $DIR_HMM_CURR/hmmDefs.mmf
fi

Skip="+1"

for monoph in $(cat $LIST_MONOPHNS | sort); do
    echo "Adding model:" $monoph

    cat $PROTO_SET | tail -n $Skip | sed 's/proto/'$monoph'/g' >> $DIR_HMM_CURR/hmmDefs.mmf

    if [ $Skip = "+1" ]; then
        # Create macros files
        cat $PROTO_SET | head -n 3 > $DIR_HMM_CURR/macros
        cat $VFLOORS >> $DIR_HMM_CURR/macros
        Skip="+4"
    fi
done

