#!perl

# @(#) $Id$
# A035536 - Maple from Alois Heinz converted to Perl
# 2020-09-05, Georg Fischer
#
# A035679 Number of partitions of n into parts 8k+1 and 8k+2 with at least one part of each type

use strict;
use integer;
use warnings;
no warnings 'recursion';

my %optrem = ();
my $max = shift(@ARGV);
my $ni;
for ($ni = 0; $ni <= $max; $ni ++) {
    print "$ni " . &b($ni, $ni, 0, 0) . "\n";
} # for $n
#----
my $maple = <<'GFis';
b:= proc(n, i, t, s) option remember; `if`(n=0, t*s, `if`(i<1, 0,
       b(n, i-1, t, s)+(h-> `if`(h in {1, 2}, add(b(n-i*j, i-1,
      `if`(h=1, 1, t), `if`(h=2, 1, s)), j=1..n/i), 0))(irem(i, 8))))
    end:
a:= n-> b(n$2, 0$2):
seq(a(n), n=1..75);

b:= proc(n, i, t, s) option remember; 
  `if`(n=0
      ,t*s
      , `if`(i<1
            , 0
            , b(n, i-1, t, s)
            + (h-> `if`(h in {1, 2}
                       , add(  b(n-i*j, i-1, `if`(h=1, 1, t), `if`(h=2, 1, s))
                            , j=1..n/i)
                       , 0)
              )  (irem(i, 8))
            )
      )
    end:
GFis

sub b {
    my ($n, $i, $t, $s) = @_;
    my $key = "$n,$i,$t,$s";
    my $result = $optrem{$key};
    if (! defined($result)) {
        if ($n == 0) {
            $result = $t * $s;
            print "too large: i=$i n=$n t=$t s=$s\n" if $t > $ni or $s > $ni;
        } else {
            print "negative: i=$i n=$n t=$t s=$s\n" if $i < 0;
            if ($i < 1) {
                $result = 0;
            } else {
                $result = &b($n, $i-1, $t, $s);
                my $h = $i % 8;
                if ($h == 1 or $h == 2) {
                    my $sum = 0;
                    for (my $j = 1; $j <= $n / $i; $j ++) {
                        $sum += &b($n - $i * $j, $i - 1
                             , ($h == 1 ? 1 : $t)
                             , ($h == 2 ? 1 : $s)
                             );
                    }
                    $result += $sum;
                } 
            }
        }
        $optrem{$key} = $result;
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
