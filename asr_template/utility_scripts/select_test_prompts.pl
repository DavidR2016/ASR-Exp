#!/usr/bin/perl
use warnings;
use strict;
use Unicode::Normalize;

use open IO => ':encoding(utf8)';
use open ':std';

my $CNT_LOWER = 20;
my $CNT_UPPER = 180;
srand(123);

my $fn_all_trans = $ARGV[0];
my $fn_test_set  = $ARGV[1];

if((@ARGV + 0) != 2) {
  print "Usage: ./select_test_prompts.pl <in:fn_all_trans> <out:fn_test_set>\n";
  print "       <in:fn_all_trans> - single file containing all transcriptions (one transcription per line, no counts)\n";
  print "       <out:fn_test_set> - filename with counts[tab]transcription\n\n";
  print "	'Random' selection - change srand for 'real' random behaviour; currently constant seed\n";
  print "\nDescription:\n";
  printf " * Selects '%d' terms; '%d' from the range of terms occuring once or twice,\n",$CNT_LOWER+$CNT_UPPER, $CNT_LOWER;
  printf "   and '%d' from the range of counts > 2 (see CNT_LOWER and CNT_UPPER in script)\n",$CNT_UPPER;
  printf " * term = complete transcription of one spoken utterance\n";
  printf " * expects preprocessed transcriptions\n";
  exit 1;
}

# Read in and count all transcriptions from file
# -----------------------------------------------------------------------------
my %trans;
open TRANS, "$fn_all_trans" or die "Can't open '$fn_all_trans'";
while(<TRANS>) {
  chomp;
  $_ = NFC($_);
  $trans{$_} += 1;
}
close(TRANS);

# Select $CNT_LOWER examples from transcriptions with counts 1 & 2
# -----------------------------------------------------------------------------
my @lower;
my @upper;
foreach my $prompt (keys %trans) {
  if ($trans{$prompt} == 1 or $trans{$prompt} == 2) {
    push @lower,$prompt;
  } else {
    push @upper,$prompt;
  }
}

my @selected;
my @rand_lower = shuffle(@lower);
foreach my $i (0..($CNT_LOWER - 1)) {
  push @selected,$rand_lower[$i];
}

# Select $CNT_UPPER examples from transcriptions with counts 3-N
# -----------------------------------------------------------------------------
my @rand_upper = shuffle(@upper);
foreach my $i (0..($CNT_UPPER - 1)) {
  push @selected,$rand_upper[$i];
}

# Write prompts to file
# -----------------------------------------------------------------------------
open TEST_PROMPTS, ">$fn_test_set" or die "Can't open '$fn_test_set'\n";
foreach my $prompt (@selected) {
  printf TEST_PROMPTS "%d\t%s\n",$trans{$prompt}, $prompt;
}
close(TEST_PROMPTS);

sub shuffle {
  my @a=\(@_);
  my $n;
  my $i=@_;
  map {
    $n = rand($i--);
    (${$a[$n]}, $a[$n] = $a[$i])[0];
  } @_;
}
