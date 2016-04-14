#!/usr/bin/perl
use warnings;
use strict;
use Unicode::Normalize;

use open IO => ':encoding(utf8)';
use open ':std';

my $fn_trans 		= $ARGV[0];
my $fn_audio_tst	= $ARGV[1];
my $fn_trans_tst	= $ARGV[2];
my $fn_200_audio_tst 	= $ARGV[3];
my $fn_200_trans_tst 	= $ARGV[4];

if((@ARGV + 0) != 5) {
  print "Usage: ./select_tst_terms_from_dict.pl <in:test_terms> <in:audio_tst.lst> <in:trans_tst.lst> <out:200_test_audio_tst.lst> <out:200_test_trans_tst.lst>\n\n";
  print "Description:\n";
  print " * if you have a list of terms and want all those filenames for which the transcription corresponds to one of the terms\n";
  exit 1;
}

# Read all transcriptions from file
# -----------------------------------------------------------------------------
my %terms;
open TRANS, "$fn_trans" or die "Can't open '$fn_trans'\n";
while (<TRANS>) {
  chomp; 
  $_ = NFC($_);
  $terms{$_} += 1;
}
close(TRANS);

# Read audio from file
# -----------------------------------------------------------------------------
my %audio_files;
my %trans_files;
open AUDIO_IN, "$fn_audio_tst" or die "Can't open '$fn_audio_tst'\n";
while(<AUDIO_IN>) {
  chomp;
  my @tokens = split(/\//,$_);
  my $fn = pop @tokens;
  $fn =~ s/\.[a-z0-9A-Z]+$//g;
  $audio_files{$fn} = $_;
}
close(AUDIO_IN);

# Print those tst instances which correspond to the test terms to file
# -----------------------------------------------------------------------------
open AUDIO_OUT, ">$fn_200_audio_tst" or die "Can't open '$fn_200_audio_tst' for writing\n";
open TRANS_IN,  "$fn_trans_tst" or die "Can't open '$fn_trans_tst'\n";
open TRANS_OUT, ">$fn_200_trans_tst" or die "Can't open '$fn_200_trans_tst' for writing\n";
while(<TRANS_IN>) {
  chomp;
  my $fn = $_;
  open TRANS, "$fn" or die "Can't open '$fn'\n";
  my $trans;
  while (<TRANS>) {
    chomp($trans = $_);
  }
  close(TRANS);
  if (exists($terms{$trans})) {
    my @tokens = split(/\//,$fn);
    my $part = pop @tokens;
    $part =~ s/\.[a-z0-9A-Z]+$//g;
    if (!exists($audio_files{$part})) {
      print "ERROR: '$part' not found in '$fn_audio_tst'\n";
      exit 1;
    } 
    print TRANS_OUT "$fn\n";
    printf AUDIO_OUT "%s\n",$audio_files{$part};
  }
}
close(TRANS_IN);
close(TRANS_OUT);
