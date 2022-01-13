#!perl

# Numbers k such that k^2 contains only 3 specific digits, or
# Squares k^2 composed of 3 specific digits; here: 1,2,4
# 2022-01-09, Georg Fischer
#
#:# Usage:
#:# perl A053880_next.pl [-b base] [-d debug] [-2] [-k] [-n noterms] [-s sample] [-z]
#:#     -2 output k^2 instead of k
#:#     -b number base (default: 10)
#:#     -d debugging mode: 0=none, 1=some, 2=more
#:#     -n number of terms (default: 64)
#:#     -k whether k must also consist of these digits only (default: all digits for k)
#:#     -s sample digits (default: 124)
#:#     -z forbid a trailing zero (default: allow)
#
# Applicable to:
#   A053880-A053975 (option -2 for odd A-numbers)
#   A058411-A058474 (option -z and option -2 for even A-numbers)
#   A136808-A137147 (option -k)
#--------
use strict;
use integer;

my $noTerms = 64;
my $mTestK  = 0;
my $mNextK2 = 0;
my $mSubset = "124"; # A053880
my $sDebug  = 0;
my $mNoZeroTail  = 0;
my $mBase   = 10;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt    =~ m{\-2}  ) {
        $mNextK2     = 1;
    } elsif ($opt    =~ m{\-b}  ) {
        $mBase       = shift(@ARGV);
    } elsif ($opt    =~ m{\-d}  ) {
        $sDebug      = shift(@ARGV);
    } elsif ($opt    =~ m{\-k}  ) {
        $mTestK      = 1;
    } elsif ($opt    =~ m{\-n}  ) {
        $noTerms      = shift(@ARGV);
    } elsif ($opt    =~ m{\-s}  ) {
        $mSubset     = shift(@ARGV);
    } elsif ($opt    =~ m{-z}  ) {
        $mNoZeroTail = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
$mSubset     =~ s{\D}{}g; # remove non-digits

my @mOldBlock = (0);
my $mOldIx = 0;
my $mNewIx = 0;
my $mOldLen = scalar(@mOldBlock);
my $mNewLen = 0;
my @mNewBlock = ();
my $mAdd1 = 1;
my $mAdd = $mAdd1;
my $mMod = $mBase;
my $mDig = 0; # was 0 !!
my $mN = 0;
my @mAllowedDigits;
my $mOldK = 0; # new !!
for (my $isub = 0; $isub < $mBase; ++$isub) {
  $mAllowedDigits[$isub] = index($mSubset, $isub) >= 0 ? 1 : 0;
} # for $isub

print "# $0, digits: $mSubset, " . join(",", @mAllowedDigits) . "\n";
while (1) {
  my $result = &next();
  print "$mN $result\n";
}

  sub next {
    if ($mN == 0 && &isAllowed(0) && $mNoZeroTail == 0) {
      ++$mN;
      return 0;
    }
    while (1) {
      while ($mDig < $mBase) {
        while ($mOldIx < $mOldLen) {
          my $k = $mAdd + $mOldBlock[$mOldIx++]; # pop
          my $k2 = $k * $k;
          my $k2div = $k2 / $mMod;
          if (&isAllowed($k2 % $mMod)) {
            $mNewBlock[$mNewIx ++] = $k; # push
            if ($sDebug >= 1) {
                print "    # push $k $k2 mOldIx=$mOldIx mAdd=$mAdd mMod=$mMod mDig=$mDig\n";
            }
            if (&isAllowed($k2)) {
              if ($mTestK == 0 || &isAllowed($k)) {
                if (($mNoZeroTail == 0 || $k % $mBase != 0) && $k > $mOldK) {
                  ++$mN;
                  $mOldK = $k;
                  return $mNextK2 == 0 ? $k : $k2;
                }
              }
            } 
          }
        }
        $mOldIx = 0;
        $mAdd += $mAdd1;
        ++$mDig;
      }
      $mDig = 0; # was 0 !!
      $mOldLen = $mNewIx;
      @mOldBlock = @mNewBlock;
      $mNewLen = $mOldLen * $mBase;
      @mNewBlock = ();
      $mNewIx = 0;
      $mAdd1 *= $mBase;
      $mMod *= $mBase;
      $mAdd = 0; # was $mAdd1;
      if ($sDebug >= 1) { print "---- new block, mOldLen=$mOldLen, mMod=$mMod, mAdd=$mAdd, mAdd1=$mAdd1, mDig=$mDig\n"; }
    }
  } # next
#----
sub isAllowed {
  my ($k) = @_;
  return ($k  =~ m{\A[$mSubset]+\Z}o) ? 1 : 0;
}