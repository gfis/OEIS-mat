#!perl

# Check whether A-numbers in input file are already implemented in jOEIS
# 2023-01-13, Georg Fischer: copied from jcat25.txt
#
#:# Usage:
#:#   perl aij.pl [-f ofter_file] [n] [-c|infile] 
#:#     -c read clipboard instead of input file
#:#     -f file with aseqno, offset1, terms (default $(COMMON)/joeis_ofter.txt)
#:#     -n print only those that are not yet implemented in jOEIS (defaul: all)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $ofter_file = "../common/joeis_ofter.txt";
my $debug      = 0;
my $from_clip  = 0;
my $only_nyi   = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if ($opt   =~ m{c}) {
        $from_clip = 1;
    } 
    if ($opt   =~ m{d}) {
        $debug      = shift(@ARGV);
    } 
    if ($opt   =~ m{f}) {
        $ofter_file = shift(@ARGV);
    } 
    if ($opt   =~ m{n}) {
        $only_nyi = 1;
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
#----------------
my $buffer = "";
if ($from_clip == 0) { # read from STDIN or files
    while (<>) {
        $buffer .= $_;
    }
} else { # get it from the clipboard
    $buffer = `powershell -command Get-Clipboard`;
}
my %hash = ();
foreach my $aseqno ($buffer =~ m{(A\d{6})}g) {
    if (! defined($hash{$aseqno})) {
        $hash{$aseqno} = defined($ofters{$aseqno}) ? 1 : 0;
    }
} # foreach
my $ari = 0;
my $nyi = 0;
foreach my $key (sort(keys(%hash))) {
    my $value = $hash{$key};
    if ($value == 0) {
        $nyi ++;
    } else {
        $ari ++;
    }
    if ($only_nyi) {
        if ($value <= 0) {
            print join("\t", $key, $value) . "\n";
        }
    } else {
            print join("\t", $key, $value, ($value <= 0) ? "**" : "") . "\n";
    }
} # for $key
print sprintf("%4d not implemented in jOEIS\n", $nyi);
print sprintf("%4d already implemented\n"     , $ari);
#================
__DATA__
A004018	parmof2	0	A000144	2	Number of ways of writing n as a sum of 2 squares.
A005875	parmof2	0	A000144	3	Number of ways of writing n as a sum of 3 squares.
A000118	parmof2	0	A000144	4 	Number of ways of writing n as a sum of 4 squares;
A000132	parmof2	0	A000144	5 	Number of ways of writing n as a sum of 5 squares.
A000141	parmof2	0	A000144	6 	Number of ways of writing n as a sum of 6 squares.
A008451	parmof2	0	A000144	7 	Number of ways of writing n as a sum of 7 squares.
A000143	parmof2	0	A000144	8 	Number of ways of writing n as a sum of 8 squares.
A008452	parmof2	0	A000144	9 	Number of ways of writing n as a sum of 9 squares.
A000144	parmof2	0	A000144	10	Number of ways of writing n as a sum of 10 squares.
A008453	parmof2	0	A000144	11	Number of ways of writing n as a sum of 11 squares.
A000145	parmof2	0	A000144	12	Number of ways of writing n as a sum of 12 squares.
A276285	parmof2	0	A000144	13	Number of ways of writing n as a sum of 13 squares.
A276286	parmof2	0	A000144	14	Number of ways of writing n as a sum of 14 squares.
A276287	parmof2	0	A000144	15	Number of ways of writing n as a sum of 15 squares.
A000152	parmof2	0	A000144	16	Number of ways of writing n as a sum of 16 squares.
A000156	parmof2	0	A000144	24	Number of ways of writing n as a sum of 24 squares.
A302856	parmof2	0	A000144	32	Number of ways of writing n as a sum of 32 squares.