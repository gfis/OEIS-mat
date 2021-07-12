#!perl

# @(#) $Id$
# Maple from Alois Heinz converted to Perl
# 2020-09-05, Georg Fischer
#
# A161039 Number of partitions of n into odd numbers where every part appears at least 3 times.		1
# 0, 0, 1, 1, 1, 1, 1, 1, 2, 1, 1, 3, 2, 2, 5, 3, 3, 6, 5, 6, 8, 6, 7, 11, 10, 9, 14, 13, 13, 19, 16, 
# 18, 25, 22, 25, 32, 29, 31, 42, 41, 41, 53, 51, 54, 69, 64, 69, 88, 83, 89, 109, 105, 112, 136, 134, 141, 170, 166, 177, 215, 207, 219, 262, 260, 276, 320, 320, 341, 397, 397, 417, 485

# N O T   W O R K I N G !

use strict;
use integer;
use warnings;
no warnings 'recursion';

my %optrem = ();
my $max = shift(@ARGV);
my $ni;
for ($ni = 0; $ni <= $max; $ni ++) {
    print "$ni " . &b($ni, $ni, 0) . "\n";
} # for $n
#----
sub b {
    my ($n, $i, $t) = @_;
    my $key = "$n,$i,$t";
    my $result = $optrem{$key};
    if (! defined($result)) {
        if ($n == 0) {
            $result = $t;
        } else {
            if ($i < 1) {
                $result = 0;
            } else {
                my $j = 0;
                my  $sum  = &b($n - $i * $j, $i - 1, ($i % 2) == 1 ? 1 : $t);
                $j = 3;
                while ($j <= $n / $i) {
                    $sum += &b($n - $i * $j, $i - 1, ($i % 2) == 1 ? 1 : $t);
                    $j ++;
                }
                $result = $sum;
            }
        }
        $optrem{$key} = $result;
    }
    return $result;
} # b
__DATA__
use strict;
use integer;
use warnings;
no warnings 'recursion';

my %optrem = ();
my $max = shift(@ARGV);
print "max=$max\n";
my $ni;
my $appear = 3;
for ($ni = 0; $ni <= $max; $ni ++) {
    print "$ni " . &b($ni, $ni, 0) . "\n";
} # for $n

sub b { # at least 3 times
    my ($n, $i, $t) = @_;
    my $key = "$n,$i,$t";
    my $result = $optrem{$key};
    if (! defined($result)) {
        if ($n == 0) {
            $result = 1; # $t;
        } else {
            if ($i < 1) {
                $result = 0;
            } else {
                my $h = $i % 2;
                if ($h == 1) {
                    my  $j = 0;
                    my  $sum  = &b($n - $i * $j, $i - 1, ($h == 1 ? 1 : $t));
                    $j = $appear;
                    while ($j <= $n / $i) {
                        $sum += &b($n - $i * $j, $i - 1, ($h == 1 ? 1 : $t));
                        $j ++;
                    }
                    $result = $sum;
                }
            }
        }
        $optrem{$key} = $result;
    }
    return $result;
} # b
__DATA__
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

sub b679 {
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
} # b679

sub b1 {
    my ($n, $i, $t) = @_;
    my $key = "$n,$i,$t";
    my $result = $optrem{$key};
    if (! defined($result)) {
        if ($n == 0) {
            $result = $t; # >= 3 ? 1 : 0;
        } else {
            if ($i < 1) {
                $result = 0;
            } else {
                $result = &b($n, $i-1, $t);
                my $h = $i % 2;
                if ($h == 1) {
                    my $sum = 0;
                    for (my $j = 1; $j <= $n / $i; $j ++) {
                        $sum += &b($n - $i * $j, $i - 1
                             , ($h == 1 ? 1 : $t)
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

#----
