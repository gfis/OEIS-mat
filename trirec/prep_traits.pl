#!perl

# Prepare traits for HTML page
# @(#) $Id$
# 2020-03-28: changes for Peter; Wolfgang = 73
# 2020-03-23, Georg Fischer
#
#:# Usage:
#:#   perl prep_traits.pl traits4.tmp > traits5.tmp
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

print join("\t", "Trait", "A", "Key.", "Seq.", "Key", "SeqName", "Author, Year", "Data"). "\n";
my $oseqno = "A000000"; # old aseqno
while (<>) {
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    if ($line =~ m{\A(A\d+)}) {
    	# relates to a following line in trimore.pl 
        my ($aseqno, $trait, $tseqno, $tname, $termlist
            , $tkeyw, $author, $akeyw) = split(/\t/, $line);
        if ($aseqno eq $oseqno) {
        	$aseqno = "";
        } else {
        	$oseqno = $aseqno;
        }
        $akeyw   = &keyword($akeyw);
        $tkeyw   = &keyword($tkeyw);
        $author  = $author || "";
        $tname   = $tname  || "";
        $author =~ s{[A-Z]\. }{}g;
        $author =~ s{ [A-Z][a-z][a-z] \d\d }{ };
        $author =~ s{\A\_(\w+\s+)?(\w+)\_}{$2};
        $author = substr($author, 0, 16);
        $termlist = substr($termlist, 0,16);
        $termlist =~ s{\,}{\, }g;
        print join("\t"
            , $trait
            , $aseqno
            , $akeyw
            , $tseqno
            , $tkeyw
            , $tname
            , $author
            , $termlist
            ) . "\n";
    } else {
        # ignore
    }
} # while <>

sub keyword {
    my ($keyw) = @_;
    $keyw = $keyw   || "";
    $keyw =~ s{nonn|easy|sign|changed|tabl|full|synth}{}g;
    $keyw =~ s{\,+}{\,}g;
    $keyw =~ s{\A\,+}{};     
    $keyw =~ s{\,+\Z}{};     
    return $keyw;
} # keyw    
#--------------------------------------------
__DATA__
Trait   A       Key.    Seq.    Key     SeqName Author, Year    Data
EvenSum A000012 core,mult,cofr,cons     A008619 nice    Positive integers repeat        Sloane  1, 1, 2, 2, 3, 3, 4, 4,
OddSum  A000012 core,mult,cofr,cons     A110654         a(n) = ceiling(n/2), or:        Zumkeller, 2005 0, 1, 1, 2, 2, 3, 3, 4,
AltSum  A000012 core,mult,cofr,cons     A331218 base,new        a(n) is the numbers of w        _R√©my Sigris   1, 0, 1, 0, 1, 0, 1, 0,
DiagSum A000012 core,mult,cofr,cons     A008619 nice    Positive integers repeat        Sloane  1, 1, 2, 2, 3, 3, 4, 4,
NegHalf A000012 core,mult,cofr,cons     A077925         Expansion of 1/((1-x)*(1        Sloane, 2002    1, -1, 3, -5, 11, -21
N0TS    A000012 core,mult,cofr,cons     A105339         a(n) = n*(n+1)/2 mod 102        Takeshita, 2005 0, 1, 3, 6, 10, 15, 21
Central A001404         A181984         INVERT transform of A028        Somos, 2012     1, 2, 5, 12, 28, 65
LeftSide        A001404         A167750         Row sums of triangle A16        Barry, 2009     1, 1, 2, 4, 9, 20, 45,
RowSum  A001477 core,mult       A027480 nice    a(n) = n*(n+1)*(n+2)/2. _Olivier G√©r   0, 3, 12, 30, 60, 105
