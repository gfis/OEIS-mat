#!perl

# Extract linear recurrence signatures from jcat25 grep
# @(#) $Id$
# 2026-02-03: Georg Fischer, copied from signat_extract.pl
#
#:# Usage:
#:#   perl signat_eval.pl [-d debug] [-m max_binom] input > output
#:#      -d mode 0=none, 1=some, 2=more
#:#      -m number of rows in Pascal's triangle (default 64)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug = 0;
my $max_binom   = 64;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{c}) {
        &create_sql();
        exit(0);
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $max_binom = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my @binarr; # array of binomial coefficients: (1), (1,1), (1,2,1) ...
&fill_binarr();
#----
my ($line, $aseqno, $type25, $sigord, $longord, $wordord, $signature, $keyword);
my $nok = "";
my @elems; # terms in the signature

while (<>) {
    s/\s+\Z//; # chompr
    $line = $_;
    $nok     = "";
    ($aseqno, $type25, $sigord, $longord, $signature, $keyword) = split(/\t/, $line);
    if ($signature !~ m{\?}) { # valid signature
        @elems = split(/\,/, $signature);
        if (0) {
        } elsif ($sigord == 1) {
            if ($signature eq "1") {
                $keyword .= ",constant"
            } else {
                $keyword .= ",pow=$signature";
            }
        #                          12   2 1
        } elsif ($signature =~ m{\A((0\,)+)1\Z}) {
            my $zeros = $1;
            my $perlen = length($zeros)/2 + 1;
            $keyword .= ",period=$perlen";
        } else {
            if ($signature =~ m{\A(\-?\d+)}) {
                my $first = $1;
                if ($first >= 2 && $first < $max_binom) {
                    my $posign = $signature;
                    $posign =~ s{\-}{}g;
                    if ("1," . $posign eq $binarr[$first]) {
                        $keyword .= ",binom=$first";
                    }
                }
            }
        }
    }
  &output();
} # while <>
# end main
#----------
sub output {
    $keyword =~ s{^\,}{}; # remove leading comma
    if ($nok eq "") {
        print join("\t"
            , $aseqno
            , $type25
            , $sigord
            , $longord
            , $signature
            , $keyword
#           , $line
            ) . "\n";
    } else {
        print STDERR "$line -> $nok\n";
    }
} # output 
#----
sub fill_binarr {
    push(@binarr, "1");
    print "[0]\t1\n" if $debug >= 1;
    for (my $irow = 1; $irow < $max_binom; $irow ++) {
        my @orow = split(/\,/, $binarr[$irow - 1]);
        push(@orow, 0);
        # print "\t\t" . join(";", @orow) . "\n";
        my $nrow = "1";
        for (my $icol = 1; $icol < scalar(@orow); $icol ++) {
            $nrow .= "," . ($orow[$icol - 1] + $orow[$icol]); # Pascal's rule
        } # for $icol
        print "[$irow]\t$nrow\n" if $debug >= 1;
        push(@binarr, $nrow);
    } # for $irow  
} # fill_binarr
#-------------------------------------------------
__DATA__
A392075	#	26	26	0,0,16,0,0,-112,0,0,448,0,0,-1120,96,0,1792,-768,0,-1792,2304,0,1024,-3072,0,-256,1536,-2304		;
A392076	#	10	10	8,-28,56,-70,58,-36,20,-9,2,-1		;
A392083	#	3	3	5,-8,4		;
A392084	#	3	3	7,-15,9		;
A392137	#	3	3	11,-35,25		;
A392138	#	3	3	15,-63,49		;
A392141	#	-1	167227	?sig4	nosig	;
A392142	#	10	10	0,0,0,0,0,0,0,0,0,1		;
