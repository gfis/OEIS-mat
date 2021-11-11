#!perl

# Analyze the output of transpose.pl and detect matching pairs
# @(#) $Id$
# 2021-11-10, Georg Fischer
#
#:# Usage:
#:#   perl transpose.pl ... | sort -k5,5 -k2,2 \
#:#   | perl transpose_detect.pl > outfile
#:#       infile  has the tab-separated format: aseqno, "original|transpose" termno initial_terms remaining_terms
#:#       outfile has the tab-separated format: aseqno, "transpose" termno rseqno inita initr     rest
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (scalar(@ARGV) < 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $split = 0;
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{s}) {
        $split     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($oseqno, $occ, $ooff, $oinit, $orest);
my ($nseqno, $ncc, $noff, $ninit, $nrest);
$oseqno = "";
$orest  = "";
# while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    ($nseqno, $ncc, $noff, $ninit, $nrest) = split(/\t/);
    $nrest = $nrest || "";
    if (($nrest eq $orest) && ($nseqno ne $oseqno)) {
       print join("\t", $oseqno, "transpose", $ooff, $nseqno, $oinit, $ninit, $orest) . "\n";
    }
    ($oseqno, $occ, $ooff, $oinit, $orest) =
    ($nseqno, $ncc, $noff, $ninit, $nrest);
} # while <>
#--------------------------------------------
__DATA__
