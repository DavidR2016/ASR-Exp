#!/usr/bin/perl
use warnings;
use strict;

my $dictionary_in  = $ARGV[0];
my $dictionary_out = $ARGV[1];

if ((@ARGV + 0) < 2) {
  print "./add_disambiguation_symbols.pl <in:dict_in> <out:dict_out>\n";
  exit 1;
}

my %dict;
my %prons;
my %disamb;
my @tokens;
my $pron;

open DICT, "$dictionary_in";
open OUT, ">$dictionary_out";
while(<DICT>) {
  chomp;
  @tokens = split(/\s+/,$_);
  my $word = shift @tokens;
  $pron = join " ", @tokens;
  push @{ $dict{$word} },$pron;

  # TODO(Charl): Come up with a cleaner way to handle SENTSTART and SENTEND
  if ($pron ne "sil") {
    $prons{$pron} += 1;
  } else {
    $prons{$pron} = 1;
  }
  $disamb{"$word"."\t$pron"} = $prons{$pron};
}
close(DICT);

foreach my $wordpron (sort keys %disamb) {
  @tokens = split(/\s+/,$wordpron);
  my $word = shift @tokens;
  $pron = join " ",@tokens;
  if ($prons{$pron} > 1) {
    print OUT "$wordpron #$disamb{$wordpron}\n";
  } else {
    print OUT "$word\t$pron\n";
  }
}
close OUT;
