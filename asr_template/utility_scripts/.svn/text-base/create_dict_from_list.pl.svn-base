#!/usr/bin/perl
use warnings;
use strict;
use Unicode::Normalize;

use open IO => ':encoding(utf8)';
use open ':std';

my $fn_trans = $ARGV[0];
my $dict_in  = $ARGV[1];
my $dict_out = $ARGV[2];

if((@ARGV + 0) != 3) {
  print "Usage: ./create_dict_from_list.pl <in:fn_trans> <in:dict> <out:dict>\n\n";
  print "Description:\n";
  print "* Extract pronunciations for all words in a single file from a reference dictionary\n";
  exit 1;
}

# Read in all pronunciations
# -----------------------------------------------------------------------------
my %dict_base;
open DICT_IN, "$dict_in" or die "Can't open '$dict_in'\n";
while(<DICT_IN>) {
  chomp;
  my @tokens = split(/\s+/,$_);
  my $word = shift @tokens;
  my $pron = join " ",@tokens;
  push @{$dict_base{$word}},$pron;
}
close(DICT_IN);

# Read all transcriptions from file and find prons
# -----------------------------------------------------------------------------
my %words;
open TRANS, "$fn_trans" or die "Can't open '$fn_trans'\n";
while (<TRANS>) {
  chomp; 
  $_ = NFC($_);
  my @tokens = split(/\s+/,$_);
  foreach my $word (@tokens) {
    $words{$word} += 1;
  }
}
close(TRANS);

my %dict_new;
foreach my $word (sort keys %words) {
  if (!exists($dict_base{$word})) {
    print "ERROR: '$word' not found in dict:'$dict_in'\n";
    exit 1;
  }

  foreach my $pron (@{$dict_base{$word}}) {
    push @{ $dict_new{$word} }, $pron;
  }
}

# Print new dictionary to file
# -----------------------------------------------------------------------------
open DICT_OUT, ">$dict_out" or die "Can't open '$dict_out'\n";
foreach my $word (sort keys %dict_new) {
  foreach my $pron (@{$dict_new{$word}}) {
    printf DICT_OUT "%s %s\n",$word,$pron;
  }
}
close(DICT_OUT);
