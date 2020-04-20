#!perl

# Extract parameters from Galebach's website
# https://oeis.org/A250120/a250120.html
# @(#) $Id$
# 2020-04-17, Georg Fischer
#
#:# usage:
#:#   perl extract_gb.pl galabach.html > output
#---------------------------------
use strict;
# do not "use integer;" !

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
      
my @angles = ();
while (<DATA>) {
	s{\s+\Z}{}; # chompr
    if (m{\Aangle\;(.*)}) {
        push(@angles, $1);
    }
} # while DATA

my (@xpos, @ypos);
my $ipos = 0;
foreach my $angle(sort(@angles)) {
    my ($degr, $xlist, $ylist) = split(/\;/, $angle);
	push(@xpos, &cartesian($xlist));
	push(@ypos, &cartesian($ylist));
    print join("\t", ($degr + 0) . ":", sprintf("%f10\t%f10", $xpos[$ipos], $ypos[$ipos])). "\n"; 
    $ipos ++;
} # foreach

sub cartesian {
    my ($list) = @_;
    my (@elems) = split(/\,/, $list);
    return ($elems[0] + sqrt(2)*$elems[1] + sqrt(3)*$elems[2] + sqrt(6)*$elems[3]) / 4;
} # cartesian
__DATA__<br />
# Exact trigonometric formulae in the unit circle for the corners of a 
# with coordinates (x,y) as (a+b*sqrt(2)+c*sqrt(3)+d*sqrt(6)/4 by tuples (a,b,c,d):
angle;000;4,0,0,0;0,0,0,0
angle;090;0,0,0,0;4,0,0,0
angle;180;-4,0,0,0;0,0,0,0
angle;270;0,0,0,0;-4,0,0,0

angle;045;0,2,0,0;0,2,0,0
angle;135;0,-2,0,0;0,2,0,0
angle;225;0,-2,0,0;0,-2,0,0
angle;315;0,2,0,0;0,-2,0,0

angle;030;0,0,2,0;2,0,0,0
angle;150;0,0,-2,0;2,0,0,0
angle;210;0,0,-2,0;-2,0,0,0
angle;330;0,0,2,0;-2,0,0,0

angle;060;2,0,0,0;0,0,2,0
angle;120;-2,0,0,0;0,0,2,0
angle;240;-2,0,0,0;0,0,-2,0
angle;300;2,0,0,0;0,0,-2,0

angle;015;0,1,0,1;0,-1,0,1
angle;165;0,-1,0,-1;0,-1,0,1
angle;195;0,-1,0,-1;0,1,0,-1
angle;345;0,1,0,1;0,1,0,-1

angle;075;0,-1,0,1;0,1,0,1
angle;105;0,1,0,-1;0,1,0,1
angle;255;0,1,0,-1;0,-1,0,-1
angle;285;0,-1,0,1;0,-1,0,-1

# Tilings by Regular Polygons. Branko Grünbaum and Geoffrey C. Shephard.
# Mathematics Magazine, Vol. 50, No. 5 (Nov., 1977), pp. 227-247 (21 pages)
# DOI: 10.2307/2689529
# https://www.jstor.org/stable/2689529
# Possible vertex types for tiling with regular polygones with unit side length:
vertex_type;1.1;3.3.3.3.3.3;arch;6
vertex_type;2.1;3.3.3.3.6;arch;5
vertex_type;3.1;3.3.3.4.4;arch;5
vertex_type;3.2;3.3.4.3.4;arch;5
vertex_type;4.1;3.3.4.12;uni;4
vertex_type;4.2;3.4.3.12;uni;4
vertex_type;5.1;3.3.6.6;uni;4
vertex_type;5.2;3.6.3.6;arch;4
vertex_type;6.1;3.4.4.6;uni;4
vertex_type;6.2;3.4.6.4;arch;4
vertex_type;7.1;3.7.42;invalid
vertex_type;8.1;3.8.24;invalid
vertex_type;9.1;3.9.18;invalid
vertex_type;10.1;3.10.15;invalid
vertex_type;11.1;3.12.12;arch;3
vertex_type;12.1;4.4.4.4;arch;4
vertex_type;13.1;4.5.20;invalid
vertex_type;14.1;4.6.12;arch;3
vertex_type;15.1;4.8.8;arch;3
vertex_type;16.1;5.5.10;invalid
vertex_type;17.1;6.6.6;arch;3
# 21 total, 11 arch, 4 uni, 6 invalid
#---------------------
# Experiment: Gal.2.1, 6.4.3.4, 12.4.6/12.6.4

v1:	12.6.4 
	3
	succ: v2,6;  v3,4; v4,12
	pred: v2,12; v3,6; v4,4
v2: 12.6.4
	3
	succ: v1,12; v5,6; v6,4
	pred: v1,6;  v5,4; v6,12
v3:
	1
	succ: v1,6
	pred: v1,4
v4:	12.4.6
	1
	succ: v1,4
	pred: v1,12
	
#--------------
v1 -12} v2 -12} v3 >12> v4 >12> v5 >12> v6 >12> v7 >12> v8 >12> v9 >12> v10 >12> v11 >12> v12 >12> v1
        v2 >6> v1 >6> v13 >6> v14 >6> v15 >6> v16 >6> v2
               v1 >4> v11 >4> v17