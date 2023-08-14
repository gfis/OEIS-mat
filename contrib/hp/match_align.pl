#!perl

# Join tuples of lines with matching data into one record
# @(#) $Id$
# 2023-08-10, Georg Fischer: copied from match_data.pl
#
#:# usage:
#:#   perl match_align.pl [-w width] {-ny|-yy|-yn|-nn}... input.seq4 > output.seq4
#
# $o... = target, $n... = source
#---------------------------------
use strict;
use integer;
# get options
my $debug   = 0; # 0 (none), 1 (some), 2 (more)
my $offset  = 0;
my $width   = 64;
my %hash = qw(ny 1 yn 1);
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-([ny]{2})}) {
        $hash{$1} = 1;
    } elsif ($opt =~ m{\-w}) {
        $width    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------
$/ = "\n\n"; # separator for blocks of 2 lines to be joined
my  ($oseqno, $occ, $ooff, $ogcd, $odata);
my  ($nseqno, $ncc, $noff, $ngcd, $ndata); # new record
while (<>) {
    next if ! m{\AA\d{6}};
    my $block = $_;
    my $nyi = join("", ($block =~ m{\t([ny])\w+\t}g));
    my @lines = split(/\n/, $block);
    if (defined($hash{$nyi})) {
        ($oseqno, $occ, $ooff, $ogcd, $odata) = split(/\t/, $lines[($nyi =~ m{\An}) ? 0 : 1]);
        ($nseqno, $ncc, $noff, $ngcd, $ndata) = split(/\t/, $lines[($nyi =~ m{\An}) ? 1 : 0]);
        print join("\t", ($oseqno, $occ, $ooff, $ogcd                           )) . "\t";  # aseqno already implemented 
        #                                       parm1
        print join("\t", ($nseqno, $ncc, $noff, $ngcd, substr($ndata, 0, $width))) . "\n";  # parm2  not yet implemented 
        #                 parm2    parm3 parm4  parm5  parm6
    }
} # while <>
# seqno gcd count data
__DATA__
A114044	yorig	0	1	1,1,1,1,1,2,3,4,5,6,9,13,18,24,31,42,58,80,109,146,197,268,366,499,676,916,1243,1690,2299,3122,4237,5751,7811,10614,14418,19580,26587,36106,49043,66614,90473,122869,166866,226632,307810,418060,567784,771122,1047296,1422396
A351724	yorig	0	1	1,1,1,1,1,2,3,4,5,6,9,13,18,24,31,42,58,80,109,146,197,268,366,499,676,916,1243,1690,2299,3122,4237,5751,7811,10614,14418,19580,26587,36106,49043,66614,90473,122869,166866,226632,307810,418060,567784,771122,1047296,1422396,1931845

A152659	ngcd0	-22	2	1,1,1,1,1,2,4,2,1,1,3,9,9,9,3,1,1,4,16,24,36,24,16,4,1,1,5,25,50,100,100,100,50,25,5,1,1,6,36,90,225,300,400,300,225,90,36,6,1,1,7,49,147,441,735,1225,1225,1225,735,441,147,49,7,1,1,8,64,224
A247644	yorig	1	1	1,1,1,1,1,2,4,2,1,1,3,9,9,9,3,1,1,4,16,24,36,24,16,4,1,1,5,25,50,100,100,100,50,25,5,1,1,6,36,90,225,300,400,300,225,90,36,6,1,1,7,49,147,441,735,1225,1225,1225,735,441,147,49,7,1,1,8,64,224,784,1568,3136,3920,4900,3920,3136,1568,784,224,64,8,1

A263858	norig	0	1	1,1,1,1,1,3,1,1,7,6,2,1,13,25,18,4,2
A263862	norig	0	1	1,1,1,1,1,3,1,1,7,6,2,1,13,25,18,4,2,1,22,80,111,60,32,7,4,1
