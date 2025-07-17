#!perl

use strict;
use warnings;
use integer;

for (my $n = 0; $n < 64; $n ++) {
  # print ", " . &ror2($n); # 0, 1, 2, 3, 1, 3, 5, 7, 2, 6, 10, 14, 3, 7, 11, 15, 4, 12, 20, 28,  5, 13, 21, 29, 6, 14, 22, 30, 7,
    print ", " . &rol2($n); # 0, 1, 2, 3, 2, 6, 3, 7, 2, 6, 10, 14, 3, 7, 11, 15, 2,  6, 10, 14, 18, 22, 26, 30,
}   
print "\n";

sub rol  { # A006257 Josephus problem
  my ($x) = @_;
  my $rep = sprintf("%b", $x);
  return oct("0b" . substr($rep, 1) . substr($rep, 0, 1));
}
sub rol2 { # 
  my ($x) = @_;
  my $rep = sprintf("%b", $x);
  return $x <= 3 ? $x : oct("0b" . substr($rep, 2) . substr($rep, 0, 2));
}
sub ror  { # A038572
  my ($x) = @_;
  my $last = $x & 1;
  $x /= 2;
  my $rep = $x == 0 ? "" : sprintf("%b", $x);
  return oct("0b$last$rep");
}
sub ror2 { # 
  my ($x) = @_;
  my $last = sprintf("%b", $x & 3);
  $x /= 4;
  my $rep = $x == 0 ? "" : sprintf("%b", $x);
  return oct("0b$last$rep");
}
