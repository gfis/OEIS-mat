#!perl

# Prepare result of grep -E "[PCD]\-finite"
# @(#) $Id$
# 2022-07-29, Georg Fischer
#
#:# Usage:
#:#     find ajson -iname "*.json" | sort | grep -iHE "[PCD]\-finite" > dfinite.tmp
#:#     perl dfinite.pl [-d debug] dfinite.tmp > output.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;

my $mode = "bf";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $line;
my ($aseqno, $recur, $callcode, $name);
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $callcode = ($line =~ s{Conjecture\:? *}{}) ? "holocj" : "holope";
    $line =~ s{\Aajson\/(A\d+)\.json\:\t+\"(.*)}{$1};
    ($aseqno, $name) = ($1, $2);
    next if ($name =~ m{appears });
    $name =~ s{\A.*[PCD]\-finite (with )?[Rrecun]+\:? *}{};
    $name =~ s{Expansion satisfies }{};
    $name =~ s{\(of order \d+\)\:?}{};
    if ($name =~ m{a\(n}) {
        print join("\t", $aseqno, $callcode, 0, $name) . "\n";
    }
} # while <>
#--------------------------------------------
__DATA__
ajson/A047665.json:             "D-finite with recurrence: n*(2*n-3)*a(n) = (2*n-1)*(7*n-10)*a(n-1) - (2*n-3)*(7*n-4)*a(n-2) + (n-2)*(2*n-1)*a(n-3). - _Vaclav Kotesovec_, Oct 08 2012",
ajson/A047749.json:             "Conjecture D-finite with recurrence: 8*n*(n+1)*a(n) + 36*n*(n-2)*a(n-1) - 6*(9n^2-18n+14)*a(n-2) - 27*(3n-7)*(3n-8)*a(n-3) = 0. - _R. J. Mathar_, Dec 19 2011",
ajson/A047781.json:             "D-finite with recurrence n*(2*n-3)*a(n) - (12*n^2-24*n+8)*a(n-1) + (2*n-1)*(n-2)*a(n-2) = 0. - _Vladeta Jovovic_, Aug 29 2004",
ajson/A047891.json:             "D-finite with recurrence: (n+2)*(n+3)*a(n+3) - 6*(n+2)^2*a(n+2) - 12*(n)^2*a(n+1) + 8*n*(n-1)*a(n) = 0. (End)",


make runholo A=A347855 OFF=0 MATRIX="[[0],[385,-2208,3040,-1536,256],[-216],[0],[0,-6,13,-9,2]]" INIT="1, 9, 189" ??