#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use open IO => ':encoding(utf8)';

my $list  = $ARGV[0];
my $mlf   = $ARGV[1];

if ((@ARGV + 0) < 2) {
  print "./create_mlf_from_text_files.pl <text_list> <mlf out>\n";
  print "                                <text_list> - full paths to transcriptions, one file per line\n";
  print "                                <mlf out>   - full path to mlf to be created\n";
  exit 1; 
}

open MLF, ">$mlf";
print MLF "\#\!MLF\!\#\n";

my @tokens;
open LIST, "$list";
while(<LIST>) {
  chomp;
  open FILE, "$_";
  my $fname = fileparse($_);
  $fname =~ s/\.[[:alnum:]]+$/\.lab/g;
  print MLF "\"*/$fname\"\n";
  while(<FILE>) {
    chomp;
    $_ =~ s/(^\s+|\s+$)//g;
    @tokens = split(/\s+/,$_);
    foreach my $token (@tokens) {
      if ($token !~ /^[[:digit:]]/) {
        print MLF "$token\n";
      } else {
        print MLF "\"$token\"\n";
      }
    }
  }
  close(FILE);
  print MLF ".\n";
}
close(LIST);

