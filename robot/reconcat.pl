#!perl

# Extract recursive concateneations from asdata list
# @(#) $Id$
# 2023-06-30, Georg Fischer
#
#:# Usage:
#:#     perl reconcat.pl [-d debug] asdata-extract > output
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $line;
# while (<DATA>) {
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $termno, $data, $name) = split(/\t/, $line);
    my @terms = split(/\, */, $data);
    my $it = 0;
    my $term = $terms[$it ++];
    my $head = "";
    my $tail = "";
    my $busy = 1;
    while ($busy && $it < scalar(@terms)) {
        if ($terms[$it] =~ m{$term}p) {
            $head .= "," . (${^PREMATCH} || "");
            $tail .= "," . (${^POSTMATCH} || "");
            $term = $terms[$it];
        } else {
            $busy = 0;
        }
        $it ++;
    } # while
    if ($busy) { # success
        $head =~ s{^\,}{};
        $tail =~ s{^\,}{};
        print join("\t", $aseqno, "reconcat", 0, $head, $tail, $name) . "\n";
    } # success
} # while <>
#--------------------------------------------
__DATA__
A000422	150	1,21,321,4321,54321,654321,7654321,87654321,987654321,10987654321,1110987654321,121110987654321,13121110987654321,1413121110987654321,151413121110987654321,16151413121110987654321,1716151413121110987654321,181716151413121110987654321	Concatenation of numbers from n down to 1.
A000461	333	1,22,333,4444,55555,666666,7777777,88888888,999999999,10101010101010101010,1111111111111111111111,121212121212121212121212,13131313131313131313131313,1414141414141414141414141414,151515151515151515151515151515,16161616161616161616161616161616	Concatenate n n times.
A001292	10000	1,12,21,123,231,312,1234,2341,3412,4123,12345,23451,34512,45123,51234,123456,234561,345612,456123,561234,612345,1234567,2345671,3456712,4567123,5671234,6712345,7123456	Concatenations of cyclic permutations of initial positive integers.
A001703	1001	12,123,234,345,456,567,678,789,8910,91011,101112,111213,121314,131415,141516,151617,161718,171819,181920,192021,202122,212223,222324,232425,242526,252627,262728,272829,282930,293031,303132,313233,323334,333435,343536,353637,363738	Decimal concatenation of n, n+1, and n+2.
