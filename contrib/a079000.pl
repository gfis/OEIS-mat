#!perl
# 2022-06-07, Georg Fischer
# A079000 a(n) is taken to be the smallest positive integer greater than a(n-1) which is consistent 
# with the condition &quot;n is a member of the sequence if and only if a(n) is odd&quot;.
use strict;
use integer;
use warnings;

my %set = ();
my $c = 0 ;
my $i = 0;

for (my $k = 1; $k < 16; $k ++) {
  print "  next $k: " . &next() . "\n";
}
#----
sub next() {
    $i ++;
    my $icond = &cond($i);
    my $idef = defined($set{$i}) ? 1 : 0;
    while (1) {
        $c ++;
        my $ccond = &cond($c);
        print "i=$i, icond=$icond, c=$c, ccond=$ccond, def($i)=$idef\n";
        if ($ccond) { # odd candidate
          if ($idef > 0 or $c == $i) {
              $set{$c} = 1;
              return $c;
          }
        } else { # even candidate
          if ($idef == 0 && $c != $i) {
            $set{$c} = 1;
            return $c;
          }
        }
        print "\n";
    } # while 1
} # next
#----
sub cond {
    my ($n) = @_;
    return $n & 1;
} # cond
