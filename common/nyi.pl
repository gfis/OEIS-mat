#!perl

# Check whether A-numbers in input file are already implemented in jOEIS
# 2023-06-04: -q; BD=77
# 2023-02-26: #? before nyi aseqnos
# 2023-02-20: -p
# 2023-01-13, Georg Fischer: copied from jcat25.txt
#
#:# Usage:
#:#   perl nyi.pl [-f ofter_file] [-n] [p] [-q cc] [-c|infile] 
#:#     -c read clipboard instead of input file
#:#     -f file with aseqno, offset1, terms (default $(COMMON)/joeis_ofter.txt)
#:#     -n print only those that are not yet implemented in jOEIS (defaul: all)
#:#     -p print the whole file/clipboard
#:#     -q cut to leading A-number and print lines only if all R-numbers are implemented, inset callcode and offset
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $ofter_file = "../common/joeis_ofter.txt";
my $debug      = 0;
my $from_clip  = 0;
my $only_nyi   = 0;
my $print_it   = 0;
my $query      = "";
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
    if ($opt   =~ m{p}) {
        $print_it = 1;
    } 
    if ($opt   =~ m{q}) {
        $query    = shift(@ARGV);
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
if (length($query) == 0) {
    print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";
}
#----------------
my $buffer = "";
my $aseqno;
my $rseqno;
if ($from_clip == 0) { # read from STDIN or files
    while (<>) {
        $buffer .= $_;
    }
} else { # get it from the clipboard
    $buffer = `powershell -command Get-Clipboard`;
}
my %hash = ();
foreach my $line (split(/\n/, $buffer)) {
    my %lasn;
    foreach $rseqno ($line =~ m{(A\d{6})}g) {
        $lasn{$rseqno} = 1;
    } # foreach $rseqno
    foreach $rseqno (keys(%lasn)) {
        if (defined($ofters{$rseqno})) {
            $hash{$rseqno} = 1;
        } else {
            $line =~ s{$rseqno}{\#\?$rseqno}g;
        }
    } # foreach $rseqno
    if (0) {
    } elsif ($print_it > 0) {
        $line =~ s{^\#\?}{}; # assume that the leading column is nyi anyway
        print "$line\n";
    } elsif (length($query) > 0) {
        $line =~ s{^.. (\#\?)?(A\d+) *}{}; # assume that the leading column is nyi anyway
        $aseqno = $2;
        if ($line !~ m{\#\?}) {
            print join("\t", $aseqno, $query, 0, $line) . "\n";
        }
    }
} # $line
my $ari = 0;
my $nyi = 0;
if (length($query) == 0 && $print_it == 0) {
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
}
if (length($query) == 0) {
    print sprintf("# %4d not implemented in jOEIS\n", $nyi);
    print sprintf("# %4d already implemented\n"     , $ari);
}
#================
__DATA__
A004018	parmof2	0	A000144	2	Number of ways of writing n as a sum of 2 squares.
A005875	parmof2	0	A000144	3	Number of ways of writing n as a sum of 3 squares.
A000118	parmof2	0	A000144	4 	Number of ways of writing n as a sum of 4 squares;
A000132	parmof2	0	A000144	5 	Number of ways of writing n as a sum of 5 squares.
