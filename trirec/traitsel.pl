#!perl

# Select a subset of traits
# @(#) $Id$
# 2021-10-21: -s id; check ofter_file
# 2021-10-09, Georg Fischer: copied from wraptr_prepare.pl
#
#:# Usage:
#:#   java org.teherba.ramath.sequenc.Triangle -d 0 -border -b ../common/bfile -f traits1.tmp -m 528 \
#:#   | perl traitsel.pl [-d mode] [-f ofter_file] [-m min_len] [-s subset-list] > output.seq4
#:#       -d debugging mode
#:#       -f file with aseqno, offset1, terms (default $(COMMON)/joeis_ofter.txt)
#:#       -m ignore the block if the main entry has len < limit
#:#       -s selection of traits: ls,rs,co,ic,pa,ip,id; the last is the main one
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
print "# generated by trirec/traitsel.pl $timestamp\n";

my @parms;
my %abbrev = qw(ls LeftSide rs RightSide co Constant ic InnerConstant pa Pascal ip InnerPascal id InnerDiff);
my %subset = ();

if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug   = 0;
my $min_len = 1;
my $abbs    = "ls,rs,ip";
my $ofter_file = "../common/joeis_ofter.txt";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt   =~ m{\-f}  ) {
        $ofter_file = shift(@ARGV);
    } elsif ($opt  =~ m{l}) {
        $min_len   = shift(@ARGV);
    } elsif ($opt  =~ m{s}) {
        $abbs      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
my $aseqno;
my $offset = 1;
my $terms;
my %ofters = ();
open (OFT, "<", $ofter_file) || die "cannot read $ofter_file\n";
while (<OFT>) {
    s{\s+\Z}{};
    ($aseqno, $offset, $terms) = split(/\t/);
    $terms = $terms || "";
    if ($offset < -1) { # offsets -2, -3: strange, skip these
    } else {
        $ofters{$aseqno} = "$offset\t$terms";
    }
} # while <OFT>
close(OFT);
print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";
#----------------
my $main_trait; # the main trait to be selected
foreach my $abb (split(/\W+/, $abbs)) {
    $main_trait = $abbrev{$abb};
    if (! defined($main_trait)) {
        die "**traisel.pl: invalid trait abbreviation \"$abb\"\n";
    } else {
        $subset{$main_trait} = 1;
    }
} # foreach $abb

my $buffer = "";
my ($trait, $len, $list);
# while (<DATA>) {
while (<>) {
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    if ($line =~ m{\A(A\d+)}) {
        $line =~ s{\t[\.\_]+}{\t}g;
        ($aseqno, $trait, $len, $list) = split(/\t/, $line, -1);
        if (! defined($ofters{$aseqno})) { # not yet in jOEIS
            if (defined($subset{$trait})) { # in subset
                $buffer .= "$line\n";
                if ($trait eq $main_trait) { # end of block
                    if ($len >= $min_len) { # long enough
                        print $buffer;
                        print "#--------\n";
                    }
                    $buffer = "";
                } # eob
            } # in subset
        } # not yet in jOEIS
    } # with aseqno
} # while <>
#----------------
__DATA__
A005145	Pascal	0
A005145	InnerPascal	0
A007318	LeftSide	32	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
A007318	RightSide	32	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
A007318	Border	30	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
A007318	Constant	0
A007318	InnerConstant	0
A007318	Pascal	1	1
A007318	InnerPascal	1	1
A007723	LeftSide	32	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
A007723	RightSide	32	1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
A007723	Border	0
