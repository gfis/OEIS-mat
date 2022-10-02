#!perl

# Evaluate 4 variants of the PartitionTransform 
# and search for the results in all sequences
# @(#) $Id$
# 2022-10-01, Georg Fischer
#
#:# Usage:
#:#   cut -f1,3 bfdata.txt \
#:#   | perl ptsearch.pl | tee output.tmp
#---------------------------------
use strict;
use integer;
use warnings;

my $tablname = "ptstabl.tmp";
my ($aseqno, $callcode, $offset, $data);
while(<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    ($aseqno, $callcode, $offset, $data) = split(/\t/, $line);
    my @terms = split(/\,/, $data);
    my ($x1, $x2, $x3, $x4, $x5, $x6) = splice(@terms, 0, 6);
    my @a1 = ($x1, $x2, $x1**2, $x3, 2*$x1*$x2, $x1**3, $x4, 2*$x1*$x3 + $x2**2, 3*$x1**2*$x2, $x1**4, $x5, 2*$x1*$x4 + 2*$x2*$x3, 3*$x1**2*$x3 + 3*$x1*$x2**2, 4*$x1**3*$x2, $x1**5
        , $x6, 2*$x1*$x5 + 2*$x2*$x4 + $x3**2, 3*$x1**2*$x4 + 6*$x1*$x2*$x3 + $x2**3, 4*$x1**3*$x3 + 6*$x1**2*$x2**2, 5*$x1**4*$x2, $x1**6
        );
    my @a0 = ($x1, 0, $x2, $x1**2, 0, $x3, 2*$x1*$x2, $x1**3, 0, $x4, 2*$x1*$x3 + $x2**2, 3*$x1**2*$x2, $x1**4, 0, $x5, 2*$x1*$x4 + 2*$x2*$x3, 3*$x1**2*$x3 + 3*$x1*$x2**2, 4*$x1**3*$x2, $x1**5);
    my @r1 = ($x1, $x1**2, $x2, $x1**3, 2*$x1*$x2, $x3, $x1**4, 3*$x1**2*$x2, 2*$x1*$x3 + $x2**2, $x4, $x1**5, 4*$x1**3*$x2, 3*$x1**2*$x3 + 3*$x1*$x2**2, 2*$x1*$x4 + 2*$x2*$x3, $x5);
    my @r0 = ($x1, 0, $x1**2, $x2, 0, $x1**3, 2*$x1*$x2, $x3, 0, $x1**4, 3*$x1**2*$x2, 2*$x1*$x3 + $x2**2, $x4, 0, $x1**5, 4*$x1**3*$x2, 3*$x1**2*$x3 + 3*$x1*$x2**2, 2*$x1*$x4 + 2*$x2*$x3, $x5);
    &search("a1", @a1);
    # &search("a0", @a0);
    # &search("r1", @r1);
    # &search("r0", @r0);
} # while <>
#----
sub search {
    my ($code, @a) = @_;
    my $alist = join(",", @a);
    return if $alist !~ m{[\-2-9]};
    return if $alist eq "1,1,1,1,2,1,1,3,3,1,1,4,6,4,1,1,5,10,10,5,1";
    my $found = 0;
    foreach my $line (split(/\r?\n/, `grep -P \"\\t$alist\" $tablname`)) {
        $found ++;
        if ($found == 1) {
            print "========\n" if $code eq "a1";
            print join("\t", $aseqno, "--$code", 0, $alist) . "\n";
        }
        my ($rseqno, $dummy, $offset, $data) = split(/\t/, $line);
        print join("\t", $rseqno, "..$code", $offset, substr($data, 0, 64)) . "\n";
    }
} # while <>
__DATA__
A000001 search  0       0,1,1,1,2,1,2
A000002 search  1       1,2,2,1,1,2,1
A000003 search  1       1,1,1,1,2,2,1
A000004 search  0       0,0,0,0,0,0,0

A000369 tabl    1       1,3,1,21,9,1,231,111,18