#!perl

# Change A-numbers into D-/K-/M-/F-numbers for DirectSequences, known formulas, MemorySequences and Functions.* 
# @(#) $Id$
# 2024-06-15: with D/K/M/F
# 2024-05-14, Georg Fischer: copied from ../sortprep.pl
#
#:# Usage:
#:#   perl endirect.pl [-f directfile] [-c] infile > outfile
#:#       -c read from clipboard
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my $pwd = `pwd`;
my $procname;
$pwd =~ m{(/gits/)};
my $gits = $`. "/gits"; # prematch

my $debug   = 0;
my $clip    = 0; # whether to read from clipboard instead from <>
my $vector_file = "$gits/joeis-lite/internal/fischer/reflect/vector.txt";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{c}) {
        $clip      = 1;
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{v}) {
        $vector_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

open(VEC, "<", $vector_file) || die "cannot read $vector_file";
my $line = <VEC>;
close(VEC);
my @vector = split(//, $line);
my $veclen = scalar(@vector);

while (<>) {
    my $line = $_;
    if ($debug >= 1) {
        print "# line=$line";
    }
    foreach my $aseqno ($line =~ m{\b([€AB-HJKSTUX]\d{6})}g) {
        my $seqno = substr($aseqno, 1);
        my $nseqno = ($seqno < $veclen) ? "$vector[$seqno]$seqno" : "A$seqno";
        $line =~ s{$aseqno}{$nseqno};
    } # foreach
    print $line;
} # while <>
__DATA__
#	F	A339420	a(n)=Sum_{k=(\d+),n}Annn(k)*Annn(n-k)	0	A023358,A323633
%	F	A073118	a(n)=Sum_{k=(\d+),n}Annn(k)*Annn(n-k)	1	A008472,A000041
%	F	A073119	a(n)=Sum_{k=(\d+),n}Annn(k)*Annn(n-k)	1	A007814,A000041
%	F	A073336	a(n)=Sum_{k=(\d+),n}Annn(k)*Annn(n-k)	1	A046951,A000041
%	F	A090319	a(n)=Sum_{k=(\d+),n}Annn(k)*Annn(n-k)	0	A003149,A003149
%	F	A338223	a(n)=Sum_{k=(\d+),n}Annn(k)*Annn(n-k)	0	A014968,A014968
%	F	A342228	a(n)=Sum_{k=(\d+),n}Annn(k)*Annn(n-k)	1	A035316,A000041
%	F	A342229	a(n)=Sum_{k=(\d+),n}Annn(k)*Annn(n-k)	1	A113061,A000041
%	F	A342230	a(n)=Sum_{k=(\d+),n}Annn(k)*Annn(n-k)	1	A001511,A000041
%	F	A342231	a(n)=Sum_{k=(\d+),n}Annn(k)*Annn(n-k)	1	A038712,A000041
#	T	A008292
