#!perl
# @(#) $Id$
# Generate integer-sided triangles
# 2024-04-03, Georg Fischer
use strict;
# do not use integer!
use warnings;

my ($p, $a, $b, $c, $r) =
   (1,   1,  0,  2,  0);

my $debug = 0;
if (scalar(@ARGV) > 0) {
	$debug = 1;
}
my $n = 0;
sub advance {
	my $busy = 1;
    while ($busy) {
        $b ++;
        $c = $p - $a - $b;
        print sprintf("%3d: %3d %3d %3d P\n", $p, $a, $b, $c) if $debug > 0;
        if ($a <= $b and $b <= $c && $a + $b > $c) {
            $busy = 0;
        } elsif ($b > $c) {
            $a ++;
            $r = $p - $a;
            $b = $a;
            $c = $p - $a - $b;
            print sprintf("%3d: %3d %3d %3d Q\n", $p, $a, $b, $c) if $debug > 0;
            if ($a <= $b and $b <= $c && $a + $b > $c) {
                $busy = 0;
            } elsif ($b + $c <= $a) {
                $p ++;
                print "\n";
                $a = 1;
                $r = $p - $a;
                $b = $a;
                $c = $p - $a - $b;
                print sprintf("%3d: %3d %3d %3d R\n", $p, $a, $b, $c) if $debug > 0;
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
    #                            1 1 1 1 1 1 1 1 1 1 2
    #        0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 
    my @p = (0,0,1,1,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1);
    return $p[$num] if $num < 20;
    return 0 if $num % 2 == 0 ;
    for (my $i = 3; $i <= $num/2; $i += 2) {
       return 0 if ($num % $i == 0)
    }
    return 1;
}

while (++$n <= 1290) {
    &advance();
    print sprintf("| %3d | %5d |%3d%3d%3d |", $n, $p, $a, $b, $c);
    my $s = $p/2;
    my $H = sprintf("%8.4f",   sqrt($s*($s - $a)*($s - $b)*($s - $c)));
    my $I = sprintf("%8.4f", sqrt(   ($s - $a)*($s - $b)*($s - $c)/$s));
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
    print "" . (($H =~ m{\.000}) ? " H" : "  ");
    print "" . (($I =~ m{\.000}) ? " I" : "  ");
    print " | $H $I";
    print "\n";
} # while
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
	|  