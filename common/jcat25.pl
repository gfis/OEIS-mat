#!perl

# Copy CAT25 file and replace all leading "%" characters by "#" for jOEIS sequences
# 2021-01-21, Georg Fischer
#
#:# Usage:
#:#   perl jcat25.pl [-f ofter_file] $(COMMON)/cat25.txt > cat25j.txt \
#:#     -f  file with aseqno, offset1, terms (default $(COMMON)/joeis_ofter.txt)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my $ofter_file = "../../OEIS-mat/common/joeis_ofter.txt";
my $debug = 0;
my $sharp = "#";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-f}  ) {
        $ofter_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
my $terms;
my %ofters = ();
open (OFT, "<", $ofter_file) || die "cannot read $ofter_file\n";
while (<OFT>) {
    s{\s+\Z}{};
    my ($aseqno, $offset, $terms) = split(/\t/);
    $terms = $terms || "";
    if ($offset < -1) { # offsets -2, -3: strange, skip these
    } else {
        $ofters{$aseqno} = "$offset\t$terms";
    }
} # while <OFT>
close(OFT);
print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";
#----------------
my $oseqno = "";
my $repl = 0;
while (<>) { # CAT25 format
    $line = $_;
    m{\A.. (A\d+)};
    my $aseqno = $1 || "A000000";
    if ($oseqno ne $aseqno) {
        $oseqno = $aseqno;
        $repl = defined($ofters{$aseqno}) ? 1 : 0;
    }
    if ($repl && (substr($line, 0, 1) ne $sharp)) {
        print $sharp . substr($line, 1);
    } else {
        print $line;
    }
} # while <>
#================
__DATA__
%I
%I A000001  M0098 N0035
%S A000001 0,1,1,1,2,1,2,1,5,2,2,1,5,1,2,1,14,1,5,1,5,2,2,1,15,2,2,5,4,1,4,1,51,
%T A000001 1,2,1,14,1,2,2,14,1,6,1,4,2,2,1,52,2,5,1,5,1,15,2,13,2,2,1,13,1,2,4,
%U A000001 267,1,4,1,5,1,4,1,50,1,2,3,4,1,6,1,52,15,2,1,15,1,2,1,12,1,10,1,4,2
%N A000001 Number of groups of order n.
%C A000001 Also, number of nonisomorphic subgroups of order n in symmetric group S_n. - _Lekraj Beedassy_, Dec 16 2004
%C A000001 Also, number of nonisomorphic primitives of the combinatorial species Lin[n-1]. - _Nicolae Boicu_, Apr 29 2011