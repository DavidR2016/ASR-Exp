#!/usr/bin/perl
use warnings;
use strict;
use List::Util 'shuffle';

use open IO => ':encoding(utf8)';
binmode STDOUT, ":utf8";

if (scalar(@ARGV) != 3) {
  print "Usage: ./split.pl <list.txt> <num splits> <dir_out>\n";
  print "\nInfo: Similar to the linux 'split' function. Different in that it\n";
  print "      creates random, balanced lists\n";
  exit 1;
}

my $list = $ARGV[0];
my $num_splits = $ARGV[1];
my $dir_out = $ARGV[2];

my @lines;
open LIST, "$list" or die "Can't open '$list' for reading\n";
while(<LIST>) {
  chomp;
  push @lines,$_;
}
close(LIST);

my @shuffled = shuffle(@lines);

my %lines_per_fold;

my $fold = 1;
foreach my $line (@shuffled) {
  push @{$lines_per_fold{$fold}},$line;
  $fold += 1;
  if ($fold > $num_splits) {
    $fold = 1;
  }
}

my @sorted = sort keys %lines_per_fold;
foreach $fold (@sorted) {
  open FOLD, ">$dir_out/$fold.lst" or die "Can't open '$dir_out/$fold.lst' for writing\n";
  foreach my $line (@{$lines_per_fold{$fold}}) {
    print FOLD "$line\n";
  }
  close(FOLD);
}
