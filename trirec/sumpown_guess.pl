#!perl

# Guess "Sums of powers of m" 
# @(#) $Id$
# 2021-10-18, Georg Fischer
#
#:# Usage:
#:#   grep -P "\t2\," bfdata.txt \
#:#   | perl sumpown_guess.pl > output
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
while (<>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $termno, $data) = split(/\t/, $line);
    my @terms = split(/\,/, $data);
    if (scalar(@terms) > 10 && $terms[0] == 2) {
        my $b  = $terms[1] - 1;
        my $b2 = $b * $b;
        my $b3 = $b2 * $b;
        if (($b > 2 or ($aseqno eq "A173786"))
            && $terms[2] == $b  + $b 
            && $terms[3] == 1   + $b2
            && $terms[4] == $b  + $b2
            && $terms[5] == $b2 + $b2
            && $terms[6] == 1   + $b3
            && $terms[7] == $b  + $b3
           ) {
            print join("\t", $aseqno, "parm2", 0, "A055235", $b, substr($data, 0, 32)) . "\n";
        } # pattern of 6 initial terms
    } # start with 2
} # while <>
__DATA__
# A073423	parm2	0	A055235	0
# A007395	parm2	0	A055235	1
A173786	parm2	0	A055235	2
A055235	parm2	0	A055235	3
A055236	parm2	0	A055235	4
A055237	parm2	0	A055235	5
A055257	parm2	0	A055235	6
A055258	parm2	0	A055235	7
A055259	parm2	0	A055235	8
A055260	parm2	0	A055235	9
A052216	parm2	0	A055235	10
A073211	parm2	0	A055235	11
A194887	parm2	0	A055235	12
A072390	parm2	0	A055235	13
A055261	parm2	0	A055235	16
A073213	parm2	0	A055235	17
A073214	parm2	0	A055235	19
A073215	parm2	0	A055235	23
