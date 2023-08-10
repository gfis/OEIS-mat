#!perl

# Read a sorted list of OEIS data and identify the ones with common prefix
# @(#) $Id$
# 2023-08-10, Georg Fischer: copied from gcd_reform.pl
#
#:# usage:
#:#   perl match_data input > output
#---------------------------------
use strict;
use integer;
# get options
my $debug   = 0; # 0 (none), 1 (some), 2 (more)
my $offset  = 0;
my $width   = 16; # very high
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-w}) {
        $width    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------
my $ofter_file = "../../common/joeis_ofter.txt";
my $terms;
my %ofters = ();
open (OFT, "<", $ofter_file) || die "cannot read $ofter_file\n";
while (<OFT>) {
    s{\s+\Z}{};
    my ($aseqno, $offset, $terms) = split(/\t/);
    $terms = $terms || "";
    $ofters{$aseqno} = "$offset\t$terms";
} # while <OFT>
close(OFT);
print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";
#----------------
# a window of 2 lines
my  ($oseqno, $occ, $ooff, $ogcd, $odata) = ("A000000", "8", "0,1,2,3,4,5,6,7");
my  ($nseqno, $ncc, $noff, $ngcd, $ndata); # new record
my  $olen = length($odata);
my  $nlen = 0;
while (<>) {
    next if ! m{\AA\d{6}};
    s/\s+\Z//; # chompr
    ($nseqno, $ncc, $noff, $ngcd, $ndata) = split(/\t/);
    $nlen = length($ndata);
    my $min = 16;
    # print join("\t", $nseqno, substr($ndata, 0, $min)) . "\n";
    if ($nlen >= $width && $olen >= $width) { # sufficient length
        $min = ($nlen < $olen) ? $nlen : $olen;
        if (substr($odata, 0, $min) eq substr($ndata, 0, $min)) { # matches
            if (0) {
                print join("\t", $oseqno, $occ, $nseqno, $ncc
                    , (defined($ofters{$oseqno}) ? "y" : "n") 
                    . (defined($ofters{$nseqno}) ? "y" : "n")
                    , substr($ndata, 0, $min)
                    ) . "\n";
            } else {
                print join("\t", $oseqno, (defined($ofters{$oseqno}) ? "y" : "n") . $occ, $ooff, $ogcd, $odata) . "\n";
                print join("\t", $nseqno, (defined($ofters{$nseqno}) ? "y" : "n") . $ncc, $noff, $ngcd, $ndata) . "\n";
                print "\n";
            }
            # matches
        } else {
        }
    } # sufficient length
    ($oseqno, $occ, $ooff, $ogcd, $odata) = 
    ($nseqno, $ncc, $noff, $ngcd, $ndata); # move window of 2 lines
    $olen = length($odata);
} # while <>
# seqno gcd count data
__DATA__
A286707	100	-1,-1,-1,-1,-1,-1
A321804	200	-1,-1,-1,-1,-1,-1
