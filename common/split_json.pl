#!perl

# Read a bulk JSON response and split it into individual sequence JSONs
# @(#) $Id$
# 2019-01-23, Georg Fischer: copied from extrac_info.pl
#
# usage:
#   perl split_json.pl [-d targetdir] [inputfile]
#       -o         target directory, default ./temp
#       -d level   0 = none, 1 = some, 2 = more
#       infile     default ./bulk_json.tmp
#---------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf("%04d-%02d-%02dT%02d:%02d:%02dz"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $targetdir  = "./temp";
my $infile     = "bulk_json.tmp";
my $debug      = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt =~ m{\-o}) {
        $targetdir = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
if (scalar(@ARGV) >= 1) {
    $infile = shift(@ARGV);
}
my $header = "";
my %requested = (); # keep track of the ones we want to fetch
my $trailer = <<"GFis"; # print tail of 1 JSON
        }
    ]
}
GFis
my $buffer = "";
my $seqno;
my $aseqno;
my $id;
my $state  = 0;
my $iline  = 0;
my $outfile;
my $line;
my $placeholder = "##";
open(INF, "<", $infile) || die "cannot read \"$infile\"\n";
while (<INF>) {
    $line = $_;
    if ($debug >= 2) {
        print STDERR "$state $iline: $line";
    }
    if (0) {
    } elsif ($state == 0) {
        if (0) {
        } elsif ($line =~ m{\A\s*\"query\"\:\s*\"([^\"]*)\"}) {
            #   "query": "id:A282971|id:A282972",
            my $list =                           $1;
            map {
                ($id, $aseqno) = split(/\:/);
                $requested{$aseqno} = 1;
                $_
                } split(/\|/, $list);
            $line = "\t\"query\": \"id:$placeholder\",\n"; # 
            $header .= $line; 
            if ($debug > 0) {
                print STDERR "requested " . join("|", sort(keys(%requested))) . "\n";
            }
        } elsif ($line =~ m{\A\s*\"results\"\:\s*\[}) {
            $state  = 1;
            $buffer = "";
            $iline  = 0;
            $header .= $line;
        } else {
            $header .= $line;
        }
    } elsif ($state == 1) {
        $iline ++;
        if (0) {
        } elsif ($line =~ m{\A\s*\"number\"\:\s*(\d+)}) {
            $seqno = $1;
            $buffer .= $line;
            if ($debug > 0) {
                print STDERR "number; $seqno\n";
            }
        } elsif ($line =~ m[\A\s*\}]  ) { # end of some sequence
            if (($line =~  s[\A\s*\}\,][\t\t\}]) == 0) { # end of last sequence
                $state = 2;
            }
            $buffer .= $line;
            $aseqno = sprintf("A%06d", $seqno);
            if ($debug > 0) {
                print STDERR "separator behind \"$aseqno\", write \"$targetdir/$aseqno.json\"\n";
            }
            &print_seq("$targetdir/$aseqno.json");
            $buffer = "";
        } else {
            $buffer .= $line;
        }
    } elsif ($state == 2) { # ignore last closing lines
    } else {
        die "invalid state $state\n";
    }
} # while <INF>
close(INF);

# print those which were not found
$header  =~ s{\n\s*\"results\"\:\s*\[}
             {\n\t\"results\"\: null};
$buffer  = "";
$trailer = "}\n";
$iline   = 0;               
foreach $aseqno(sort(keys(%requested))) { # write the non-existing
	if ($requested{$aseqno} == 1) { # was not yet printed
	    &print_seq("$targetdir/$aseqno.json");
	}
} # foreach non-exsisting
#----------
sub print_seq { # global: $header, $buffer, $trailer, $iline
    my ($outfile, $count) = @_;
    open(OUT, ">", $outfile) || die "cannot write \"$outfile\"\n";
    $header =~ s{\"id\:$placeholder}{\"id\:$aseqno};
    print OUT "$header$buffer$trailer";
    $header =~ s{\"id\:$aseqno}{\"id\:$placeholder};
    close(OUT);
    print STDERR "$outfile $iline lines\n";
    $buffer = "";
    $iline = 0;
    $requested{$aseqno} = 0; # process non-existing ones them below
} # print_seq
__DATA__
#------------------------------------
{
    "greeting": "Greetings from The On-Line Encyclopedia of Integer Sequences! http://oeis.org/",
    "query": "id:A064694|id:A064696|id:A064698|id:A064699|id:A064700|id:A064701|id:A064702|id:A064707|id:A064710|id:A064711|id:A064713|id:A064715|id:A064716|id:A064719|id:A064721|id:A064724",
    "count": 16,
    "start": 0,
    "results": [
        {
            "number": 64699,
            "data": "1,3,7,17,19,31,47,383,2897,3061,4847,5359,10223",
            "name": "Integers for which the smallest m in A040076 such that n*2^m+1 is prime (A050921) increases.",
            "comment": [
                "Where records occur in A040076. A103964 gives the record values."
            ],
            "mathematica": [
                "a = -1; Do[m = 0; While[ !PrimeQ[n*2^m + 1], m++ ]; If[m \u003e a, a = m; Print[n]], {n, 1, 10^3} ]"
            ],
            "xref": [
                "Cf. A040076, A050921."
            ],
            "keyword": "more,nonn",
            "offset": "1,2",
            "author": "_Robert G. Wilson v_, Oct 16 2001",
            "ext": [
                "Corrected and extended by _T. D. Noe_, Nov 15 2010",
                "a(13) was found by PrimeGrid, added by _Arkadiusz Wesolowski_, Feb 13 2017"
            ],
            "references": 6,
            "revision": 9,
            "time": "2017-02-13T13:34:13-05:00",
            "created": "2003-05-16T03:00:00-04:00"
        },
        {
            "number": 64707,
            "data": "0,1,2,3,5,4,7,6,10,11,8,9,15,14,13,12,21,20,23,22,16,17,18,19,31,30,29,28,26,27,24,25,42,43,40,41,47,46,45,44,32,33,34,35,37,36,39,38,63,62,61,60,58,59,56,57,53,52,55,54,48,49,50,51,85,84,87,86,80,81,82,83",
            "name": "Inverse square of permutation defined by A003188.",
            "comment": [
                "Not the same as A100281: a(n)=A100281(n)=A099896(A099896(n)) only for n\u003c64. - _Reinhard Zumkeller_, Nov 11 2004"
            ],
            "link": [
                "Ivan Neretin, \u003ca href=\"/A064707/b064707.txt\"\u003eTable of n, a(n) for n = 0..8191\u003c/a\u003e",
                "\u003ca href=\"/index/Per#IntegerPermutation\"\u003eIndex entries for sequences that are permutations of the natural numbers\u003c/a\u003e"
            ],
            "formula": [
                "a(n) = A180200(A233279(n)), n \u003e 0. - _Yosu Yurramendi_, Apr 05 2017"
            ],
            "program": [
                "(MATLAB) A = 1; for i = 1:7 B = A(end:-1:1); A = [A (B + length(A))]; end C = A(A); for i = 1:128 A(C(i)) = i - 1; end A"
            ],
            "xref": [
                "Inverse of permutation defined by A064706. Cf. A003188."
            ],
            "keyword": "nonn,look,easy",
            "offset": "0,3",
            "author": "_N. J. A. Sloane_, Oct 13 2001",
            "ext": [
                "More terms from _David Wasserman_, Aug 02 2002"
            ],
            "references": 6,
            "revision": 19,
            "time": "2017-09-06T21:20:10-04:00",
            "created": "2003-05-16T03:00:00-04:00"
        },
        {
            "number": 64711,

...


            "revision": 9,
            "time": "2017-02-26T11:53:16-05:00",
            "created": "2017-02-26T11:53:16-05:00"
        }
    ]
}