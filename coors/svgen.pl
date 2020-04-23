#!perl

# Generate SVG for tilings
# @(#) $Id$
# 2020-04-22, Georg Fischer
#
#:# usage:
#:#   perl svgen.pl lines.data > output.svg
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
my $w1 = 16;
my $w2 = $w1 * 2;
print <<"GFis";
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN"
 "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd" [
 <!ATTLIST svg xmlns:xlink CDATA #FIXED "http://www.w3.org/1999/xlink">
]>
<!--
    2020-04-22, Georg Fischer: test of tiling generation
-->
<svg width="192mm" height="192mm"
    viewBox="-$w1 -$w1 $w2 $w2" 
    xmlns="http://www.w3.org/2000/svg" 
    >
    <defs>
        <style type="text/css"><![CDATA[
            rect, line {
                stroke: black; 
                fill:none; 
                stroke-width:0.1
            }
        ]]></style>
    </defs>
<title>Tiling</title>
<g id="graph0" >
    <rect x="-$w1" y="-$w1" width="$w2" height="$w2" />
GFis
while (<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    last if $line =~ m{vertex type 2};
    if ($line =~ m{\A\/\* line:\s*(\S*)}) {
        my $rest = $1;
        my (@cos) = split(/\,/, $rest);
        print "<line x1=\"$cos[0]\" y1=\"$cos[1]\"  x2=\"$cos[2]\" y2=\"$cos[3]\" />\n";
        # e.g. <line x1="0" y1="0"  x2="8" y2="-8"  />
    } 
} # while <>
print <<'GFis';
</g>
</svg>
GFis
__DATA__