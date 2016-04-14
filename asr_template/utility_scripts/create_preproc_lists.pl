#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use open IO => ':encoding(utf8)';

my $dir_trans = $ARGV[0];
my $dir_preproc = $ARGV[1];
my $list = $ARGV[2];

if ((@ARGV + 0) < 3) {
  print "./create_preproc_lists.pl <dir_trans> <dir_proc> <preproc_list>\n";
  print "\tdir_trans     - directory where transcriptions reside (NB: .txt files!)\n";
  print "\tdir_proc      - directory where processed .txt will be saved to\n";
  print "\tpreproc_list  - full path to preproc_list.txt\n";
  exit 1;
}

if (! -d $dir_preproc) {
  print "$dir_preproc doesn't exist! Please create.\n";
  exit 1;
}

my @files = `find $dir_trans -iname "*.txt"`;

my %files;
chomp($dir_preproc=`readlink -f $dir_preproc`);

open LIST, ">$list";

foreach my $file (@files) {
  chomp($file);
  chomp($file=`readlink -f $file`);
  my $basename = basename($file);
  if (exists($files{$basename})) {
    print "WARNING: Non-unique filename encountered! <$basename> Exiting\n";
    close LIST;
    exit 1;
  }
  $files{$basename} = 1;
  print LIST "$file $dir_preproc/$basename\n";
}
close LIST;
