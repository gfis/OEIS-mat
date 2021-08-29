#!perl

# Recombine expressions splitted over several seq4 records by expr_split.pl
# @(#) $Id$
# 2021-08-23, Georg Fischer
#
#:# Usage:
#:#   perl expr_join.pl [-d debug] input.seq4 > output.seq4
#
# The records must be sorted by aseqno and callcode, 
# and the callcode ending in "_z" must be the last in each group.
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
my $asel = "0-9a-z"; # select all possible TAB codes
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{a}) {
        $asel      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
my $bufinit = "~~  "; 
my $buffer = $bufinit;
my $r = "";
while (<>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $callcode, $offset, $expr1, @rest) = split(/\t/, $line);
    if (0) {
    } elsif ($callcode =~ s{_z}{}) {
        print join("\t", $aseqno, "$callcode$r", $offset, $expr1, $buffer) . "\n";
        $buffer = $bufinit;
        $r = "";
    } elsif ($aseqno =~ m{\AA\d+}) {
        $callcode =~ m{_(m[A-Z]+)(r)?};
        my $varname = $1;
        if (defined($2)) {
            $r = "r";
        }
        $buffer .= "~~private final CR $varname = $expr1;";
    }
} # while
__DATA__
A189750	floor_mR	0	CR.ONE	1	0	0
A189750	floor_mSr	0	REALS.atan(CR.ONE.divide(CR.THREE))	arctan(1/3)	0	0
A189750	floor_mTr	0	REALS.atan(CR.TWO.divide(CR.THREE))	arctan(2/3)	0	0
A189750	floor_z	0	CR.valueOf(mN).add(CR.valueOf(mN).multiply(mS).divide(mR).floor()).add(CR.valueOf(mN).multiply(mT).divide(mR).floor())	n+floor(n*s/r)+floor(n*t/r)	0	0
A189751	floor_mR	0	CR.ONE	1	0	0
A189751	floor_mSr	0	REALS.atan(CR.ONE.divide(CR.THREE))	arctan(1/3)	0	0
A189751	floor_mTr	0	REALS.atan(CR.TWO.divide(CR.THREE))	arctan(2/3)	0	0
A189751	floor_z	0	CR.valueOf(mN).add(CR.valueOf(mN).multiply(mR).divide(mS).floor()).add(CR.valueOf(mN).multiply(mT).divide(mS).floor())	n+floor(n*r/s)+floor(n*t/s)	0	0
A189756	floor_mR	0	CR.ONE	1	0	0
A189756	floor_mS	0	CR.ONE.sin()	sin(1)	0	0
A189756	floor_mT	0	CR.ONE.cos()	cos(1)	0	0
A189756	floor_z	0	CR.valueOf(mN).add(CR.valueOf(mN).multiply(mS).divide(mR).floor()).add(CR.valueOf(mN).multiply(mT).divide(mR).floor())	n+floor(n*s/r)+floor(n*t/r)	0	0
A189757	floor_mR	0	CR.ONE	1	0	0
A189757	floor_mS	0	CR.ONE.sin()	sin(1)	0	0
A189757	floor_mT	0	CR.ONE.cos()	cos(1)	0	0
A189757	floor_z	0	CR.valueOf(mN).add(CR.valueOf(mN).multiply(mR).divide(mS).floor()).add(CR.valueOf(mN).multiply(mT).divide(mS).floor())	n+floor(n*r/s)+floor(n*t/s)	0	0
