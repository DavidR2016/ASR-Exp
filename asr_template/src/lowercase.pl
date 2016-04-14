#!/usr/bin/perl
use warnings;
use strict;

use open IO => ':encoding(utf8)';

# Lowercase all transcriptions

my $file_list = $ARGV[0];

if((@ARGV + 0) < 1) {
  print "Usage: ./lowercase.pl <file_list>\n";
  print "\n       <file_list> - format per line:<file in> <file out>\n";
  print "                   - file in should have only one line of text\n";
  exit 1;
}

my @tokens;
open LIST, "$file_list";
while(<LIST>) {
  chomp;
  @tokens = split(/\s+/,$_);

  my $line;
  open FILE_IN, "$tokens[0]";
  while(<FILE_IN>) {
    chomp($line = $_);
  }
  close(FILE_IN);

  open FILE_OUT, ">$tokens[1]";
  printf FILE_OUT "%s\n", lc $line;
  close(FILE_OUT);
}
close(LIST);
