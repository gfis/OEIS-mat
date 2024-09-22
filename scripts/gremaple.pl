#!perl

# @(#) $Id$
# 2024-08-27, Georg Fischer
#
#:# Filter records, extract callcodes for cmaple into a file and execute them
#:# Usage:
#:#   perl gremaple.pl [-d mode] [-t timeout] infile.seq4 > outfile.seq4
#:#       -d debugging mode: 0=none, 1=some, 2=more
#:#       -t timeout in seconds (default 60)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $cmaple     = "\"C:/Program Files/Maple 2022/bin.X86_64_WINDOWS/cmaple.exe\"";
my $filename   = "gremaple.tmp";
my $cmaple_cmd = "$cmaple -q $filename";

my $debug   = 0;
my $timeout = "60";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  eq "-d") {
        $debug     =  shift(@ARGV);
    } elsif ($opt  eq "-t") {
        $timeout   =  shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my %maple_cc = qw(
    halg 1
    hfre 1
    );
open(TMP, ">", $filename) || die "cannot write $filename";
print TMP << "GFis";
interface(prettyprint=0,ansi=false):
with(gfun):
with(FPS):
halg:=proc(aseqno, ae, egf:=0):
timelimit($timeout
GFis
print TMP << 'GFis';
  , printf("%a\tbva\t0\t%a\t\t%a\t%a\t%a\n", aseqno
  , diffeqtorec(AlgtoHolonomicDE(ae,A(x)),A(x),a(n))
  , 0, egf, ae)):
end:
GFis
print TMP << "GFis";
hfre:=proc(aseqno, ae, egf:=0):
timelimit($timeout
GFis
print TMP << 'GFis';
  , printf("%a\tbva\t0\t%a\t\t%a\t%a\t%a\n", aseqno
  , FindRE(ae,x,a(n))
  , 0, egf, ae)):
end:
C     := proc(x) (1 - sqrt(1 - 4*x)) / (2*x) end: # A000108 Catalan's g.f.
Catlan:= proc(x) (1 - sqrt(1 - 4*x)) / (2*x) end:
GFis

#while (<DATA>) {
while (<>) {
    if (m{\AA\d+\s}) { # starts with A-number tab
        s/\s+\Z//; # chompr
        my ($aseqno, $callcode, $offset1, @parms) = split(/\t/);
        if (defined($maple_cc{$callcode})) {
            print TMP "$callcode(" . join(", ", $aseqno, @parms) .");\n";
        }
    }
} # while
close(TMP);
my $result = `$cmaple_cmd`;
print "$result\n";
__DATA__
# test data
A374542	hfre	0	((4*x - 1)*(4*x^4 - 22*x^3 + 25*x^2 - 9*x + 1) - (2*x - 1)*(x^2 - 5*x + 1)*(2*x^2 - 4*x + 1)*sqrt(1 - 4*x))/(2*x^3*(4*x - 1)*(x - 1)^2)
A249932	halg	0	-1-x+2*A^4-A^7
A249786	halg	0	(A^2 - 4*x)^3  - (2 - A^3)^2	1
