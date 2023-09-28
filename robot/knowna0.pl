#!perl

# Derive simple transformations from known A-numbers
# @(#) $Id$
# 2023-09-25, Georg Fischer
#
#:# Usage:
#:#   perl knowna0.pl input.seq4 > output.seq4
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
my ($aseqno, $callcode, $offset, $name, $rseqno);
# while (<DATA>) {
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $line =~ s/  +/ /g; # only single spaces
    my ($aseqno, $callcode, $offset, $name) = split(/\t/, $line);
    $name =~ s{^ *a\(n\) *\= *}{}; # remove any "a(n) = "
    if ($name =~ m{(A\d{6})}) { # always
        $rseqno = $1;
        print join("\t", ($aseqno, $callcode, $offset, $rseqno, $name)) . "\n";
    }
} # while <>
#--------------------------------------------
__DATA__
A049288 knownf  0       a(n) = A002086(n) for squarefree 2n-1. - _Andrew Howroyd_, Apr 28 2017
A049297 knownf  0       a(n) = A056391(n) for squarefree n.