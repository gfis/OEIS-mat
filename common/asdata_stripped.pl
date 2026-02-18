#!perl

# Get the single records or pairs from asdata and stripped with different term lists
# @(#) $Id$
# 2026-02-17, Georg Fischer: copied from bfdata_uniq.pl
#
#:# Usage:
#:#   sort ... \
#:#   | perl asdata_stripped.pl > $@.txt
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt


my  ($oseqno, $osrc, $oterms) = ("", "", "");
my  ($nseqno, $nsrc, $nterms) = ("", "", "");
my  ($aseqno, $asrc, $aterms) = ("", "", "");
my  ($sseqno, $ssrc, $sterms) = ("", "", "");;
while (<>) {
    s/\s+\Z//; # chompr
    ($nseqno, $nsrc, $nterms) = split(/\t/);
    if ($nseqno ne $oseqno) { # group change
        &output();
        $oseqno = $nseqno;
        ($aseqno, $asrc, $aterms) = ($nseqno, "asdata"  , "missing");
        ($sseqno, $ssrc, $sterms) = ($nseqno, "stripped", "missing");
    } # group change
    if ($nsrc eq "asdata") {
        ($aseqno, $asrc, $aterms) = ($nseqno, $nsrc, $nterms);
    } else {
        ($sseqno, $ssrc, $sterms) = ($nseqno, $nsrc, $nterms);
    }
} # while <>
&output();
#----
sub output {
    my $alen = length($aterms);
    my $slen = length($sterms);
    if ($aterms ne $sterms) {
        if (0) {
        } elsif ($alen > $slen) {
            my $partlen = $slen * 7 / 8; # 87.5%
            if (substr($aterms, 0, $slen) eq $sterms) {
                $aterms = &span("refp", "... " . substr($aterms, $partlen));
                $sterms =               "... " . substr($sterms, $partlen);
            }
        } elsif ($alen < $slen) {
            my $partlen = $alen * 7 / 8; # 87.5%
            if (substr($sterms, 0, $alen) eq $aterms) {
                $aterms = &span("refp", "... " . substr($aterms, $partlen));
                $sterms =               "... " . substr($sterms, $partlen);
            }
        } else {
                $aterms = &span("warn", $aterms);
                $sterms = &span("warn", $sterms);
        }
        print join("\t", &span("refp", $aseqno), &span("refp", "DATA    "), &span("refp", $aterms)) . "\n";
        print join("\t", $sseqno, "stripped", $sterms) . "\n";
    }
} # output
sub span { # colorize a field
    my ($class, $text) = @_;
    return "<span class=\"$class\">$text</span>";
} # span
#--------------------
__DATA__
A000000	asdata	2026-02-17T09:48:47z
A000001	asdata  	0,1,1,1,2,1,2,1,5,2,2,1,5,1,2,1,14,1,5,1,5,2,2,1,15,2,2,5,4,1,4,1,51,1,2,1,14,1,2,2,14,1,6,1,4,2,2,1,52,2,5,1,5,1,15,2,13,2,2,1,13,1,2,4,267,1,4,1,5,1,4,1,50,1,2,3,4,1,6,1,52,15,2,1,15,1,2,1,12,1,10,1,4,2
A000001	stripped	0,1,1,1,2,1,2,1,5,2,2,1,5,1,2,1,14,1,5,1,5,2,2,1,15,2,2,5,4,1,4,1,51,1,2,1,14,1,2,2,14,1,6,1,4,2,2,1,52,2,5,1,5,1,15,2,13,2,2,1,13,1,2,4,267,1,4,1,5,1,4,1,50,1,2,3,4,1,6,1,52,15,2,1,15,1,2,1,12,1,10,1,4,2
A000002	asdata  	1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,2,1,2,1,1,2,1,2,2,1,1,2,1,1,2,1,2,2,1,2,2,1,1,2,1,2,2,1,2,1,1,2,1,1,2,2,1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,1,2,2,1,2,1,1,2,2,1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,2,1,2,1,1,2,1,2,2
A000002	stripped	1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,2,1,2,1,1,2,1,2,2,1,1,2,1,1,2,1,2,2,1,2,2,1,1,2,1,2,2,1,2,1,1,2,1,1,2,2,1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,1,2,2,1,2,1,1,2,2,1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,2,1,2,1,1,2,1,2,2
A000003	asdata  	1,1,1,1,2,2,1,2,2,2,3,2,2,4,2,2,4,2,3,4,4,2,3,4,2,6,3,2,6,4,3,4,4,4,6,4,2,6,4,4,8,4,3,6,4,4,5,4,4,6,6,4,6,6,4,8,4,2,9,4,6,8,4,4,8,8,3,8,8,4,7,4,4,10,6,6,8,4,5,8,6,4,9,8,4,10,6,4,12,8,6,6,4,8,8,8,4,8,6,4
A000003	stripped	1,1,1,1,2,2,1,2,2,2,3,2,2,4,2,2,4,2,3,4,4,2,3,4,2,6,3,2,6,4,3,4,4,4,6,4,2,6,4,4,8,4,3,6,4,4,5,4,4,6,6,4,6,6,4,8,4,2,9,4,6,8,4,4,8,8,3,8,8,4,7,4,4,10,6,6,8,4,5,8,6,4,9,8,4,10,6,4,12,8,6,6,4,8,8,8,4,8,6,4
