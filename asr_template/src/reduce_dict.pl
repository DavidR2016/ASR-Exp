#!/usr/bin/perl
use warnings;
use strict;

# Confirm that every word in the transcriptions has a corresponding
# pronunciation in the pronunciation dictionary

my $list = $ARGV[0];
my $dictionary = $ARGV[1];

if ((@ARGV + 0) < 2) {
  print "./check_words_in_dict.pl <file_list> <dictionary>\n";
  exit 1;
}

my %dict;
my @tokens;
my $pron;
my %unigrams;

open DICT, " $dictionary";
while(<DICT>) {
  chomp;
  @tokens = split(/\s+/,$_);
  my $word = shift @tokens;
  $pron = join " ",@tokens;
  push @{ $dict{$word} }, $pron;
}
close(DICT);

open LIST, "$list";
while(<LIST>) {
  my $flag = 1;
  my $file;
  chomp ($file = $_);
  open FILE, "$file";
  while (<FILE>) {
    chomp;
    @tokens = split(/\s+/,$_);
    foreach my $word (@tokens) {
      if (!exists($dict{$word})) {
        print "ERROR: <$word> not in dict\n";
        $flag = 0;
      }
      $unigrams{$word} += 1;
    }
  }
  close(FILE);
}
close(LIST);

foreach my $word (sort keys %unigrams) {
  foreach my $pron (@{ $dict{$word} }) {
    print "$word\t$pron\n";
  }
}
