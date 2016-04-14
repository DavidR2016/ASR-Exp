#!/usr/bin/perl -w

#--------------------------------------------------------------------------
# Author: Marelie Davel (mdavel@csir.co.za)
#--------------------------------------------------------------------------

use strict;
use warnings;
use open IO => ':encoding(utf8)';

my @markers = ( 'n', 's', 'um', 'clean' );
#Apart from 'clean', all other markers $m are identified in the form \[$m\]
#'clean' a default value, if no other markers found

#--------------------------------------------------------------------------

sub print_usage() {
  print "Create lists of noisy speech based on transcription noise markers.\n";
  print "Count noise markers in transcriptions.\n";
  print "Usage: id_noise.pl <in:file_list> <in:trans_dir> <out:prefix>\n";
  print "       <in:file_list> = list of file names\n";
  print "       <in:trans_dir> = dir of original transcriptions\n";
  print "       <out:prefix>.<marker> = list of filanames per category\n";
  print "Counts are displayed to STDOUT.\n";
  print "Script assumes HLT in-house directory setup - fix to match own.\n";
}

#--------------------------------------------------------------------------

sub do_count($$$) {
  my ($inListName,$inDirName,$prefix) = @_;


  open my $inList, "<$inListName" or die "Cannot open $inListName";
  my %fileIDs=();
  foreach my $m (@markers) {
    open my $OH, ">$prefix.$m" or die "Cannot open $prefix.$m";
    $fileIDs{$m} = $OH;
  }
  #open my $cleanList, ">$prefix.clean" or die "Cannot open $prefix.clean";
  #open my $nList, ">$prefix.n" or die "Cannot open $prefix.n";
  #open my $sList, ">$prefix.s" or die "Cannot open $prefix.s";
  #open my $umList, ">$prefix.um" or die "Cannot open $prefix.um";

  my %cnt=();
  while (my $name = <$inList>) {
    chomp $name;
    $name =~ s/^.*([0-9][0-9][0-9])(.*)$/$1$2/;
    my $spkID = $1;
    my $transTxt = "$inDirName/$spkID/$name";
    my $transID = $name;
    $transID =~ s/(^.*).txt/$1/;
    if (! -e $transTxt) {
      print "Warning: transcript $transTxt not found!\n";
    } else {
      open my $txtFile, "<$transTxt" or die "Cannot open $transTxt";
      my $line = <$txtFile>;
      my $clean=1;
      foreach my $m (@markers) {
        next if $m eq 'clean';
        if ($line =~ /\[$m\]/) {
          $cnt{$m}++;
          $clean=0;
          my $OH = $fileIDs{$m}; 
          print $OH "$transID\n";
        }
      }
      if ($clean==1) {
        $cnt{'clean'}++;
        my $OH = $fileIDs{'clean'}; 
        print $OH "$transID\n";
      }
      close $txtFile;
    }
  }
  close $inList;

  foreach my $m (@markers) {
    close $fileIDs{$m};
  }

  while (my ($marker,$val) = each %cnt) {
    print "$marker\t$val\n";
  }
}

#--------------------------------------------------------------------------

if (scalar @ARGV==3) {
  do_count $ARGV[0],$ARGV[1],$ARGV[2];
} else {
  print_usage;
} 

#--------------------------------------------------------------------------

