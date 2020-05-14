#!perl

# Evaluate g.f.s for uniform tilings
# @(#) $Id$
# 2020-05-12, Georg Fischer
#
#:# usage:
#:#   perl evalgf.pl tilegf.tmp > output
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $debug = 0;
my $nmax = 16;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug = shift(@ARGV);
    } elsif ($opt  =~ m{n}) {
        $nmax = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
      
my $rest;
my $ind;
my $gal_id;
while (<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    my ($aseqno, $callcode, $offset, $numv, $denv, $ogf  , $fract, $galid) = split(/\t/, $line);
    $galid =~ m{Gal\.(\d+)\.(\d+).\d+};
    my $uniform  = $1;
    my $tilingno = $2;
    my $mn = &is_mirrored($numv);
    my $md = &is_mirrored($denv);
    my $comp = "=";
    if (0) {
    } elsif (substr($md, 1) < substr($mn, 1)) {
    	$comp = "<";
    } elsif (substr($md, 1) > substr($mn, 1)) {
    	$comp = ">";
    }
    print join("\t"
      , $aseqno, $callcode, $offset, $numv, $denv, $galid, $uniform, $tilingno, $md, $comp, $mn, $fract) . "\n";
} # while
#-----
sub is_mirrored {
    my ($list) = @_;
    my @elems = split(/\,/, $list);
    my $ielem = 0;
    my $kelem = scalar(@elems) - 1;
    my $diff = 0;
    while ($diff == 0 && $ielem < $kelem) {
        if ($elems[$ielem] != $elems[$kelem]) {
            $diff = 1;
        }
        $ielem ++;
        $kelem --;
    } # while
    return ($diff == 1 ? "a" : "s") . scalar(@elems);
} # is_mirrored

__DATA__
A008486	lingfo	0	1,1,1	1,-2,1	ogf	-(x^2+x+1)/(-x^2+2*x-1)	Gal.1.1.1	0
A008576	lingfo	0	1,2,2,2,1	1,-1,0,-1,1	ogf	-(-x^4-2*x^3-2*x^2-2*x-1)/(x^4-x^3-x+1)	Gal.1.2.1	0
A072154	lingfo	0	1,2,2,2,2,2,1	1,-1,0,0,0,-1,1	ogf	-(x^6+2*x^5+2*x^4+2*x^3+2*x^2+2*x+1)/(-x^6+x^5+x-1)	Gal.1.3.1	0
A250122	lingfo	0	1,1,1,3,-1,5,-3,4,-2	1,-2,3,-4,3,-2,1	ogf	-(2*x^8-4*x^7+3*x^6-5*x^5+x^4-3*x^3-x^2-x-1)/(x^6-2*x^5+3*x^4-4*x^3+3*x^2-2*x+1)	Gal.1.4.1	0
A008574	lingfo	0	1,2,1	1,-2,1	ogf	-(x^2+2*x+1)/(-x^2+2*x-1)	Gal.1.5.1	0
A008574	lingfo	0	1,2,1	1,-2,1	ogf	-(x^2+2*x+1)/(-x^2+2*x-1)	Gal.1.6.1	0
A008579	lingfo	0	1,4,6,6,3,-2	1,0,-2,0,1	ogf	-(-2*x^5+3*x^4+6*x^3+6*x^2+4*x+1)/(-x^4+2*x^2-1)	Gal.1.7.1	0
A008706	lingfo	0	1,3,1	1,-2,1	ogf	-(x^2+3*x+1)/(-x^2+2*x-1)	Gal.1.8.1	0
A219529	lingfo	0	1,4,6,4,1	1,-1,0,-1,1	ogf	-(-x^4-4*x^3-6*x^2-4*x-1)/(x^4-x^3-x+1)	Gal.1.9.1	0
A250120	lingfo	0	1,4,4,6,4,4,1	1,-1,0,0,0,-1,1	ogf	-(x^6+4*x^5+4*x^4+6*x^3+4*x^2+4*x+1)/(-x^6+x^5+x-1)	Gal.1.10.1	0
A008458	lingfo	0	1,4,1	1,-2,1	ogf	-(x^2+4*x+1)/(-x^2+2*x-1)	Gal.1.11.1	0
A265035	lingfo	0	1,0,1,0,0,2,-2,2,-1	1,-3,4,-3,1	ogf	-(x^8-2*x^7+2*x^6-2*x^5-x^2-1)/(x^4-3*x^3+4*x^2-3*x+1)	Gal.2.1.1	0
A265036	lingfo	0	1,0,-2,5,-2,-2,7,-8,6,-2	1,-4,8,-10,8,-4,1	ogf	-(2*x^9-6*x^8+8*x^7-7*x^6+2*x^5+2*x^4-5*x^3+2*x^2-1)/(x^6-4*x^5+8*x^4-10*x^3+8*x^2-4*x+1)	Gal.2.1.2	0
A301287	lingfo	0	1,2,4,2,2,4,1,2,-2	1,-1,1,-2,1,-1,1	ogf	-(-2*x^8+2*x^7+x^6+4*x^5+2*x^4+2*x^3+4*x^2+2*x+1)/(-x^6+x^5-x^4+2*x^3-x^2+x-1)	Gal.2.2.1	0
A301289	lingfo	0	1,2,0,4,3,0,6,-4,6,-2	1,-2,3,-4,4,-4,3,-2,1	ogf	-(-2*x^9+6*x^8-4*x^7+6*x^6+3*x^4+4*x^3+2*x+1)/(-x^8+2*x^7-3*x^6+4*x^5-4*x^4+4*x^3-3*x^2+2*x-1)	Gal.2.2.2	0
