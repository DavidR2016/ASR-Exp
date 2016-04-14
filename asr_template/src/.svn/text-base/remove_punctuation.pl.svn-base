#!/usr/bin/perl
use warnings;
use strict;

use open IO => ':encoding(utf8)';

# Lowercase all transcriptions

my $file_list = $ARGV[0];
my $file_punc = $ARGV[1];

if((@ARGV + 0) < 2) {
  print "Usage: ./remove_punctuation.pl <file_list> <punc_list>\n";
  print "\n       <file_list> - format per line:<file in> <file out>\n";
  print "                   - file in should have only one line of text\n";
  print "\n       <punc_list> - format per line:\"change from\";\"change to\"\n";
  exit 1;
}

my %punctuation;
my @original_order;

open PUNC, "$file_punc";
while(<PUNC>) {
  chomp;
  /^\"([[:print:]]+)\";\"([[:print:]]*)\"\s*$/;
  $punctuation{$1} = $2;
  push @original_order, $1;
}
close(PUNC);

my @tokens;
open LIST, "$file_list";
while(<LIST>) {
  chomp;
  @tokens = split(/\s+/,$_);

  my $line;
  my @lines;
  open FILE_IN, "$tokens[0]";
  while(<FILE_IN>) {
    chomp($line = $_);
    
    # remove control characters
    $line =~ s/[[:cntrl:]]/ /g;

    foreach my $punc (@original_order) {
      $line =~ s/\Q$punc\E/$punctuation{$punc}/g;
    }
    
    $line =~ s/\s+/ /g;
    $line =~ s/(^\s+|\s+$)//g;
    push @lines,$line;
  }
  close(FILE_IN);

  open FILE_OUT, ">$tokens[1]";
  foreach $line (@lines) {
    printf FILE_OUT "%s\n", $line;
  }
  close(FILE_OUT);
}
close(LIST);
