#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use open IO => ':encoding(utf8)';

# 1. Read in the aligned files
# 2. Write out all filenames occuring in both aligned mlf and list file

my $list_train_audio = $ARGV[0];
my $list_train_text = $ARGV[1];

if (@ARGV + 0 < 2) {
  print "./check_every_audio_has_text_and_vv.pl <list_audio> <list_transcripts>\n";
  exit 1;
}

my @suffixlist = (".lab", ".txt", ".wav", ".mfc");
my %audio_files;
my %text_files;
my $line;

open LIST_TRAIN, "$list_train_audio";
while (<LIST_TRAIN>) {
  chomp;
  $line = $_;
  my $tmp_file = fileparse($_, @suffixlist);
  $audio_files{$tmp_file} = $line;
}
close(LIST_TRAIN);

open LIST_TEST, "$list_train_text";
while (<LIST_TEST>) {
  chomp;
  $line = $_;
  my $tmp_file = fileparse($_, @suffixlist);
  $text_files{$tmp_file} = $line;
}
close(LIST_TEST);

# Check that every audio file has a transcription
foreach my $audio_file (sort keys %audio_files) {
  if (!exists($text_files{$audio_file})) {
    print "ERROR: <$audio_files{$audio_file}> has no transcription\n";
  }
}

# Check that every text file has audio
foreach my $text_file (sort keys %text_files) {
  if (!exists($audio_files{$text_file})) {
    print "ERROR: <$text_files{$text_file}> has no audio\n";
  }
}
