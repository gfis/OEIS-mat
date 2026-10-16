#!perl

# Postprocess output of target anan1
# @(#) $Id$
# 2026-10-12, Georg Fischer; *IP=52
#
#:# Usage:
#:#     perl anan1.pl [-d mode] input > output.seq4
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options
#----------------
my $cond;
my $nok;
while (<>) {
# while (<DATA>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $name) = split(/\t/, $line);
    my $callcode = "bnbn1";
    my $offset   = "0";
    $name =~ s{ *a\(n\) *\= *}{};
    #              1        1   2           2     3              3       4           4   
    if ($name =~ m{([B-Z]\d+)\(n( *[\+\-] *1)?\) *([\+\-\*\/]|mod) *\1\(n( *[\+\-] *1)?\)}) {
        my $parm1 = "new A" . substr($1, 1) . "()";
        my $parm2 = "() -> mB.$3(mB1)";
        print join("\t", $aseqno, $callcode, $offset, $parm1, $parm2, $name) . "\n";
    } else {
        print STDERR $line . "\n";
    }
} # while <>
__DATA__
A090228	a(n) = J090206(n)*J090206(n+1). - _David Wasserman_, Oct 13 2005
A092667	a(n) = J038034(n) - J038034(n-1).
A095222	a(n) = J053067(n+1) mod J053067(n). - _Hagen von Eitzen_, Jun 17 2009
A103297	a(n) = J004137(n+1) - J004137(n) for n>= 1.
A104190	a(n) = (E099825(n+1) - E099825(n)) - (J033844(n+1) - J033844(n)). - _Amiram Eldar_, Jun 04 2025
A104854	a(n) = 2*J000111(n+1)-J000111(n) [Berry et al., 2013] (but compare J231895). - _N. J. A. Sloane_, Nov 18 2013
A105035	a(n) = 2^J034797(n-1) - J034797(n-1). - _Max Alekseyev_, Mar 16 2023
