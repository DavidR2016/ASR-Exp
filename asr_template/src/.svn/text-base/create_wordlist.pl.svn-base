#!/usr/bin/perl
use warnings;
use strict;

use open IO => ':encoding(utf8)';

# Lowercase all transcriptions

my $file_list = $ARGV[0];
my $word_list = $ARGV[1];

if((@ARGV + 0) < 1) {
  print "Usage: ./create_wordlist.pl <file_list> <out:wordlist>\n";
  print "\n       <file_list> - one filename per line\n";
  print "       <word_list> - destination filename for wordlist\n";
  exit 1;
}

my @tokens;
my %words;

open LIST, "$file_list";
while(<LIST>) {
  chomp;
  my $line;
  open FILE_IN, "$_" or die "Error opening file $_";
  while(<FILE_IN>) {
    chomp($line = $_);
    @tokens = split(/\s+/,$line);
    foreach my $token (@tokens) {
      $words{$token} += 1;
    }
  }
  close(FILE_IN);
}
close(LIST);

open FILE_OUT, ">$word_list";
foreach my $word (sort keys %words) {
  printf FILE_OUT "%s\n", $word;
}
close(FILE_OUT);
