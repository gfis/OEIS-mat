#!perl

# Generate linear recurrence programs
# @(#) $Id$
# 2019-03-29, Georg Fischer
#
#:# Usage:
#:#   perl gen_linrec.pl [-d debug] infile > outfile
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


my $line;
my $aseqno;
my $rest;
my $lorder  = 0;
my $signature;
my $initerm = "";
my $termno  = 0;

while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    ($aseqno, $rest) = split(/\t/, $line);
    ($signature, $tiniterm, $termno) = split(/ /, $rest);
    my @signatures = reverse(split(/\,/, $signature));
    my @initerms   = split(/\,/, $initerm  );; 
    &output($aseqno
        , join(", ", reverse(@singatures))
        , join(", ", @initerms)
        );
} # while <>
#--------------------------------------------
sub output {
    my ($aseqno, $signature, $initerm) = @_;
    my packdir = "oeis/$package";
    print `mkdir $packdir`;
    my $filename = "$packdir/$aseqno.java";
    open(OUT, ">", $filename) || die "cannot write \"$filename\"\n";
    print OUT <<"GFis";
package irvine.oeis.$package;

import irvine.oeis.JoinLinearRecurrence;

/**
 * $aseqno.
 * \@author $timestamp Georg Fischer with gen_linrec.pl
 */
public class $aseqno extends LinearRecurrence {

    /** Construct the sequence. */
    public $aseqno() {
        super(new long[] {2, 0, 1}, new long[] {1, 1, 3});
    } // constructor()
} // $aseqno
GFis
    close(OUT);
    print "$aseqno $signature $initerm written\n";
} # output
__DATA__
A020711 2,-1,1,-1 5,7,10,14 50
A020761 1 5,0 99
A020975 30,-293,924 1,30,607 20
A021329 1,0,-1,1 0,0,3,0,7,6 100
A021874 22,-159,418,-280 1,22,325,4070 30
A022025 17,1,-14 6,102,1735 20
A022149 7,-21,35,-35,21,-7,1 1,98,1946,16394,83442,307314,907018,2282394 30
A023105 2,1,-2 1,2,2,3 40
A025875 0,0,0,1,0,0,0,0,0,0,1,1,0,0,-1,-1,0,0,0,0,0,0,-1,0,0,0,1 1,0,0,0,1,0,0,0,1,0,0,1,2,0,0,1,2,0,0,1,2,0,1,2,3,0,1 100
A026474 2,-1 1,2,4,8,15 60
A027013 8,-26,45,-45,26,-8,1 1,8,107,654,2801,9859,30869,89951 30
A028015 29,-296,1204,-1440 1,29,545,8425 30
A028309 2,0,-2,1 1,1,2,3,5,6,9 50
A028344 0,1,2,0,0,-1,-2,-3,0,3,2,1,0,0,-2,-1,0,1 1,1,1,3,4,9,19,27,41,62,91,128,175,231,298,392,498,617 50
A029003 1,1,0,-1,-1,1,0,0,1,-1,-1,0,1,1,-1 1,1,2,3,4,5,7,8,10,13,15,18,22,25,29 70
A029744 0,2 1,2,3 50
A029745 0,2 1,2,8,5 50
A030990 11,-10,-1000,11000,-10000 3,43,143,7143,57143 20
A032121 4,4,-16 1,4,10 31
A032127 3,3,-9 1,4,9,25,63 30
A033190 8,-21,20,-5 0,1,3,9,28 30
A034324 4,-6,4,-1 1,2,3,10 50
A035471 4,-6,4,-1 1,8,48,152,352 40
A