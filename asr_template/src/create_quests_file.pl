#!/usr/bin/perl
use warnings;
use strict;

use open IO => ':encoding(utf8)';

#create a questions file for triphone tying from a monophone list
my $monophone_list;
my $quest_file;

($quest_file, $monophone_list) = @ARGV;

if (@ARGV + 0 < 2) {
  print "./create_quests_file.pl <quests_file_out> <monophn_list>\n";
  exit 1;
}

my $ph;
my @elements;
my %monophones;

open IN, "$monophone_list";
while(<IN>) {
  chomp($ph = $_);
  if (($ph ne "sil")&&($ph ne "sp")) {
    $monophones{$ph} = 1;
  }
}
close(IN);

open OUT, ">$quest_file";

foreach $ph (sort keys %monophones) {
  print OUT "QS  \"R_$ph\"\t\t{ *+$ph }\n";
}

foreach $ph (sort keys %monophones) {
  print OUT "QS  \"L_$ph\"\t\t{ $ph-* }\n";
}
close(OUT);
