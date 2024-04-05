#!perl
# @(#) $Id$
# Generate integer-sided triangles
# 2024-04-05, Georg Fischer
#
#:# Usage:
#:#   perl A070080_gen.pl [start [[-]end]]
#:#       start first perimeter (default 1)
#:#       +end  number of perimeters to be printed (default 1, or 55 if start=1)
#:#       -end  print from perimeter start to abs(end)
#--------
use strict;
# do not use integer! b.o. area and inradius
use warnings;

my $periStart = 1;
my $periEnd   = 55;
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     =  shift(@ARGV);
    }
} # while
if (scalar(@ARGV) > 0) {
    $periStart = shift(@ARGV);
}
if (scalar(@ARGV) > 0) {
    $periEnd = shift(@ARGV);
} else {
    if ($periStart > 1) {
        $periEnd = $periStart;
    }
}

my ($peri, $a, $b, $c, $r) =
   (1,   1,  0,  2,  0);
$peri = $periStart;
$a = 1;
$b = 0;
if ($periStart > 1) {
    &printSeparator();
}
my $n = 0;
my $oldPeri = $peri;
while ($peri <= $periEnd) {
    $n ++;
    &advance();
    if ($peri != $oldPeri) {
      &printSeparator();
      $oldPeri = $peri;
    }
    if ($peri <= $periEnd) {
        print sprintf("| %5d | %5d |%4d%4d%4d |", $n, $peri, $a, $b, $c);
        print sprintf("%6d |%6d |", &gcd($a, &gcd($b, $c)), $a**2 + $b**2 - $c**2);
        my $s = $peri/2;
        my $H = sprintf("%12.6f", sqrt($s*($s - $a)*($s - $b)*($s - $c)));
        my $I = sprintf( "%8.6f", sqrt(   ($s - $a)*($s - $b)*($s - $c)/$s));
        print " s" if $a <  $b && $b <  $c;
        print " i" if $a == $b || $b == $c;
        if (0) {
        } elsif (&isPrime($a) && &isPrime($b) && &isPrime($c)) {
            print " p";
        } elsif (&gcd($a, &gcd($b, $c)) == 1) {
            print " r";
        } else {
            print "  ";
        }
        print " A" if $a**2 + $b**2 >  $c**2;
        print " R" if $a**2 + $b**2 == $c**2;
        print " O" if $a**2 + $b**2 <  $c**2;
        print "" . (($H =~ m{\.000000}) ? " H" : "  ");
        print "" . (($I =~ m{\.000000}) ? " I" : "  ");
        print " | $H $I";
        print "\n";
    }
} # for $n

#----
sub printSeparator {
    print "+-------+-------+-------------+-------+-------+-----------+\n";
}

sub advance {
    my $busy = 1;
    while ($busy) {
        $b ++;
        $c = $peri - $a - $b;
        print sprintf("%3d: %3d %3d %3d P\n", $peri, $a, $b, $c) if $debug > 0;
        if ($a <= $b and $b <= $c && $a + $b > $c) {
            $busy = 0;
        } elsif ($b > $c) {
            $a ++;
            $r = $peri - $a;
            $b = $a;
            $c = $peri - $a - $b;
            print sprintf("%3d: %3d %3d %3d Q\n", $peri, $a, $b, $c) if $debug > 0;
            if ($a <= $b and $b <= $c && $a + $b > $c) {
                $busy = 0;
            } elsif ($b + $c <= $a) {
                $peri ++;
                $a = 1;
                $r = $peri - $a;
                $b = $a;
                $c = $peri - $a - $b;
                print sprintf("%3d: %3d %3d %3d R\n", $peri, $a, $b, $c) if $debug > 0;
                if ($a <= $b and $b <= $c && $a + $b > $c) {
                    $busy = 0;
                }
            }
        }
    } # while
} # advance

# from https://gist.github.com/EricCrosson/8b5dc6a15679f159f7fc
sub gcd {
  my ($m, $n) = @_;
  if ($n == 0) {
    return $m;
  }
  return gcd($n, $m % $n);
}

# https://stackoverflow.com/questions/32675465/perl-finding-out-if-a-given-number-is-a-prime-number
sub isPrime {
    my ($num) = @_;
    #                             1 1 1 1 1 1 1 1 1 1 2
    #         0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 
    my @pc = (0,0,1,1,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1);
    return $pc[$num] if $num < scalar(@pc);
    return 0 if $num % 2 == 0 ;
    for (my $i = 3; $i <= $num/2; $i += 2) {
       return 0 if ($num % $i == 0)
    }
    return 1;
}

__DATA__
               s = scalene: a < b < c                          |
    |          i = isosceles: a = b or b = c                   |
    |                                                          |
    |          r = a, b, and c are relatively prime            |
    |          p = a, b, and c are primes  (p < r)             |
    |                                                          |
    |          A = acute:  a^2 + b^2 > c^2                     |
    |          R = right:  a^2 + b^2 = c^2                     |
    |          O = obtuse: a^2 + b^2 < c^2                     |
    +-----+-------+----------+-------+-------+-----------------+
    |Sequ-|A070083|A070080-82|A070084|A070085|                 |
    | Nr. | a+b+c |  a  b  c |   gcd |       |   properties    |
    +-----+-------+----------+-------+-------+-----------------+
    |   1 |     3 |  1  1  1 |     1 |     1 |  i  r  A        |
    |-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -|
    |   2 |     5 |  1  2  2 |     1 |     1 |  i  r  A        |
    |-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -|
    |   3 |     6 |  2  2  2 |     2 |     4 |  i  p  A        |
    |  