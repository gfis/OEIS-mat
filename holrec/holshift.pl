#!perl

# Shift a few numbers from the beginning of a field 
# @(#) $Id$
# 2019-12-29, Georg Fischer
#
#:# Usage:
#:#   perl holshift.pl [-f seqnos] [-k fieldno] [-s count] infile > outfile
#:#       -f  file with applicable A-numbers 
#:#       -k  fieldno 0, 1 ... (default 4)
#:#       -s  count of numbers to remove (default 1)
#:#       infile: lines with aseqno tab offset1 tab polys tab inits ...
#:#                          0          1           2         3 
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $asnfile = "holgf.tmp";
my $kfno    = 4;
my $scount  = 1;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{f}) {
        $asnfile   = shift(@ARGV);
    } elsif ($opt  =~ m{k}) {
        $kfno      = shift(@ARGV);
    } elsif ($opt  =~ m{s}) {
        $scount    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my %aseqnos = ();
open(ASN, "<", $asnfile) || die "cannot read \"$asnfile\"\n";
my $count = 0;
while (<ASN>) {
    if (m{\A(A\d+)\s+}) {
        my $aseqno = $1;
        $aseqnos{$aseqno} = 1;
        $count ++;
    }
} # while <ASN>
close(ASN);
print STDERR "$count records read from $asnfile\n";

my @fields;
while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if ($line =~ m{\A(A\d+)\s+}) {
        my $aseqno = $1;
        if (defined($aseqnos{$aseqno})) {
            @fields = split(/\t/, $line);
            $fields[$kfno] =~ s{\A(\[|)(\-?\d+\,){$scount}}{$1};
            $line = join("\t", @fields);
        } # if defined
    } # if line with aseqno
    print "$line\n";
} # while <>
#--------------------
__DATA__
A058937	holos	1	[0,-1,2,-1,1,-2,1]	[0,1,0,0,0,0,1]	0	7	GeneratingFunctionSequence	gfis			Maximal exponent of x in all terms of Somos polynomial of order n.
A081245	holos	1	[0,1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,1]	[20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,5,20]	0	1	GeneratingFunctionSequence	gfis			Number of days in months in the Haab year of Mayan/mesoamerican calendars.
A089010	holos	1	[0,1,0,0,0,0,0,-1,0,0,0,-1,0,0,0,0,0,1]	[0,1,0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]	0	1	GeneratingFunctionSequence	gfis			a(n) = 1 if n is an exponent of the Weyl group W(E_8), 0 otherwise.
A089011	holos	1	[0,1,0,0,0,-1,0,-1,0,0,0,1]	[0,1,0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0]	0	1	GeneratingFunctionSequence	gfis			a(n) = 1 if n is an exponent of the Weyl group W(E_7), 0 otherwise.
A091337	holos	1	[0,1,0,0,0,1]	[0,1,0,-1,0]	0	1	GeneratingFunctionSequence	gfis			a(n) = (2/n), where (k/n) is the Kronecker symbol.
A135528	holos	1	[0,-1,0,1]	[0,1,1,0,1]	0	1	GeneratingFunctionSequence	gfis			1, then repeat 1,0.
A141212	holos	1	[0,-1,0,0,0,0,0,1]	[0,1,0,1,1,0,0]	0	1	GeneratingFunctionSequence	gfis			a(n) = 1, if n == {1,3,4} mod 6; otherwise 0.
A153881	holos	1	[0,-1,1]	[0,1,-1,-1]	0	1	GeneratingFunctionSequence	gfis			1 followed by -1, -1, -1, ... .
A162289	holos	1	[0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]	[0,1,0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,0,0,1,0]	0	1	GeneratingFunctionSequence	gfis			a(n) = 1 if n is relatively prime to 30 else 0.
A173857	holos	1	[0,-1,0,0,1]	[0,1,0,1,0,0]	0	1	GeneratingFunctionSequence	gfis			Expansion of 3/2 in base phi.
A187074	holos	1	[0,-1,0,0,0,0,0,0,0,0,0,0,0,1]	[0,1,0,0,1,1,0,1,1,0,0,1,0]	0	1	GeneratingFunctionSequence	gfis			a(n) = 0 if and only if n is of the form 3*k or 4*k + 2, otherwise a(n) = 1.
A194644	holos	1	[0,3,-10,6,-1]	[6,12,32,90]	0	1	GeneratingFunctionSequence	gfis			Number of ways to place 2n nonattacking kings on a 4 X 2n cylindrical chessboard.
A194646	holos	1	[0,300,-4235,23320,-66422,111545,-118727,83449,-39539,12676,-2708,369,-29,1]	[34,80,276,1082,4460,18890,81606,358564,1599820,7238864,33175486,153802520,720390254]	0	1	GeneratingFunctionSequence	gfis			Number of ways to place 4n nonattacking kings on an 8 X 2n cylindrical chessboard.
A258869	holos	1	[0,1,0,0,0,0,0,0,-1]	[0,1,1,1,0,0,1,0,1,1,1,0,0,1,0,1,0,1]	0	1	GeneratingFunctionSequence	gfis			Expansion of 1 to the basis 1.880000478655... (A127583).
