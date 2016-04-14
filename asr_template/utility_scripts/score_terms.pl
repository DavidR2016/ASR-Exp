#!/usr/bin/perl
use warnings;
use strict;
use Unicode::Normalize;

use open IO => ':encoding(utf8)';
use open ':std';

if((@ARGV + 0) != 3) {
  print "Usage: ./score_terms.pl <in:mlf_words_ref> <in:mlf_words_rec> <in:hvite_log>\n";
  exit 1;
}

my $mlf_words_ref = $ARGV[0];
my $mlf_words_rec = $ARGV[1];
my $log_words_rec = $ARGV[2];

# Read in all reference transcriptions
# -----------------------------------------------------------------------------
my %truth;

open MLF_REF, "$mlf_words_ref" or die "Can't open '$mlf_words_ref'";
while(<MLF_REF>) {
  chomp;
  $_ = NFC($_);
  if (/^"(.*)\.(lab|rec)"$/) {
    my $fn = $1;
    my @file_parts = split(/\//,$fn);
    $fn = pop @file_parts;
    my $line = "";
    my @sentence;
    while ($line ne ".") {
      chomp($line = <MLF_REF>);
      $line = NFC($line);
      if ($line ne ".") {
        push @sentence,$line;
      }
    }
    $truth{$fn} = join " ",@sentence;
  }
}
close(MLF_REF);
print "All reference transcriptions read form '$mlf_words_ref'\n";

# Read in all recognized terms from mlf
# -----------------------------------------------------------------------------
my %rec;

open MLF_REC, "$mlf_words_rec" or die "Can't open '$mlf_words_rec'";
while(<MLF_REC>) {
  chomp;
  $_ = NFC($_);
  if (/^"(.*)\.(lab|rec)"$/) {
    my $fn = $1;
    my @file_parts = split(/\//,$fn);
    $fn = pop @file_parts;
    my $line = "";
    my @sentence;
    while ($line ne ".") {
      chomp($line = <MLF_REC>);
      $line = NFC($line);
      if ($line ne ".") {
	my @tokens = split(/\s+/,$line);
        push @sentence,$tokens[2];
      }
    }
    $rec{$fn} = join " ",@sentence;
  }
}
close(MLF_REC);
print "All recognized terms read form '$mlf_words_rec'\n";

# Read in logs (should be same as mlf_words_rec, except for "No tokens survived
# to final node of network"
# Expect recognized term to be enclosed by "SENT-START ... SENT-END"
# -----------------------------------------------------------------------------
my %from_log;
open LOG, "$log_words_rec" or die "Can't open '$log_words_rec'\n";
while(<LOG>) {
  chomp;
  $_ = NFC($_);
  if (/^File:(.*).mfc\s*$/) {
    my $fn = $1;
    my @file_parts = split(/\//,$fn);
    $fn = pop @file_parts;
    my $line;
    chomp($line = <LOG>);
    $line = NFC($line);
    if ($line eq "No tokens survived to final node of network") {
      $from_log{$fn} = "No tokens survived to final node of network";
    } elsif ($line =~ /^SENT-START (.*) SENT-END.*$/) {
      $from_log{$fn} = $1;
    } else {
      print "Unexpected format at fn '$fn'! Expected 'SENT-START ... SENT-END ...'. Have '$line'\n";
      exit 1;
    }
  }
}
close(LOG);
print "All recognized terms read form '$log_words_rec'\n";

# Perform some checks:
# -----------------------------------------------------------------------------
my %term_cnts;

# Check that everything in %from_log != "No tokens survived..." == that in %rec
print "\nPerforming some checks...\n\n";
my $num_terms_decoded = 0;
my $num_no_tokens_survived = 0;
print "Checking that results from mlf and log are the same\n";
foreach my $fn (sort keys %from_log) {
  $term_cnts{$truth{$fn}} += 1;
  if (!exists($rec{$fn}) and $from_log{$fn} ne "No tokens survived to final node of network") {
    print "ERROR: '$fn' in '$log_words_rec' but not in '$mlf_words_rec'\nExiting!\n";
    exit 1;
  }

  if ($from_log{$fn} eq "No tokens survived to final node of network") {
    $num_no_tokens_survived += 1;
  } elsif ($from_log{$fn} ne $rec{$fn}) {
    print "WARNING: '$from_log{$fn}' ne '$rec{$fn}'\n";
  } else {
    $num_terms_decoded += 1;
  }
}
printf "'%d' terms recognized\n",scalar(keys %from_log);
printf "'%d' terms decoded\n",$num_terms_decoded;
printf "'%d' terms did not decode (No tokens survived to final node of network)\n",$num_no_tokens_survived;

# Calculate accuracy
# -----------------------------------------------------------------------------
my %stats;
my %spk_stats;
foreach my $fn (sort keys %from_log) {
  my $ref = $truth{$fn};
  if (!exists($stats{$ref})) {
    $stats{$ref}{"no tokens"} = 0;
    $stats{$ref}{"corr"} = 0;
    $stats{$ref}{"incorr"} = 0;
    $stats{$ref}{"tot"} = 0;
  }

  my @fn_parts = split(/\_/,$fn);
  my $spk = shift @fn_parts;

  if (!exists($spk_stats{$spk})) {
    $spk_stats{$spk}{"tot"} = 0;
    $spk_stats{$spk}{"corr"} = 0;
  }

  if ($from_log{$fn} eq "No tokens survived to final node of network") {
    $stats{$ref}{"no tokens"} += 1;
  } elsif ($from_log{$fn} eq $truth{$fn}) {
    $stats{$ref}{"corr"} += 1;
    $spk_stats{$spk}{"corr"} += 1;
  } else {
    $stats{$ref}{"incorr"} += 1;
  }
  $stats{$ref}{"tot"} += 1;
  $spk_stats{$spk}{"tot"} += 1;
}

print "\nResults per term\n";
print "(#tot,term,#corr,#incorr,#not-decoded)\n";
print "--------------------------------------------------------------------------------\n";
my @sorted = sort {$stats{$a}{"tot"} <=> $stats{$b}{"tot"} || $a cmp $b} keys %stats;
foreach my $i (@sorted) {
  printf "%d,%s,%d,%d,%s\n",$stats{$i}{"tot"},$i,$stats{$i}{"corr"},$stats{$i}{"incorr"},$stats{$i}{"no tokens"};
}

# Breakdown of stats
my %breakdown_acc;
my %breakdown_tot;
my %sleutels;
my $acc = 0;
my $tot = 0;
foreach my $fn (sort keys %from_log) {
  my $cnt = $term_cnts{$truth{$fn}};

  # Set cnt to class
  # ----------------
  if ($cnt >= 2 and $cnt <= 10) { $cnt = "2-10"; }
  elsif ($cnt > 10) { $cnt = "10+"; }
  # ----------------
  my @tokens = split(/\s+/,$truth{$fn});
  my $ngram = scalar(@tokens);

  # Set gram to class
  # ----------------
  if ($ngram > 5) { $ngram = ">5"; }
  # ----------------

  if ($from_log{$fn} eq $truth{$fn}) {
    $breakdown_acc{$cnt}{$ngram} += 1;
    $breakdown_acc{$cnt}{"all"} += 1;
    $breakdown_acc{"all"}{"all"} += 1;
    $breakdown_acc{"all"}{$ngram} += 1;
    $acc += 1;
  }
  $breakdown_tot{$cnt}{$ngram} += 1;
  $breakdown_tot{"all"}{"all"} += 1;
  $breakdown_tot{"all"}{$ngram} += 1;
  $breakdown_tot{$cnt}{"all"} += 1;
  $sleutels{"row"}{$cnt} += 1;
  $sleutels{"col"}{$ngram} += 1;
  $sleutels{"row"}{"all"} += 1;
  $sleutels{"col"}{"all"} += 1;
  $tot += 1;
}

my @sorted_cnts  = sort {$a cmp $b} keys %{ $sleutels{"row"} };
my @sorted_ngram = sort {$a cmp $b} keys %{ $sleutels{"col"} };

print "\nBreakdown of results (% correct)\n";
print "<term counts (rows)> vs <# words/term (ngram, columns)>\n";
print "--------------------------------------------------------------------------------\n";
printf "%-8s","*";
foreach my $ngram (@sorted_ngram) {
  printf "%-8s",$ngram;
}
print "\n";

foreach my $cnt (@sorted_cnts) {
  printf "%-8s",$cnt;
  foreach my $ngram (@sorted_ngram) {
    if (exists($breakdown_acc{$cnt}{$ngram})) {
      printf "%-8.2f",100*$breakdown_acc{$cnt}{$ngram}/$breakdown_tot{$cnt}{$ngram};
    } else {
      printf "%-8s","-";
    }
  }
  print "\n";
}

print "\nBreakdown of results (total count)\n";
print "<term counts (rows)> vs <# words/term (ngram, columns)>\n";
print "--------------------------------------------------------------------------------\n";
printf "\n%-8s","*";
foreach my $ngram (@sorted_ngram) {
  printf "%-8s",$ngram;
}
print "\n";

foreach my $cnt (@sorted_cnts) {
  printf "%-8s",$cnt;
  foreach my $ngram (@sorted_ngram) {
    if (exists($breakdown_acc{$cnt}{$ngram})) {
      printf "%-8d",$breakdown_tot{$cnt}{$ngram};
    } else {
      printf "%-8s","0";
    }
  }
  print "\n";
}

print "\nResults per speaker\n";
print "(spk,#corr,#tot,%corr)\n";
print "--------------------------------------------------------------------------------\n";
my @sorted_spks = sort {$a <=> $b} keys %spk_stats;
foreach my $spk (@sorted_spks) {
  printf "%d\t%d\t%d\t%f\n",$spk,$spk_stats{$spk}{"corr"},$spk_stats{$spk}{"tot"}, 100*$spk_stats{$spk}{"corr"}/$spk_stats{$spk}{"tot"};
}

printf "%s correct: '%d' No tokens survivd: '%d' total: '%d'\n", "#", $acc, $num_no_tokens_survived, $tot;
printf "%s correct: '%.2f' (correct*100/total; no tokens survived considered an error)'\n", "%", 100*$acc/$tot;
