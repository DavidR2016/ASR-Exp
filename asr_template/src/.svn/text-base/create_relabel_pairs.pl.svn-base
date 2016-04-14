#!/usr/bin/perl
use warnings;
use strict;

use open IO => ':encoding(utf8)';

my $file_isyms = $ARGV[0];
my $file_out = $ARGV[1];

if((@ARGV + 0) < 1) {
  print "Usage: ./create_relabel_pairs <in:file_isyms> <out:file_isyms_new>\n";
  print "\n       <file_isyms> - isyms\n";
  exit 1;
}

open OUT, ">$file_out";

my %phns;
my $cnt = 0;

open FILE, "$file_isyms";
while(<FILE>) {
  chomp;
  my @tokens = split(/\s+/,$_);
  if (/#/) {
    $phns{$tokens[1]} = 0;
    print "$tokens[1]\t0\n";
  } else {
    $phns{$tokens[1]} = $cnt;
    print "$tokens[1]\t$cnt\n";
    print OUT "$tokens[0]\t$cnt\n";
    $cnt += 1;
  } 
}
close(FILE);
close OUT;
