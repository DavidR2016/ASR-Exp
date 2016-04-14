#!/usr/bin/perl
use warnings;
use strict;

# Confirm that the transcription has content, and at most one line

my $list = $ARGV[0];

if ((@ARGV + 0) < 1) {
  print "./check_transcripts_have_content.pl <file_list>\n";
  exit 1;
}

open LIST, "$list";
while(<LIST>) {
  chomp;
  my $num_lines;
  my $file = $_;
  open FILE, "$file";
  while (<FILE>) {
    chomp;
    $num_lines += 1;
    $_ =~ s/\s+//g;
    if ($_ =~ /^$/) {
      print "ERROR: <$file> is empty\n"; 
    }
  }
  close(FILE);
  if ($num_lines > 1) {
    print "ERROR: <$file> has <$num_lines> lines\n"; 
  }
}
close(LIST);
