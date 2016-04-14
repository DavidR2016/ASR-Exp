#!/usr/bin/perl
use warnings;
use strict;

# Check that there are at least 3 examples per monophone in the training set.
# Prints a WARNING if not

# Phones with less than MIN_NUM_EXAMPLES will be printed
my $MIN_NUM_EXAMPLES = 3;

my $list = $ARGV[0];
my $dictionary = $ARGV[1];

if ((@ARGV + 0) < 2) {
  print "./check_num_monophone_examples.pl <file_list> <dictionary>\n\n";
  print "Description\n";
  print "--------------------\n";
  print "  Counts the number of examples of each phone (as per first pronunciation\n";
  print "  in the pron. dict) in the transcriptions. Prints a warning if <= 3 examples\n";
  print "  are seen\n";
  print "  Phones in pronunciation variants are also counted, with warnings printed\n";
  print "  if there phones with <= 3 examples\n\n";
  print "Options:\n";
  print "--------------------\n";
  print "* <file_list>	- list of preprocessed transcriptions\n";
  print "* <dictionary>	- pronunciation dictionary\n";
  exit 1;
}

my %dict;
my %variants;
my %phns;
my %variant_phns;
my @tokens;
my $pron;

open DICT, "$dictionary" or die "Cannot open file <$dictionary>";
while(<DICT>) {
  chomp;
  @tokens = split(/\s+/,$_);
  my $word = shift @tokens;
  # Variants are not considered for this check, so a warning may in rare
  # circumstances be too conservative.
  if (!exists($dict{$word})) {
    push @{ $dict{$word} }, @tokens;
    foreach my $ph (@tokens) {
      $phns{$ph} = 0;
    }
  } else {
    # Add variants separately
    push @{ $variants{$word} }, join " ",@tokens;
    foreach my $ph (@tokens) {
      $variant_phns{$ph} = 0;
    }
  }
}
close(DICT);

open LIST, "$list" or die "Cannot open file <$list>";
while(<LIST>) {
  my $file;
  chomp ($file = $_);
  open FILE, "$file" or die "Cannot open file <$file>";
  while (<FILE>) {
    chomp;
    @tokens = split(/\s+/,$_);
    foreach my $word (@tokens) {
      if (exists($dict{$word})) {
        foreach my $ph (@{ $dict{$word} }) {
	  $phns{$ph} += 1;
	}
      } else {
        print "Warning: <$word> not found in <$dictionary>\n";
      }

      # Check if variants exist. Keep separate phone list
      # Ultra conservative here (only one ph example per word)
      if (exists($variants{$word})) {
        my %temp_phones;
        foreach my $variant (@{$variants{$word}}) {
          my @phones = split(/\s+/,$variant);
          foreach my $ph (@phones) {
            if (!exists($temp_phones{$ph})) {
              $variant_phns{$ph} += 1;
            }
          }
        }
      }
    }
  }
  close(FILE);
}
close(LIST);

foreach my $ph (sort keys %phns) {
  if ($phns{$ph} == 0) {
    print "ERROR: <$ph> has no instances in <$list>, but is in your dictionary (monophone list generated from dictionary)\n";
  } elsif ($phns{$ph} < $MIN_NUM_EXAMPLES) {
    print "WARNING: <$ph> has <$phns{$ph}> instances in <$list>\n";
  }
}

foreach my $ph (sort keys %variant_phns) {
  if (!exists($phns{$ph})) {
    print "ERROR: <$ph> is only ever seen in variants. Monophone trainign is thus impossible! REMOVE this phone, or make sure";
    print " enough variants are upgraded to the primary example to have at least 3 examples.\n";
  }
}
