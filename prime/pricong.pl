#!perl

# Primes of the form a*x^2 + b*x*y + c*y^2
# @(#) $Id$
# 2023-08-16, Georg Fischer
#
#:# Usage:
#:#   grep ... jcat25.txt \
#:#   | perl pricong.pl
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $stripped = "../common/stripped";
my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
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

my $aseqno;
my $callcode = "pricongr";
my $offset1 = 1;
my $name;
my $line;
my %discs = (); # discriminants
my $disc;
my %lines = (); # buffer for preliminary seq4 records
open(ALIST, ">", "alist.tmp") || die "cannot write alist.tmp";
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my $aseqno = substr($line, 0, 7);
    my $name   = substr($line, 8);
    my $nok = 1;
    my $a = 0;
    my $b = 0;
    my $c = 0;
    if (0) {
    #                        1      1 2     2              3      34     4                   5      56     6 
    } elsif ($name =~ m{form ([\+\-])?( *\d+)? *\*? *x\^2 *([\+\-])( *\d+)? *\*? *x *\*? *y *([\+\-])( *\d+)? *\*? *y\^2}) {
        $a = ($1 || "+") . ($2 || 1);
        $b = ($3 || "+") . ($4 || 1);
        $c = ($5 || "+") . ($6 || 1);
        $nok = 0;
    #                        1      1 2     2              3      34     4
    } elsif ($name =~ m{form ([\+\-])?( *\d+)? *\*? *x\^2 *([\+\-])( *\d+)? *\*? *y\^2}) {
        $a = ($1 || "+") . ($2 || 1);
        $b = 0;
        $c = ($3 || "+") . ($4 || 1);
        $nok = 0;
    }
    $a =~ s/ //g;
    $b =~ s/ //g;
    $c =~ s/ //g;
    $disc = $b * $b - 4 * $a * $c;
    if(0) {
    } elsif ($aseqno eq "A141161") {
        # $disc = 148;
    }
    $discs{$aseqno} = $disc; 
    $line = join("\t", $aseqno, $callcode, $offset1, "\$(DISC)", 0, "\$(RESIDUES)", $a, $b, $c, $name) . "\n";
    if ($nok == 0) {
        $lines{$aseqno} = $line;
        print ALIST "$aseqno\n";
        if ($debug >= 1) {
            print "# preliminary: $line";
        }
    } else {
        print STDERR $line;
    }
} # while <>

foreach my $data (split(/\r?\n/, `grep -f alist.tmp $stripped`)) {
    ($aseqno, $name) = split(/ /, $data);
    $name =~ s/^\,//;
    my @terms = split(/\,/, $name);
    # $disc = abs($discs{$aseqno});
    $disc = $discs{$aseqno};
    my %residues = ();
    foreach my $term (@terms) { # build the set of different residues
        $residues{$term % $disc} = 1;
    }
    my $reslist = join(",", sort { $a <=> $b } (keys(%residues)));
    my $datlist = join("\,", splice(@terms, 0, 8));
    if ($debug >= 1) {
        print "# $aseqno: disc=$disc, data=$datlist, residues=$reslist\n";
    }
    $lines{$aseqno} =~ s{\$\(RESIDUES\)}{$reslist};
    $lines{$aseqno} =~ s{\$\(DISC\)}    {$disc};
} # foreach $data

# final output of se4 records
foreach $aseqno (sort(keys(%lines))) {
    print $lines{$aseqno};
}
#--------------------------------------------
__DATA__
A098828 Primes of the form 3x^2 - y^2, where x and y are two consecutive numbers.
A106282 Primes of the form 3x^2+2xy+4y^2 with x and y in Z. - _T. D. Noe_, May 08 2005
A135658 Nonprimes of the form 4x^2-4xy+7y^2.
A141161 Primes of the form 4*x^2+6*x*y-7*y^2.
A141161 Also primes represented by the improperly equivalent form 7*x^2 + 6*x*y - 4*y^2
A141165 Primes of the form 9*x^2+7*x*y-5*y^2.
A141165 Also primes represented by the improperly equivalent form 5*x^2+7*x*y-9*y^2. - _Juan Arias-de-Reyna_, Mar 17 2011
A141167 Primes of the form 8*x^2+x*y-8*y^2.
A141168 Primes of the form 4*x^2+9*x*y-11*y^2.
A141168 Also primes represented by the improperly equivalent form 11*x^2+9*x*y-4*y^2. - _Juan Arias-de-Reyna_, Mar 18 2011
A141180 Primes of the form x^2+6*x*y-y^2 (as well as of the form 6*x^2+8*x*y+y^2).