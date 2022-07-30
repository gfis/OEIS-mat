#!perl

# Test bfdata.txt for termno >= 30 and a(2)*a(3)*a(5) = a(30)
# @(#) $Id$
# 2022-07-22, Georg Fischer
#
#:# usage:
#:#   perl bfmult30.pl infile > outfile
#:#   infile has aseqno, offset, termno, bfimax, datalist
#---------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @primes = (2,3,5,7,11,13,17,19,23,29,31,37,41);
my @a; # the terms
my $asize; # scalar(@a);

my ($aseqno, $offset, $termno, $bfimax, $datalist);
while (<>) {
    s{\s+\Z}{}; # chompr
    next if ! m{\AA\d};
    ($aseqno, $offset, $termno, $bfimax, $datalist) = split(/\t/);
    if ($offset >= 2) { # ignore
    } else {
        while ($offset < 1) {
            $datalist =~ s{\A\-?\d+\,}{}; #remove a term
            $offset ++;
        } # while
        if (substr($datalist, 0, 2) eq "1,") { # start with 1
            @a = split(/\, */, $datalist);
            unshift(@a, 0); # prefix with 0; a(1)=1
            while (length($a[$#a]) >= 18) { # remove long terms from the end
                pop(@a);
            } # while long
            $asize = scalar(@a);
            my $result = &prime_test();
            if ($result > 0) {
                print join("\t", $aseqno, "mult30", $offset, $bfimax, $result) . "\n";
            }
        }
    } # offset ok
} # while <>
#----
sub prime_test {
    my $result = 0;
    if ($asize >   6) { if ($a[ 2] * $a[ 3]          == $a[  6]) { $result =  6; }} else { return $result; }
    if ($asize >  10) { if ($a[ 2] * $a[ 5]          == $a[ 10]) { $result = 10; }} else { return $result; }
    if ($asize >  14) { if ($a[ 2] * $a[ 7]          == $a[ 14]) { $result = 14; }} else { return $result; }
    if ($asize >  21) { if ($a[ 3] * $a[ 7]          == $a[ 21]) { $result = 21; }} else { return $result; }
    if ($asize >  30) { if ($a[ 2] * $a[ 3] * $a[ 5] == $a[ 30]) { $result = 30; }} else { return $result; }
    if ($asize >  42) { if ($a[ 2] * $a[ 3] * $a[ 7] == $a[ 42]) { $result = 42; }} else { return $result; }
    if ($asize >  66) { if ($a[ 2] * $a[ 3] * $a[11] == $a[ 66]) { $result = 66; }} else { return $result; }
    return $result;
} # prime_test
#----------------------
__DATA__
