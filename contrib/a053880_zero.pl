#!perl

# A053880 ff.: Squares with 3 digits; here: 1 2 4
# 2022-01-09, Georg Fischer
#:# Usage:
#:# perl A053880_zero.pl [-e exponent] [-d debug] [-k] [-z] {-s sample|sample}
#:#     -d debugging mode: 0=none, 1=some, 2=more
#:#     -e compute up to this power of 10 (default: 12)
#:#     -k whether k must also consist only of these digits (default: only k^2)
#:#     -s sample digits (default: 124)
#:#     -z forbid a trailing zero (default: off)

use strict;
use integer;

my $maxexp  = 12;
my $kToo    = 0; 
my $sample  = "124"; # A053880
my $debug   = 0;
my $noEndZero  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-e}  ) {
        $maxexp     = shift(@ARGV);
    } elsif ($opt   =~ m{\-k}  ) {
        $kToo       = 1;
    } elsif ($opt   =~ m{\-s}  ) {
        $sample     = shift(@ARGV);
    } elsif ($opt   =~ m{\A\d}  ) {
        $sample     = shift(@ARGV);
    } elsif ($opt   =~ m{-z}  ) {
        $noEndZero  = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @mOlds = ();
for (my $mDig = 0; $mDig < 10; $mDig ++) {
    if ((($mDig * $mDig) % 10) =~ m{\A[$sample]+\Z}o) {
        push(@mOlds, $mDig);
    }
}
print "# $0, digits: $sample, start with " . join(",", @mOlds) . "\n";
my @mNews = ();
my $mLen = 1;
my $mAdd1 = 10;
my $mMod = 100;
my $mN = 0;
  
  for (my $exp = 0; $exp < $maxexp; $exp ++) {
    my $mAdd = $mAdd1;
    foreach my $mDig (0..9) {
      foreach my $num (@mOlds) {
        my $k = $mAdd + $num;
        my $k2 = $k * $k;
        if (($k2 % $mMod) =~ m{\A[$sample]+\Z}o) {
          push(@mNews, $k);
          if ($k2  =~ m{\A[$sample]+\Z}o) {
            if (($kToo == 0 || ($k  =~ m{\A[$sample]+\Z}o)) && ($noEndZero == 0 || $k % 10 != 0)) {
              ++$mN;
              print "$mN $k # $k2\n";
            }
          } elsif ($debug >= 1) {
              print "    # $k $k2\n";
          }
        }
      } # foreach $num
      $mAdd += $mAdd1;
    } # foreach $mDig
    @mOlds = @mNews;
    @mNews = ();
    $mAdd1 *= 10;
    $mMod *= 10;
    ++$mLen;
    if ($debug >= 1) { print "---- next add1: $mAdd1, len=$mLen\n"; }
  } # for $exp

