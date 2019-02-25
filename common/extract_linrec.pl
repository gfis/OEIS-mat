#!perl

# Extract linear recurrence signatures (and initial terms) from JSON grep
# @(#) $Id$
# 2019-02-25: write also lrindx_spec.txt
# 2019-02-22: tables 'lrindx' and 'lrlink'
# 2019-02-19, Georg Fischer
#
#:# Usage:
#:#   perl extract_linrec.pl -m mode infile > outfile
#:#       -m  index    parse https://oeis.org/w/index.php?title=Index_to_OEIS:_Section_Rec?action=raw
#:#                    and write lrindx.txt, lrindx_spec.txt
#:#           mmacall  parse Mathematica calls: LinearRecurrence[{1, 0, 1, -1}, {2, 3, 5, 10}, 50]
#:#           link     parse links in JSON: "\u003ca href=\"/index/Rec#order_02\"\u003eIndex entries for linear recurrences with constant coefficients\u003c/a\u003e, signature (7,-1)"
#:#                    and write lrlink.txt
#:#           lrindx   write CREATE SQL for table 'lrindx'
#:#           lrlink   write CREATE SQL for table 'lrlink'
#:#---------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug = 0;
my $mode  = "link";
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
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
my $line;
my $aseqno;
my $signature;
my @signatures;
my $initerm = "";
my @initerms;
my $spec    = "";
my $termno  = 0;

} elsif ($mode =~ m{lrindx}) {
    &create_sql("lrindx");
} elsif ($mode =~ m{lrlink}) {
    &create_sql("lrlink");
} elsif ($mode =~ m{index}) {
	open(SPEC, ">", "lrindx_spec.txt") || die "cannot write lrindx_spec.txt\n";
    while (<>) {
        s/\s+\Z//; # chompr
        $line = $_;
        if (0) {
        } elsif ($line =~ m{\>recurrence\,\s+linear\,\s+order\s+(\d*)\:\<}) { # index
			# >recurrence, linear, order 2:<
        	$termno = $1;
        } elsif ($line =~ m{\A\:\s*\(([^\)]+)\)[^\:]*\:(.*)}) { # index
            $signature  = $1;
            my $seqlist = $2;
            my $oldsno = "A000000";
            # print "======> signature=\"$signature\" seqlist=\"$seqlist\"\n";
            while (($seqlist =~ s{(A\d{6})}{}) > 0) {
                $aseqno = $1;
                if ($aseqno le $oldsno) {
                	print STDERR "$aseqno <= $oldsno\n";
                }
                $oldsno = $aseqno;
                &output;
            }
        }
    } # while <>
	close(SPEC);
} else { # extraction modes
    while (<>) {
        s/\s+\Z//; # chompr
        $line = $_;
        if (0) {
        } elsif ($mode =~ m{index}) {
            if (0) {
			# >recurrence, linear, order 2:<
            } elsif ($line =~ m{\>recurrence\,\s+linear\,\s+order\s+(\d*)\:\<}) { # index
            	$termno = $1;
            } elsif ($line =~ m{\A\:\s*\(([^\)]+)\)[^\:]*\:(.*)}) { # index
                $signature  = $1;
                my $seqlist = $2;
                my $oldsno = "A000000";
                # print "======> signature=\"$signature\" seqlist=\"$seqlist\"\n";
                while (($seqlist =~ s{(A\d{6})}{}) > 0) {
                    $aseqno = $1;
                    if ($aseqno le $oldsno) {
                    	print STDERR "$aseqno <= $oldsno\n";
                    }
                    $oldsno = $aseqno;
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
                $termno     = scalar(@signatures);
                $signature  = join(",", @signatures);
                @initerms   = split(/\,/, $initerm  );
                $initerm    = join(",", splice(@initerms, 0, $termno));
                $termno = 0;
                &output;
            }
        } # modes
    } # while <>
    # extraction modes
} # switch $mode
#------------------
sub output {
    $signature =~ s{[^\.\,\-\d]}{}g; # remove letters
    @signatures = split(/\,/, $signature);
    my $lorder  = scalar(@signatures);
    $initerm   =~ s{[^\,\-\d]}{}g; # remove letters 
    @initerms   = split(/\,/, $initerm  );
    my $compsig = join(" ", map { s/ //g; $_ } @signatures); # compressed signature
	#   $compsig =~ s{0 0 0 0 (0 0 ){8,}}{0 0 ... 0 0 }; # destroys the sort order
    print join("\t"
        , $aseqno
        , $mode
        , $spec
        , $lorder 
        , $compsig
        , $termno   
        , join(",", @initerms  )
        ) . "\n";
}
#-----------------
sub create_sql {
    my ($tabname) = @_;
    print <<"GFis";
--  OEIS-mat: $tabname - working table for index of linear recurrences
--  \@(#) \$Id\$
--  $timestamp, generated by extract_linrec.pl - DO NOT EDIT HERE!
--
DROP    TABLE  IF EXISTS $tabname;
CREATE  TABLE            $tabname
    ( aseqno    VARCHAR(10) NOT NULL  -- A322469
    , mode      VARCHAR(8)  NOT NULL  -- index, link, mmacall, xtract
    , spec      VARCHAR(8)    -- for insertions, deletions
    , lorder    INT         NOT NULL  -- order = number of right terms
    , signature VARCHAR(1024) -- comma separated, without "( )"
    , termno    INT                   -- number of initial terms
    , initerms  VARCHAR(1024) -- dito
    , PRIMARY KEY(aseqno, mode, lorder)
    );
COMMIT;
GFis
} # create_sql
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
