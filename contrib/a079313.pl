#!perl
# 2022-06-07, Georg Fischer
# A079313 a(n) is taken to be the smallest positive integer not already present which is consistent with the condition 
# "n is a member of the sequence if and only if a(n) is odd".
# 1, 3, 5, 2, 7, 8, 9, 11, 13, 12, 15, 17, 19, 16, 21, 23, 25, 20, 27, 29, 31

use strict;
use integer;
use warnings;

my %set = ();
my $c = 0 ;
my $i = 0;

my $opt = (scalar(@ARGV) > 0 ? shift(@ARGV) : "");
my $debug = $opt eq "" ? 0 : 1;
for (my $k = 1; $k < 24; $k ++) {
  print &next() . ", ";
} # for $k
print "\n";
#----
sub next() {
    $i ++;
    my $icond = &cond($i);
    my $idef = defined($set{$i}) ? 1 : 0;
    $c = 0;
    while (1) {
        $c ++;
        my $ccond = &cond($c);
        if ($debug) {
            print "i=$i, icond=$icond, c=$c, ccond=$ccond, idef($i)=$idef, cdef($c)=" . (defined($set{$c}) ? 1 : 0) . "\n";
        }
        if (! defined($set{$c})) {
            if ($ccond) { # odd candidate
              if ($idef > 0 || $c == $i) {
                  $set{$c} = 1;
                  return $c;
              }
            } else { # even candidate
              if ($idef == 0 && $c != $i) {
                $set{$c} = 1;
                return $c;
              }
            }
        }
    } # while 1
} # next
#----
sub cond {
    my ($n) = @_;
    return $n & 1;
} # cond
