#!/usr/bin/perl
#
# make a .hed script to clone monophones in a phone list 
# 
# rachel morton 6.12.96


if (@ARGV != 3) {
  print "usage: ./makehed.pl <monolist> <trilist> <out:mktri.hed>\n\n"; 
  exit (1);
}

my $monolist;
my $trilist;
my $file_out;

($monolist, $trilist, $file_out) = @ARGV;

# open .hed script
open(MONO, "@ARGV[0]");


# open .hed script
open(HED, ">$file_out");

print HED "CL $trilist\n";

# 
while ($phone = <MONO>) {
       chop($phone);
       if ($phone ne "") { 
	   print HED "TI T_$phone {(*-$phone+*,$phone+*,*-$phone).transP}\n";
       }
   }
