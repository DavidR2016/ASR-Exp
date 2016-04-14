#!/usr/bin/perl
use warnings;
use strict;

# Make sure that every word has at least one phoneme in its pronunciation

my $dictionary = $ARGV[0];

if ((@ARGV + 0) < 1) {
  print "./check_valid_dict_pronunciations.pl <dictionary>\n";
  exit 1;
}

my %dict;
my @tokens;
my $pron;
my $result = 0;

open DICT, "$dictionary";
while(<DICT>) {
  chomp;
  @tokens = split(/\s+/,$_);
  my $word = shift @tokens;
  if (@tokens == 0) {
    print "ERROR: <$word> has invalid pronunciation\n";
    $result = 1;
  }
  $pron = join " ",@tokens;
  $dict{$word} = $pron;
}
close(DICT);

exit $result;

