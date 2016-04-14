# Author: Charl van Heerden (cvheerden@csir.co.za)
#!/usr/bin/perl
use warnings;
use strict;

# Go through all the transcriptions and the dictionary and check for things
# that are known to break HTK, such ' at the beginning of a word

my $list = $ARGV[0];
my $dictionary = $ARGV[1];

if ((@ARGV + 0) < 2) {
  print "./check_for_things_that_break_htk.pl <file_list> <dictionary>\n";
  exit 1;
}

my %phoneset;

my @tokens;
my $pron;

open DICT, " $dictionary";
while(<DICT>) {
  chomp;
  @tokens = split(/\s+/,$_);
  # remove the word
  shift @tokens;
  foreach my $ph (@tokens) {
    $phoneset{$ph} += 1;
  }
}
close(DICT);

# Now check for phones that will break HTK
foreach my $ph (sort keys %phoneset) {
  if ($ph =~ /[\\`']/) {
    print "ERROR: <$ph> contains one of [\\`'] which may break HTK\n"
  }

  if ($ph =~ /^[0-9]/) {
    print "ERROR: <$ph> starts with a number. May be problematic for HTK\n";
  }
}

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
      # Check each word for invalid tokens
      if ($word =~ /^'/) {
        print "ERROR: <$word> should have \\' You can run PREPROC.sh with default arguments to fix.\n";
      }
    }
  }
  close(FILE);
  
  if ($flag == 0) {
    print "FILE: <$file>\n";
  }
}
close(LIST);
