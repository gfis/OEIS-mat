#!perl

# Remove parts of the angle/edge notation 
# @(#) $Id$
# 2020-05-25, Georg Fischer
#
#:# usage:
#:#   perl notae.pl [-a|-e] input > output
#:#       -a  remove angles
#:#       -e  remove edges (default)
#---------------------------------
use strict;
use warnings;
use integer;
my $oper = "-e";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{e|a}) {
        $oper = $opt;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
      
while (<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    if ($line =~  m{\AA\d\d+\t}) { # no comment, not empty
        my ($aseqno, $galid, $stdnot, $vertexid, $tarotlist, $sequence) = split(/\t/, $line);
        my @tarots = map {
                if (0) {
                } elsif ($oper eq "-a") {
                	s{\A(\w)(\d*)([\+\-])(\d*)}{$1$3$4};
                } elsif ($oper eq "-e") {
                	s{\A(\w)(\d*)([\+\-])(\d*)}{$1$2$3};
                }
                $_
            } split(/\,/, $tarotlist);
        $tarotlist = join(",", @tarots);
        print join("\t", ($aseqno, $galid, $stdnot, $vertexid, $tarotlist, $sequence)) . "\n";
    } # no comment, not empty
} # while
__DATA__
A265035	Gal.2.1.1	12.6.4	A180-0,A120-1,B90+0	1,3,6,9,11,14,17,21,25,28,30,32,35,39,43,46,48,50,53,57,61,64,66,68,71,75,79,82,84,86,89,93,97,100,102,104,107,111,115,118,120,122,125,129,133,136,138,140,143,147
A265036	Gal.2.1.2	6.4.3.4	A270+2,A210-2,B120+3,B240+2	1,4,6,7,10,14,20,24,24,23,26,34,42,44,40,37,42,54,64,64,56,51,58,74,86,84,72,65,74,94,108,104,88,79,90,114,130,124,104,93,106,134,152,144,120,107,122,154,174,164
