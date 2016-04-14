#!/usr/bin/perl
use warnings;
use strict;

use open IO => ':encoding(utf8)';

my @dicts;

(@dicts) = @ARGV;

if((@ARGV + 0) < 2) {
  print "Usage: perl create_monophone_list.pl <monophone_list_out> <dict1> <dict2> ... <dictn>\n";
  exit 0;
}

my $monophone_list = $dicts[0];
splice(@dicts,0,1);

my $dict;
my $temp;
my @elements;
my %monophones;

foreach $dict (@dicts) {
  open FILE, "$dict";
  while(<FILE>) {
    chomp($temp = $_);
    @elements = split(/\s+/,$temp);
    shift @elements;
    my $ph;
    foreach $ph (@elements) {
      $monophones{$ph} = 1;
    }
  }
  close(FILE);
}

my @sorted = sort keys %monophones;

my $word;
open FILE, ">$monophone_list";

foreach $word (@sorted) {
  print FILE "$word\n";
}
close(FILE);
