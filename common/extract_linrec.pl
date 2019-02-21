#!perl

# Extract linear recurrence signatures from JSON grep
# @(#) $Id$
# 2019-02-19, Georg Fischer
#
# Usage:
#   perl extract_signature.pl -m mode infile > outfile
#       -m  index, mmacall, link
#---------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug = 0;
my $mode  = "link";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @parts;
my $aseqno;
my $signature;
my @signatures;
my $initerm = "";
my @initerms;
my $line;
my $termno = 0;
while (<>) {
    s/\s+\Z//; # chompr
    $line = $_;
    if (0) {
    } elsif ($mode =~ m{index}) {
        if ($line =~ m{\A\:\s*\(([^\)]+)\)[^\:]*\:(.*)}) { # index
            $signature  = $1;
            my $seqlist = $2;
            # print "======> signature=\"$signature\" seqlist=\"$seqlist\"\n";
            while (($seqlist =~ s{(A\d{6})}{}) > 0) {
                $aseqno = $1;
                &output;
            }
        }
    } elsif ($mode =~ m{link|mmacall}) {
        if ($line =~ m{(A\d{6})\.json\:}) { # link, mmacall
            $aseqno   = $1;
            $initerm  = "";
            $termno   = 0;
            if (0) {
            } elsif ($mode eq "link") {
                if ($line =~ m{signature\s*\(([^\)]+)}i) {
                    $signature = $1;
                    &output;
                }
            } elsif ($mode eq "mmacall") {
                if ($line =~ m{LinearRecurrence\s*\[\s*\{([^\}]+)\}\s*\,\s*\{([^\}]+)\}\s*\,\s*(\d+)\s*\]}i) {
                    $signature = $1;
                    $initerm   = $2;
                    $termno    = $3;
                    &output;
                }
            }
        } # Annnnnn.json
    } elsif ($mode =~ m{xtract}) {
        if ($line =~ m{\A(A\d{6})\t([^\t]+)\t([^\t]+)}) { # xtract
            # A000096   a(n) = +3 * a(n-1) -3 * a(n-2) +1 * a(n-3)  0,2,5,9,14,20,27,35,44,54,65,77,90,104,119,135,152,170,189,209,230,252,275,299
            $aseqno     = $1;
            $signature  = $2;
            $initerm    = $3;
            @signatures = map {
                    s{\+}{};
                    $_
                } grep {
                    m{[\+\-]\d+}
                } split(/\s+/, $signature);
            $termno = scalar(@signatures);
            $signature  = join(",", @signatures);
            @initerms   = split(/\,/, $initerm  );
            $initerm    = join(",", splice(@initerms, 0, $termno));
            $termno = 0;
            &output;
        }
    } # modes
} # while <>
#----
sub output {
    $signature =~ s{[^\,\-\d]}{}g;
    @signatures = split(/\,/, $signature);
    $initerm   =~ s{[^\,\-\d]}{}g;
    @initerms   = split(/\,/, $initerm  );
    print "$aseqno\t$mode\t"
        . scalar(@signatures) . "\t" . join(",", @signatures) 
        . "\t"
        . scalar(@initerms  ) . "\t" . join(",", @initerms  )
        . "\t$termno\n";
}
#--------------------
__DATA__
link
ajson/A033889.json:             "\u003ca href=\"/index/Rec#order_02\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (7,-1)"
ajson/A002530.json:             "\u003ca href=\"/index/Rec#order_04\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (0,4,0,-1).",
ajson/A042407.json:             "\u003ca href=\"/index/Rec\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (0,1460,0,-1)."
ajson/A076736.json:             "\u003ca href=\"/index/Rec#order_02\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (0,2)."
ajson/A037141.json:             "\u003ca href=\"/index/Rec#order_04\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (3,-2,-1,1)."
ajson/A094567.json:             "\u003ca href=\"/index/Rec#order_03\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (6,6,-1)."
ajson/A020979.json:             "\u003ca href=\"/index/Rec#order_03\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (29,-278,880)."
ajson/A013898.json:             "\u003ca href=\"/index/Rec#order_01\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (4084101)."
ajson/A071953.json:             "\u003ca href=\"/index/Rec#order_07\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (7, -21, 35, -35, 21, -7, 1)."

mmcall
ajson/A047604.json:                             "LinearRecurrence[{1, 0, 1, -1}, {2, 3, 5, 10}, 50] (* _G. C. Greubel_,"
ajson/A081138.json:                             "LinearRecurrence[{24,-192,512},{0,0,1},30] (* _Harvey P. Dale_, Jun 08"
ajson/A029898.json:                             "Join[{1},LinearRecurrence[{1,0,-1,1},{1,2,4,8},110]] (* or *) Join[{1},"

index
====<span id="order 02">recurrence, linear, order 2:</span>====
:(-24,-2048): A035174
:(-14,-1): A122572
:(-1,-2): A001607, A078050, A110512, A169998, A279675
:(-1,-1), i.e., 3-periodic: A049347, A057078, A061347, A099837, A099838, A102283, A106510, A122434, A131713, A132677, A163804, A167373
:(-1,1): A039834, A061084, A075193

xtract
A000044 a(n) = +1 * a(n-1) +1 * a(n-3) +1 * a(n-5) +1 * a(n-7) +1 * a(n-9) +1 * a(n-11) 1,1,1,2,3,5,8,13,21,34,55,89,144,232,375,606,979,1582,2556,4130,6673,10782,17421,28148
A000045 a(n) = +1 * a(n-1) +1 * a(n-2)  0,1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181,6765,10946,17711,28657
A000051 a(n) = +3 * a(n-1) -2 * a(n-2)  2,3,5,9,17,33,65,129,257,513,1025,2049,4097,8193,16385,32769,65537,131073,262145,524289,1048577,2097153,4194305,8388609
A000062 a(n) = +1 * a(n-1) +1 * a(n-5) -1 * a(n-6)  1,2,4,5,6,8,9,11,12,13,15,16,18,19,20,22,23,25,26,27,29,30,32,33
A000096 a(n) = +3 * a(n-1) -3 * a(n-2) +1 * a(n-3)  0,2,5,9,14,20,27,35,44,54,65,77,90,104,119,135,152,170,189,209,230,252,275,299
