#!perl

# Remove XMl from the output of pdftohtml -xml
# @(#) $Id$
# 2019-11-05, Georg Fischer
#
#:# Usage:
#:#   perl dexml.pl infile > outfile
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
my $line = "";
while (<>) {
	s{\s+\Z}{}; # chompr
    s{\<(text|page|pdf2xml)[^\>]*\>}{};
    s{\<\/(text|page|pdf2xml)[^\>]*\>}{};
    my $text = $_;
    if ($text =~ m{\AA\d\d\d+}) {
    	&out();
    }
    $line .= " $text";
} # while <>
&out();

sub out {
	print substr($line, 1) . "\n";
	$line = "";
} # sub out
#--------------------
__DATA__
<text top="321" left="13" width="342" height="12" font="0">(-8*x^6-4*x^5+8*x^4+4*x^2+x-1) lgdogf]</text>
<text top="337" left="13" width="576" height="12" font="0">A305652 10.2737 [-(3*x^3-x^2-x)/(-4*x^5+2*x^4+6*x^3-3*x^2-2*x+1)</text>
<text top="354" left="13" width="225" height="12" font="0">ogf_with_Euler_transform]</text>
<text top="370" left="13" width="513" height="12" font="0">A305653 11.3107 [-(-x-1)/(-x^5+5*x^4-10*x^3+10*x^2-5*x+1)</text>
<text top="386" left="13" width="225" height="12" font="0">ogf_with_Euler_transform]</text>
<text top="402" left="13" width="540" height="12" font="0">A305687 4.77012 [ -(3*x^6+18*x^4-27*x^3+6*x^2-19*x-1)/(x+1)/</text>
<text top="418" left="13" width="333" height="12" font="0">(x^7-2*x^6+x^5-11*x^3-x^2-7*x+1) ogf]</text>
<text top="434" left="13" width="495" height="12" font="0">A305708 10.6746 [-exp(-x)*sin(x)-exp(-x)*cos(x) lgdegf]</text>
<text top="450" left="13" width="684" height="12" font="0">A305721 4.33474 [{(2*n^2+9*n+10)*a(n+1)+(-4*n^2-20*n-123)*a(n+2)+(2*n^2+11*n</text>
<text top="466" left="13" width="468" height="12" font="0">+15)*a(n+3), a(0) = 1, a(1) = 99, a(2) = 1765}, ogf]</text>
<text top="482" left="13" width="684" height="12" font="0">A305721 4.98496 [ (x+1)*(x^6+90*x^5+911*x^4+2092*x^3+911*x^2+90*x+1)/(x-1)^8</text>
<text top="499" left="13" width="36" height="12" font="0">ogf]</text>
<text top="515" left="13" width="171" height="12" font="0">A305722 3.84802 [ -</text>
<text top="531" left="13" width="720" height="12" font="0">(x^8+120*x^7+1820*x^6+8008*x^5+12870*x^4+8008*x^3+1820*x^2+120*x+1)/(x-1)^9 ogf]</text>
<text top="547" left="13" width="684" height="12" font="0">A305722 3.84802 [{(2*n^2+9*n+10)*a(n+1)+(-4*n^2-20*n-153)*a(n+2)+(2*n^2+11*n</text>
<text top="563" left="13" width="477" height="12" font="0">+15)*a(n+3), a(0) = 1, a(1) = 129, a(2) = 2945}, ogf]</text>
<text top="579" left="13" width="721" height="12" font="0">A305723 3.54932 [ (x+1)*(x^2+14*x+1)*(x^6+138*x^5+975*x^4+1868*x^3+975*x^2+138*x</text>
<text top="595" left="13" width="153" height="12" font="0">+1)/(x-1)^10 ogf]</text>
<text top="611" left="13" width="684" height="12" font="0">A305723 4.10570 [{(2*n^2+9*n+10)*a(n+1)+(-4*n^2-20*n-187)*a(n+2)+(2*n^2+11*n</text>
<text top="627" left="13" width="477" height="12" font="0">+15)*a(n+3), a(0) = 1, a(1) = 163, a(2) = 4645}, ogf]</text>
<text top="644" left="13" width="684" height="12" font="0">A305724 3.80950 [{(2*n^2+9*n+10)*a(n+1)+(-4*n^2-20*n-225)*a(n+2)+(2*n^2+11*n</text>
<text top="660" left="13" width="477" height="12" font="0">+15)*a(n+3), a(0) = 1, a(1) = 201, a(2) = 7001}, ogf]</text>
<text top="676" left="13" width="522" height="12" font="0">A305753 14.3180 [ -x*(3*x-1)*(3*x+1)/(x-1)/(10*x^2-1) ogf]</text>
<text top="692" left="13" width="711" height="12" font="0">A305753 6.35159 [{a(n+4)-a(n+3)-10*a(n+2)+10*a(n+1), a(0) = 0, a(1) = 1, a(2) =</text>
<text top="708" left="13" width="162" height="12" font="0">1, a(3) = 2}, ogf]</text>
<text top="724" left="13" width="666" height="12" font="0">A305777 5.93776 [ (10*x^6-x^5-13*x^4+x^3+6*x^2-1)/(2*x-1)/(x+1)/(3*x^2-1)/</text>
<text top="740" left="13" width="198" height="12" font="0">(2*x^2-1)/(x-1)^2 ogf]</text>
<text top="756" left="13" width="693" height="12" font="0">A305826 4.95307 [ -(4*x^8-26*x^7+74*x^6-120*x^5+120*x^4-76*x^3+28*x^2-8*x+1)/</text>
<text top="772" left="13" width="549" height="12" font="0">(5*x-1)/(x^2-x+1)/(x^6-6*x^5+15*x^4-19*x^3+12*x^2-3*x+1) ogf]</text>
<text top="789" left="13" width="522" height="12" font="0">A305859 12.7577 [ (x^3+8*x^2+2*x+1)/(x^2+x+1)/(x-1)^2 ogf]</text>
<text top="805" left="13" width="702" height="12" font="0">A305859 5.27116 [{(4*n+13)*a(n+1)+4*a(n+2)+4*a(n+3)+(-4*n-9)*a(n+4), a(0) = 1,</text>
<text top="821" left="13" width="333" height="12" font="0">a(1) = 3, a(2) = 11, a(3) = 13}, ogf]</text>
<text top="837" left="13" width="531" height="12" font="0">A305867 32.7590 [1/(1-2*x)^(3/2), egf_with_Euler_transform]</text>
<text top="853" left="13" width="720" height="12" font="0">A305886 4.51802 [{(n+2)*a(n+2)+(-1722-1728*n)*a(n+1), a(0) = 1, a(1) = -6}, ogf]</text>
<text top="869" left="13" width="703" height="12" font="0">A305956 3.38722 [ -(9*x^9+25*x^7+26*x^6+121*x^5+186*x^4+48*x^3-15*x^2-21*x-1)/</text>
<text top="885" left="13" width="630" height="12" font="0">(11*x^9+39*x^8+58*x^7+107*x^6+135*x^5+54*x^4-14*x^3-17*x^2-4*x+1) ogf]</text>
<text top="901" left="13" width="684" height="12" font="0">A305991 5.88981 [{(n+2)*a(n+2)+(-24-27*n)*a(n+1), a(0) = 1, a(1) = -3}, ogf]</text>
<text top="1029" left="356" width="36" height="12" font="0">2320</text>
</page>
</pdf2xml>
