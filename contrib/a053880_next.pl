#!perl

# A053880 ff.: Squares with 3 digits; here: 1 2 4
# 2022-01-09, Georg Fischer
#:# Usage:
#:# perl A053880_next.pl [-b base] [-e exponent] [-d debug] [-k] [-z] {-s sample|sample}
#:#     -b number base (default: 10)
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
my $mBase = 10;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-b}  ) {
        $mBase      = shift(@ARGV);
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
my $mAdd1 = $mBase;
my $mAdd = $mAdd1;
my $mMod = $mBase * $mBase;
my $mDig = 0;
my $mOldIx = 0;
my $mNewIx = 0;
my $mN = 0;
while (1) {
  my $result = &next();
  print "$mN $result\n";
}

  sub next {
    while (1) {
      while ($mDig < $mBase) {
        while ($mOldIx < scalar(@mOlds)) {
          my $num = $mOlds[$mOldIx++];
          my $k = $mAdd + $num;
          my $k2 = $k * $k;
          if (($k2 % $mMod) =~ m{\A[$sample]+\Z}o) {
            push(@mNews, $k);
            if ($k2  =~ m{\A[$sample]+\Z}o) {
              if (($kToo == 0 || ($k  =~ m{\A[$sample]+\Z}o)) && ($noEndZero == 0 || $k % 10 != 0)) {
                ++$mN;
                return $k;
              }
            } elsif ($debug >= 1) {
                print "    # $k $k2\n";
            }
          }
        }
        $mOldIx = 0;
        $mAdd += $mAdd1;
        ++$mDig;
      }
      $mDig = 0;
      @mOlds = @mNews;
      @mNews = ();
      $mAdd1 *= $mBase;
      $mMod *= $mBase;
      $mAdd = $mAdd1;
      ++$mLen;
      if ($debug >= 1) { print "---- next add1: $mAdd1, len=$mLen\n"; }
    }
  } # next
