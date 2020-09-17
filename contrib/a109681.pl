#!perl

# A109681 "Sloping ternary numbers": write numbers in ternary under each other 
# (right-justified), read diagonals in upward direction, convert to decimal.
# @(#) $Id$
# 2020-03-13, Georg Fischer
#
#:# Usage:
#:#   perl a109681.pl [no_terms] > b109681.txt
#---------------------------------
use strict;
use integer;
use warnings;

my $no_terms = scalar(@ARGV) > 0 ? shift(@ARGV) : 32;
my $base     = scalar(@ARGV) > 0 ? shift(@ARGV) : 3; # ternary
my $bm1      = $base - 1;
my $pattern  = qr(\A${bm1}+\Z);
my $bfind = 0; # index for b-file

my @a = (); # stores all ternary numbers
my $ind = 0; # index over @a
while ($ind < $no_terms) { # over all numbers
    my $num3 = &to_base($ind);
    $a[$ind] = $num3;
    my $len = length($num3);
    my $diag = ""; # assemble the diagonal here
    for (my $inum = 0; $inum < $len; $inum ++) {
        my $prev = $a[$ind - $inum]; # some previous element
        $diag .= substr($prev, $inum - ($len - length($prev)), 1);
    } # for $inum
    if ($num3 !~ m{$pattern}) { # skip if all two's - diagonal starts at the next element
        # print "# $ind:\t" . sprintf("num3=%16s", $num3) ."\t -> $diag\t\t\t"; # debug
        print "$bfind " . &from_base($diag) . "\n";
        $bfind ++;
    }
    $ind ++;
} # while $ind
#--------
sub to_base { # convert from decimal to base
    my ($num)  = @_;
    my $result = "";
    while ($num > 0) {
        my $digit = $num % $base;
        $result =  $digit . $result;
        $num /= $base;
    } # while > 0
    return $result eq "" ? "0" : $result; 
} # to_base
#--------
sub from_base { # convert a string (maybe with letters) from base to decimal
    my ($num)  = @_;
    my $bpow   = 1;
    my $result = 0;
    my $pos    = length($num) - 1;
    while ($pos >= 0) { # from backwards
        my $digit = substr($num, $pos, 1);
        if ($digit < 0) {
            print STDERR "invalid digit in number $num\n";
        }
        $result += $digit * $bpow;
        $bpow   *= $base;
        $pos --;
    } # positive
    return $result; 
} # from_base
#--------
__DATA__
  number  upward sloping diagonal
      0   0  
      1   1
      2   (no diagonal 2)
     10   12
     11   10 
     12   11
     20   22 
     21   20
     22   (no diagonal 21) 
    100   121
    101   102
    102   100
    110   101
    111   112
    112   110
    ...   ...
giving (decimal) 0, 1, 5, 3, 4, 8, 6, 16, 11, 9, 10, 14, 12, ...

