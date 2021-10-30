#!perl

# A055256, 1-based
# 2021-10-27, Georg Fischer
#
#:# Usage:
#:#   perl a055356.pl 
#--------------------------------------------------------
use strict;
use integer;
use warnings;

# 1-based:
my @rold; push(@rold, 0, 1);
my @rnew; push(@rnew, 0, 0);
for (my $n = 1; $n <= 8; $n ++) {
    @rnew = (0,0,0,0,0,0,0,0,0,0,0,0,0);
    for (my $k = 0; $k <= $n; $k ++) {
      # print "n=$n, k=$k, t[k]=$rold[$k], T(n-1,k-1)=" . &tri($n-1, $k-1) . ", T(n-1,k)=" . &tri($n-1, $k) . "\n"; 
      my $term = &tri($n-1, $k-1) * ($n - 2) + &tri($n-1, $k) * $k;
      $rnew[$k] = $k == 0 ? 0 : $term;
      print "$term\t";
    } # for $k
    print "\n";
    @rold = @rnew;
} # for $n

sub tri {
    my ($n, $k) = @_;
    if ($k < 1 || $k > $n + 1) {
        return 0;
    } else {
        return $rold[$k];
    }
} # sub T

__DATA__
# 0-based:
my @t = (1);
my @u = (0);
my ($n, $k);
for (my $n = 0; $n <= 10; $n ++) {
    for (my $k = 0; $k <= $n; $k ++) {
      my $term = ($n - 1) * &T($n-1, $k-1) + ($k + 1) * &T($n-1, $k);
      $u[$k] = $term;
      print "$term\t";
    } # for $k
    print "\n";
    @t = @u;
    push(@t, 0);
} # for $n

sub T {
    my ($n, $k) = @_;
    $n ++;
    if ($k < 0 || $k > $n) {
        return 0;
    } else {
        return $t[$k];
    }
} # sub T
#--------
rold = [1];
rnew = [];
for n from 1 to 8 do 
  for k from 1 to n do 
    rnew[k] = rold[k - 1] * (n - 2) + rold[k] * k;
    
  end;
  seq(rnew[i], i=1..n);
  rold = rnew;
end;