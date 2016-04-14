#!/usr/bin/perl
use warnings;
use strict;
use List::Util 'shuffle';

use open IO => ':encoding(utf8)';
binmode STDOUT, ":utf8";

# This file is used to check that all the files intended for training, were
# actually used during the parallelization.
# (1) Searches for -p 0 (HERest command to estimate models given accumulators)
#     and confirms that there are N accumulators
# (2) Searches for all -p's (excluding 0) and count the associated
#     Processing Data: 012_Female_20_348.mfc;

if (scalar(@ARGV) != 2) {
  print "Usage: ./check_num_files_used_per_step.pl <#procs> <log>\n";
  print "       - #procs	-- number of parallel processes used\n";
  print "       - log   	-- log that captured all HERest related operations\n";
  exit 1;
}

my $num_procs = $ARGV[0];
my %accs_per_model;
my %mfccs_per_model;
my %mfccs_per_spk_model;
my %mfccs_per_acc_per_model;
my $hmm;
my @tokens;

open LOG, "$ARGV[1]" or die "Can't open '$ARGV[1]' for reading\n";
while(<LOG>) {
  chomp;
  my $line = $_;
  if (/^HERest/) {
    # HERest start found.
    if (/-p ([[:digit:]]+) /) {
      my $p_val = $1;
      $hmm = 0;
      @tokens = split(/\s+/,$_);
      foreach my $i (0..(@tokens - 1)) {
        if ($tokens[$i] eq "-M") {
          $tokens[$i + 1] =~ /hmm_([[:digit:]]+)\//;
          $tokens[$i + 1] =~ s/.*hmm_//g;
          $tokens[$i + 1] =~ s/\/.*//g;
          $hmm = $tokens[$i + 1];
        }
      }
      if ($p_val == 0) {
        my $acc_cnt = 0;
        # Count # .acc files on the line
        my @accs = split(/\s+/,$line);
        foreach my $acc (@accs) {
          if ($acc =~ /\.acc$/) { $acc_cnt += 1; }
        }
        $accs_per_model{$hmm} = $acc_cnt;
        print "HMM $hmm: $acc_cnt .acc files\n";
      } else {
        # Find first "Processing Data" line, and then continue reading lines until a line is found that doesn't start with a space
        my $process_data_line_found = 0;
        while($process_data_line_found == 0) {
          chomp($line = <LOG>);
          if ($line =~ /^\s*Processing Data:/) {
            $process_data_line_found = 1;
          }
        }
        
        @tokens = split(/\s+/,$line);
        my $mfc = $tokens[3];
        $mfccs_per_model{$hmm}{$mfc} = 1;
        $mfccs_per_acc_per_model{$hmm}{$p_val} += 1;
        @tokens = split(/\_/,$tokens[3]);
        $mfccs_per_spk_model{$hmm}{$tokens[0]} += 1;
        my $non_space_line = 0;
        while ($non_space_line == 0) {
          chomp($line = <LOG>);
          if ($line =~ /^\s+/ || $line =~ /^Retrying/) {
            if ($line =~ /\s+Processing Data:/) {
              @tokens = split(/\s+/,$line);
              my $mfc = $tokens[3];
              $mfccs_per_model{$hmm}{$mfc} = 1;
              $mfccs_per_acc_per_model{$hmm}{$p_val} += 1;
              @tokens = split(/\_/,$tokens[3]);
              $mfccs_per_spk_model{$hmm}{$tokens[0]} += 1;
            }
          } else {
            $non_space_line = 1;
          }
        }
      }
      #print "$p_val -- $hmm\n";
    }
  }
}
close(LOG);
my @sorted = sort {$a <=> $b} keys %mfccs_per_model;
foreach my $hmm (@sorted) {
  printf "HMM: %2d - %d mfcs processed (%d spks):", $hmm, scalar(keys %{ $mfccs_per_model{$hmm} }), scalar(keys %{ $mfccs_per_spk_model{$hmm} });
  my @sorted_ps = sort {$a <=> $b} keys %{ $mfccs_per_acc_per_model{$hmm} };
  foreach my $acc (@sorted_ps) {
    printf " %d (%d) -- ", $acc, $mfccs_per_acc_per_model{$hmm}{$acc};
  }
  print "\n";
}

