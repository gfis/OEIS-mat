#!perl

# Convert output of recurrence-guess.gp into CC=holos seq4 records

# @(#) $Id$
# 2026-07-07, Georg Fischer: copied from gp_guess.pl
#
#:# usage:
#:#   perl holguess.pl aseqnos > output.seq4
#:#
#:# read files ../contrib/rh/guess/Annnnn.txt
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $timeout = 8;
my $guess_dir = "../contrib/rh/guess";
my ($aseqno, $bseqno, $order, $signature, $termno, $termlist);
#while(<>) {
while(<DATA>) {
    s/\s+\Z//; # chompr
    if m{\A[A-Z](\d{6})} { # valid A-number
        my $aseqno = "A$1";
        ($termlist, $order, $signature) = ("", "", "");
        if (open(GUE, "<", "$guess_dir/$aseqno.txt")) {
            while (<GUE>) {
                s/\s+\Z//; # chompr
                my $line = $_;
                if ($line =~ m{\A(A\d+)}) {
                    ($bseqno, $termno, $termlist) = split(/\t/, $line);
                    if ($bseqno ne $aseqno) {
                        print STDERR "#** A-numbers do not match: $bseqno <> $aseqno\n";
                    } else {
                        
                    } 
                #                             1   1        2           2
                } elsif ($line =~ m{\A  v\[n\-(\d+)\] *\* *(\[([^\]]+\])}) {
                    ($order, $signature) = ($1, $2);
                    $signature =~ s{\[}{\{[0, };
                    print join("\t", $aseqno, "holos", 0, $signature, $termlist, 0, 0) . "\n";
                }
            } # while <GUE>
            close(GUE);
        } else {
            print STDERR "#** $guess_dir/$aseqno.txt not found\n";
        }
    } # valid A-number
} # while <>
__DATA__
A296683	49	4,43,210,1162,6959,39608,226599,1305725,7497482,43051551,247361324,14209...
Recurrence length=12
 coefficients
  v[n-12]* [2, -20, -19, -49, -92, -7, -79, 21, -15, 37, 4, 4] *v[n-1]  = v[n]
  v[n] =  v[n-1]* [4, 4, 37, -15, 21, -79, -7, -92, -49, -19, -20, 2] *v[n-12]

 characteristic polynomial
  x^12 - 4*x^11 - 4*x^10 - 37*x^9 + 15*x^8 - 21*x^7 + 79*x^6 + 7*x^5 + 92*x^4 + 49*x^3 + 19*x^2 + 20*x - 2
  roots 0.0901712, -0.617558,  0.0265656+I*0.649026,  0.0265656+I*-0.649026,  0.327894+I*0.948771,  0.327894+I*-0.948771,  -0.638306+I*1.14115,  -0.638306+I*-1.14115, 1.46193,  -1.05564+I*2.18380,  -1.05564+I*-2.18380, 5.74443

 generating function
  (4 + 27*x + 22*x^2 + 2*x^3 - 60*x^4 - 85*x^5 - 100*x^6 - 141*x^7 - 68*x^8 - 39*x^9 - 18*x^10 + 2*x^11)/(1 - 4*x - 4*x^2 - 37*x^3 + 15*x^4 - 21*x^5 + 79*x^6 + 7*x^7 + 92*x^8 + 49*x^9 + 19*x^10 + 20*x^11 - 2*x^12)
  same in partial fractions

 as powers
  + gf (4 + 27*x + 22*x^2 + 2*x^3 - 60*x^4 - 85*x^5 - 100*x^6 - 141*x^7 - 68*x^8 - 39*x^9 - 18*x^10 + 2*x^11)/(1 - 4*x - 4*x^2 - 37*x^3 + 15*x^4 - 21*x^5 + 79*x^6 + 7*x^7 + 92*x^8 + 49*x^9 + 19*x^10 + 20*x^11 - 2*x^12)

 OEIS
  %H <a href="/index/Rec#order_12">Index entries for linear recurrences with constant coefficients</a>, signature (4,4,37,-15,21,-79,-7,-92,-49,-19,-20,2).
  %F a(n) = 4*a(n-1) + 4*a(n-2) + 37*a(n-3) - 15*a(n-4) + 21*a(n-5) - 79*a(n-6) - 7*a(n-7) - 92*a(n-8) - 49*a(n-9) - 19*a(n-10) - 20*a(n-11) + 2*a(n-12).

