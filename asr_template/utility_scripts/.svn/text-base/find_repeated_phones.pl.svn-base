#!/usr/bin/perl -w

#--------------------------------------------------------------------------
# Author: Marelie Davel, mdavel@csir.co.za
# HLT Research Group, CSIR Meraka Institute
# http://www.meraka.org.za/hlt
#--------------------------------------------------------------------------

use g2pVar;
use g2pIO;

use strict;
use warnings;

#--------------------------------------------------------------------------

sub print_usage() {
  print "Determine if two identical phonemes follow one another in an MLF\n";
  print "Usage: find_repeated_phones.pl <in:mlf>  [ <in:txt_dir> ]\n";
  print "       <in:mlf>      = input HTK label file (MLF)\n";
  print "       <in:text_dir> = optional, directory where transcripts are kept that match label file (MLF)\n";
  print "Script assumes that label file has matching .txt transcriptions, using lwazi naming conventions"
}

#--------------------------------------------------------------------------

sub id_double($$$) {
  my ($mlfName,$displayText,$txtDir) = @_;
  open my $inMlf, '<:encoding(utf8)', $mlfName or die "Error reading $mlfName";
  my $name = 'none';
  my $prev = 'none';
  my %cnt = (); 
  while (<$inMlf>) {
    chomp;
    if (/\.lab/) {
      $name = $_;
    }
    if ($prev eq $_) {
      print "Found: $prev $_ \t$name\n";
      if ($displayText ==1) {
        my $txtName = $name;
        $txtName =~ s/^..(.*).lab./$txtDir$1.txt/;
        system "cat $txtName";
      }
      $cnt{$_}++;
    }
    $prev = $_;
  }
  close $inMlf;
  print "Found doubles\n";
  foreach my $p (sort keys %cnt) {
    printf "%s\t%d\n",$p,$cnt{$p};
  }
}

#--------------------------------------------------------------------------

if (scalar @ARGV==2) {
  id_double $ARGV[0],1,$ARGV[1];
} elsif (scalar @ARGV==1) {
  id_double $ARGV[0],0,"";
} else {
  print_usage;
} 

#--------------------------------------------------------------------------

