#!perl
# @(#) $Id$
# Generate integer-sided triangles
# 2024-04-03, Georg Fischer
use strict;
use integer;
use warnings;

my ($p, $a, $b, $c, $r) =
   (3,   1,  0,  2,  0);

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

while (++$n <= 1290) {
    &advance();
    print sprintf("| %3d | %5d |%3d%3d%3d |\n", $n, $p, $a, $b, $c);
} # while
__DATA__
