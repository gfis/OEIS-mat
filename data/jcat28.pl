#!perl

# Copy CAT25 file and replace all leading "%" characters by "#" for jOEIS sequences
# 2023-09-28: nyi A-numbers -> "Ännnnnn"
# 2023-05-05: renamed from ../common/jcat25.pl
# 2023-05-01: App(e->a)rent, seem
# 2021-95-30: Conjecture (Start) ... (End)
# 2021-01-21, Georg Fischer
#
#:# Usage:
#:#   perl jcat28.pl [-f ofter_file] [-d debug] [-n nyi-char] cat28.txt > jcat28.txt 
#:#     -d debugging mode: 0=none, 1=some, 2=more
#:#     -n character that replaces "A" in A-numbers that are not yet implemented in jOEIS, e.g. "Ä"
#:#     -f file with aseqno, offset1, terms (default $(COMMON)/joeis_ofter.txt)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my $ofter_file = "joeis_ofter.txt";
my $debug = 0;
my $sharp = "#";
my $nyia = "";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-f}  ) {
        $ofter_file = shift(@ARGV);
    } elsif ($opt   =~ m{\-n}  ) {
        $nyia       = shift(@ARGV); # usually "Ä"
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
    $ofters{$aseqno} = "$offset\t$terms";
} # while <OFT>
close(OFT);
print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";
foreach my $key (("A000001", "A000007", "A183652", "A400000")) {
    print STDERR "$key " . ($ofters{$key} || "undef") . "\n";
}
#----------------
my $oseqno = "";
my $otype  = "-";
my $state  = 0;
my $col1   = "%";

while (<>) { # CAT25 format
    next if length($_) < 11;
    $line = $_;
    my $atype  = substr($line, 1, 1);
    my $aseqno = substr($line, 3, 7); # $1 || "A000000";
    if ($atype ne $otype) {
        if ($state != 0) {
            $state = 0;
            print STDERR "# Start-End overrun in $otype $oseqno\n";
        }
        $otype = $atype;
    }
    if ($aseqno ne $oseqno) {
        $oseqno = $aseqno;
        if (defined($ofters{$aseqno})) {
            $col1 = "#";
        } else {
            $col1 = "%";
        }
    }
    $line =~ s{\A.}{$col1};
    if (0) {
    } elsif ($atype eq "F" && ($line =~ m{Conjecture}i) && ($line =~ m{\(Start\)}i)) {
        $state = 1;
    } elsif ($state == 1   && ($line =~ m{\(End\)}i)) {
        $state = 0;
    }
    if ($state == 1 || ($line =~ m{[Cc]onject|Apparent|Appear|May be|Empiric|Seem})) {
        $line =~ s{\A.}{\?};
    }
    if ($nyia ne "") {
        #                      12 23     31
        substr($line, 11) =~ s{((A)(\d{6}))}{defined($ofters{"$1"}) ? "$1" : "$nyia$3"}eg;
    }
    print $line;
} # while <>
#================
__DATA__
012345678901234567
%I
%I A000001  M0098 N0035
%S A000001 0,1,1,1,2,1,2,1,5,2,2,1,5,1,2,1,14,1,5,1,5,2,2,1,15,2,2,5,4,1,4,1,51,
%T A000001 1,2,1,14,1,2,2,14,1,6,1,4,2,2,1,52,2,5,1,5,1,15,2,13,2,2,1,13,1,2,4,
%U A000001 267,1,4,1,5,1,4,1,50,1,2,3,4,1,6,1,52,15,2,1,15,1,2,1,12,1,10,1,4,2
%N A000001 Number of groups of order n.
%C A000001 Also, number of nonisomorphic subgroups of order n in symmetric group S_n. - _Lekraj Beedassy_, Dec 16 2004
%C A000001 Also, number of nonisomorphic primitives of the combinatorial species Lin[n-1]. - _Nicolae Boicu_, Apr 29 2011