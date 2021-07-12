#!perl

# Generate a recurrence from some root of a polynomial
# @(#) $Id$
# 2021-07-02, Georg Fischer: copied from extract_weidis.pl
#
#:# Usage:
#:#   perl root_matrix -a aseqno -r root polynomial_coefficient_list > seq4-record and make runholo cmd
#---------------------------------
use strict;
use integer;
use warnings;
use POSIX;

my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my @parts = split(/\s+/, asctime(localtime(time)));  #  "Fri Jun  2 18:22:13 2000\n\0"
#                                             0   1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $parts[1], $parts[2], $parts[4]);
#----
my $aseqno = "A100000";
my $root   = 2; # sqrt
my $debug   = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{a}) {
        $aseqno    = shift(@ARGV);
    } elsif ($opt  =~ m{r}) {
        $root      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my $list = shift(@ARGV);
my @poly = ($list =~ m{(\d+)}g);

my $matrix = "[[0]";
my $order = scalar(@poly) - 1;
my $common = undef;
my (@npow0, @npow1);
for (my $l = $order; $l >= 0; $l --) {
    my $n1 = - $root * $poly[$l];            # factor of n^1
    my $n0 =  ($root * $l + $l) * $poly[$l]; # factor of n^0
    push(@npow1, $n1);
    push(@npow0, $n0);
    &accum($n1);
    &accum($n0);
} # for $l
for (my $i = 0; $i < scalar(@npow0); ++$i) {
    my $n1 = $npow1[$i] / $common;
    my $n0 = $npow0[$i] / $common;
    $matrix .= ",[$n0,$n1]";
} # for $i
$matrix .= "]";
print join("\t", $aseqno, "wroot", 0, $matrix, "[1]", 0, 0) . "\n";
print "make runholo MATRIX=\"$matrix\" INIT=\"[1]\"\n";
#--------
sub accum { # accumulate the GCD; global: $common
    my ($n) = @_;
    $n = abs($n);
    if ($n > 0) {
        $common = (! defined($common)) ? $n : &gcd($common, $n);
    }
} # accum
#--------
# c.f. https://github.com/gfis/ramath/src/main/java/org/teherba/ramath/linear/Vector.java
sub gcd { my ($a, $b) = @_;
    my $result = abs($a);
    if ($result != 1) {
        my $p = $result;
        my $q = abs($b);
        while ($q != 0) {
            my $temp = $q;
            $q = $p % $q;
            $p = $temp;
        } # while $q
        $result = $p;
    }
    return abs($result);
} # gcd
__DATA__
