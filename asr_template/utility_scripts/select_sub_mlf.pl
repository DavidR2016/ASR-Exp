#!/usr/bin/perl -w

#--------------------------------------------------------------------------
# Author: Marelie Davel (mdavel@csir.co.za)
#--------------------------------------------------------------------------

use strict;
use warnings;
use open IO => ':encoding(utf8)';

#--------------------------------------------------------------------------

sub print_usage() {
  print "Create a subset MLF from a larger MLF, based on provided IDs.\n";
  print "Usage: select_sub_MLF.pl <in:ID_list> <in:orig_mlf> (in:marker=rec|lab) <out:new_mlf>\n";
  print "       <in:ID_list>   = list of IDs of transcriptions to select\n";
  print "       <in:orig_mlf>  = original MLF (HTK label file)\n";
  print "       rec | lab      = use to indicate the type of MLF (recognised or label)\n";
  print "       <out:new_mlf>  = subset of original\n";
  print "       Warnings are generated if IDs cannot be found.\n";
  print "       Note that label should either be exact match for label name in MLF\n";
  print "       or exact match for basename of label name in MLF\n";
}

#--------------------------------------------------------------------------

sub do_select($$$$) {
  my ($inIDName,$inLabelName,$marker,$outLabelName) = @_;

  open my $inLabels, "<$inLabelName" or die "Cannot open $inLabelName";
  open my $inIDs, "<$inIDName" or die "Cannot open $inIDName";
  open my $outLabels, ">$outLabelName" or die "Cannot open $outLabelName";

  #Read IDs to select
  my %select=();
  while (<$inIDs>) {
    chomp;
    $select{$_}=0;
  }
  close $inIDs;

  #Start new MLF
  print $outLabels "#!MLF!#\n";

  #Select from existing mlf
  my $do_write=0;
  while (<$inLabels>) {
    chomp;
    if (/$marker\"$/) {
      $do_write=0;
      my $name = $_;
      if ($name =~ /\/([^\/]*).$marker\"$/) {
        $name = $1;
      }
      if (exists $select{$name}) {
        #print "$name\n";    
        $select{$name}=1;
        print $outLabels "$_\n";
        $do_write=1;
      }
    } else {
      if ($do_write==1) {
        print $outLabels "$_\n";
      }
    }
  }
  close $inLabels;
  close $outLabels;

  my $cnt=0;
  foreach my $lab (sort keys %select) {
    if ($select{$lab}==0) {
      print "Warning: $lab not found\n";
    } else {
      $cnt++;
    }
  }
  print "Labels selected for $cnt $marker files\n";
}

#--------------------------------------------------------------------------

if (scalar @ARGV==4) {
  if ( ! (($ARGV[2] eq 'rec')||($ARGV[2] eq 'lab')) ) {
    die "Need to specify whether this label file contain recognised lables (rec) or reference labels (lab)\n";
  }
  do_select $ARGV[0],$ARGV[1],$ARGV[2],$ARGV[3];
} else {
  print_usage;
} 

#--------------------------------------------------------------------------

