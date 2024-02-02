#!perl

# Grep gcd formulas from jcat25: %F A325975 a(n) = gcd(A325977(n), A325978(n)).
# @(#) $Id$
# 2024-01-26, Georg Fischer
#
#:# Usage:
#:#   perl gcd.rob.pl > gcd.gen
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min);
my $progname = $0;
print "# Generated by $progname at $timestamp\n";

my $CAT = "../common/jcat25.txt";
my $pattern = "^\\%[NF] A\\d+ *a\\(n\\) *\\= *(gcd|GCD)\\(A\\d+\\(n( *\\+ *1)?\\)\\, *A\\d+\\(n( *\\+ *1)?\\)\\) *[\\..|\\=]*";
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
print "# $pattern\n" if $debug > 0;;

foreach my $line (split(/\r?\n/, `grep -P \"$pattern\" $CAT`)) {
    print "# $line\n" if $debug > 0;;
    my ($type, $aseqno, $rest) = split(/ +/, $line, 3);
    my @rseqnos = ($rest =~ m{(A\d+)}g);
    if ($rest =~ m{\(n *\+ *1\)}) {
        if ($rseqnos[0] eq $rseqnos[1]) {
            print join("\t", $aseqno, "tuptraf", 0, "(n, s) -> s[0].gcd(s[1])", "\"\"", "new $rseqnos[0](), PREVIOUS") ."\n";
        } else {
            print STDERR "$line\n";
        }
    } else {
        print join("\t", $aseqno, "tuptraf", 0, "(n, s) -> s[0].gcd(s[1])", "\"\"", "new $rseqnos[0](), new $rseqnos[1]()") ."\n";
    }
} # foreach $line
#--------------------------------------------
__DATA__
%N A325975 a(n) = gcd(A325977(n), A325978(n)).
%F A325975 a(n) = gcd(A325977(n), A325978(n)).
%N A326129 a(n) = gcd(A326127(n), A326128(n)).