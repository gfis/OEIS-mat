#!perl

# Get e.g.f.s from implemented sequences
# @(#) $Id$
# 2025-06-08, Georg Fischer; *FP=11
#
#:# Usage:
#:#     perl getegf.pl [-d mode] input.pack > output.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($aseqno, $callcode, $offset, $polys, @rest, $postfix);
while (<>) {
#while (<DATA>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if (0) {
    } elsif ($line =~ m{\A *\* *(A\d{6})}) {
        $aseqno = $1;
    } elsif ($line =~ m{\A *\* *E\.g\.f\.\: *(.*)}) {
        $postfix = $1;
        $postfix =~ s{\.\Z}{};
        $postfix =~ s{\s}{}g;
        $postfix =~ s{\<\/?code\>}{}g;
        $postfix =~ s{arcsin}{asin}g;
        print join("\t", $aseqno, "poly", 0, "\"[1]\"", $postfix, " ", " ", " ", " ", " ", " * E.g.f.: $postfix.") ."\n";
    }
} # while <>
#--------------------------------------------
__DATA__
/**
 * A355111 Expansion of e.g.f. 3 / (4 - 3*x - exp(3*x)).
 * E.g.f.: 3 / (4 - 3*x - exp(3*x))
 * @author Georg Fischer
 */
public class A355111 extends ExponentialGeneratingFunction {

  /** Construct the sequence. */
