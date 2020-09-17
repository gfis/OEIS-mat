#!perl

# @(#) $Id$
# A035536 - Maple from Alois Heinz converted to Perl
# 2020-09-04, Georg Fischer
#
# A035537 null Number of partitions of n with equal nonzero number of parts congruent to each of 0 and 1 (mod 3).	nonn,synth	0..54

use strict;
use integer;
use warnings;
no warnings 'recursion';

my $maple = <<'GFis';
    b := proc(n, i, c) option remember; `if`(n=0,
      `if`(c = 0, 1, 0), `if`(i<1, 0, b(n, i-1, c)+
       b(n-i, min(n-i, i), c+[0, 1, -1][1+irem(i, 3)])))
    end:
    seq(b(n,n, 0), n=0..32);
GFis

my %optrem = ();
my $max = shift(@ARGV);
for (my $n = 0; $n <= $max; $n ++) {
    print "$n " .  &b($n, $n, 0) . "\n";
} # for $n
#----
sub b {
    my ($n, $i, $c) = @_;
    my $result = $optrem{"$n,$i,$c"};
    if (! defined($result)) {
        if ($n == 0) {
            $result = ($c == 0) ? 1 : 0;
        } else {
            print "i=$i n=$n c=$c\n" if $i < 0;
            if ($i < 1) {
                $result = 0;
            } else {
                $result = &b($n, $i-1, $c) 
                        + &b($n - $i, &min($n - $i, $i)
                            , $c + (0, 1, -1)[$i % 3]);
            }
        }
        $optrem{"$n,$i,$c"} = $result;
    }
    return $result;
} # b

sub min {
    my ($a, $b) = @_;
    return $a < $b ? $a : $b;
}
__DATA__
1,0,0,2,0,0,6,0,0,14,0,0,32,0,0,66,0,0,134,0,0,256,0,0
,480,0,0,868,0,0,1540,0,0,2664,0,0,4536,0,0,7574,0,0
,12474,0,0,20234,0,0,32428,0,0,51324,0,0,80388,0,0,124582
,0,0,191310,0,0,291114,0,0,439394,0,0,657936,0,0
