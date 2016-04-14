#!/usr/bin/perl
use warnings;
use strict;
use Unicode::Normalize;

use open IO => ':encoding(utf8)';
use open ':std';

my $lst_trans = $ARGV[0];
my $fn_all_trans  = $ARGV[1];

if((@ARGV + 0) != 2) {
  print "Usage: ./cat_all_trans.pl <in:lst_trans> <out:fn_all_trans>\n\n";
  print "Description:\n";
  print "* Prints all transcriptions from a potentially very long list ";
  print "to a single file\n";
  print "* Useful for when a list is too long for cat\n";
  exit 1;
}

# Read in and count all transcriptions from file
# -----------------------------------------------------------------------------
my @trans;
open LIST, "$lst_trans" or die "Can't open '$lst_trans'";
while(<LIST>) {
  chomp;
  open TRANS, "$_" or die "Can't open '$_'\n";
  while (<TRANS>) {
    chomp; 
    $_ = NFC($_);
    push @trans,$_;
  }
  close(TRANS);
}
close(LIST);

# Print transcriptions with counts to file
# -----------------------------------------------------------------------------
open TRANS_OUT, ">$fn_all_trans" or die "Can't open '$fn_all_trans'\n";
foreach my $term (sort @trans) {
  printf TRANS_OUT "%s\n", $term;
}
close(TRANS_OUT);
