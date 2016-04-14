#!/usr/bin/perl

# Author: Neil Kleynhans (ntkleynhans@csir.co.za)

# $SCP_FILE ($ARGV[0]) = file containg list of parameter files
# $MIN_OBS ($ARGV[1]) = minimum number of observations (set in Vars.sh)

$SCP_FILE=$ARGV[0];
$MIN_OBS=$ARGV[1];

open(DAT, $SCP_FILE) || die("Could not open file: $SCP_FILE");
@raw_data=<DAT>;

foreach $pFile (@raw_data) {
    chomp($pFile);
    $cmd="HList -t -z $pFile | grep 'Num Samples' | awk {'print \$3'}";
    $result=`$cmd`;
    if ($result < $MIN_OBS) {
	print "WARNING: $pFile does not surpass the minimum required number of observations($MIN_OBS): $result\n"
    }
}

