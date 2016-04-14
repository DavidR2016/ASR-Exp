#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use open IO => ':encoding(utf8)';

# 1. Read in the aligned files
# 2. Write out all filenames occuring in both aligned mlf and list file

my $aligned_train_mlf = $ARGV[0];
my $aligned_test_mlf = $ARGV[1];
my $list_train_file = $ARGV[2];
my $list_test_file = $ARGV[3];

if (@ARGV + 0 < 4) {
  print "./prune_list_after_alignment.pl <aligned_trn_mlf> <aligned_tst_mlf> <mfc_trn_lst> <mfc_tst_lst>\n";
  exit 1;
}

my @suffixlist = (".lab", ".txt", ".wav", ".mfc");
my %aligned_train_files;
my %aligned_test_files;
my %list_train_files;
my %list_test_files;

open ALIGNED, "$aligned_train_mlf";
while (<ALIGNED>) {
  if (/\.lab/) {
    chomp;
    $_ =~ s/\"//g;
    my $tmp_file = fileparse($_, @suffixlist);
    $aligned_train_files{$tmp_file} = 1;
  }
}
close(ALIGNED);

open ALIGNED, "$aligned_test_mlf";
while (<ALIGNED>) {
  if (/\.lab/) {
    chomp;
    $_ =~ s/\"//g;
    my $tmp_file = fileparse($_, @suffixlist);
    $aligned_test_files{$tmp_file} = 1;
  }
}
close(ALIGNED);

my $line;

open LIST_TRAIN, "$list_train_file";
while (<LIST_TRAIN>) {
  chomp;
  $line = $_;
  my $tmp_file = fileparse($_, @suffixlist);
  if (exists($aligned_train_files{$tmp_file})) {
    $list_train_files{$line} = 1;
  }
}
close(LIST_TRAIN);

open LIST_TEST, "$list_test_file";
while (<LIST_TEST>) {
  chomp;
  $line = $_;
  my $tmp_file = fileparse($_, @suffixlist);
  if (exists($aligned_test_files{$tmp_file})) {
    $list_test_files{$line} = 1;
  }
}
close(LIST_TEST);

open LIST_TRAIN, ">$list_train_file";
foreach my $file (sort keys %list_train_files) {
  print LIST_TRAIN "$file\n";
}
close(LIST_TRAIN);

open LIST_TEST, ">$list_test_file";
foreach my $file (sort keys %list_test_files) {
  print LIST_TEST "$file\n";
}
close(LIST_TEST);
