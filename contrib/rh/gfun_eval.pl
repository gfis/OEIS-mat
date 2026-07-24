#!perl

# Convert output of gfun:-listtorec into CC=holos seq4 records

# @(#) $Id$
# 2026-07-21, Georg Fischer: copied from holguess.pl
#
#:# usage:
#:#   perl gfun_eval.pl (aseqno, input).seq4 > (aseqno, bva, offset, recurrence, inits).seq4
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my ($aseqno, $cc, $offset, $parm1, $order, $recurrence, $termno, $termlist, @terms);
while(<>) {
# while(<DATA>) {
    s/\s+\Z//; # chompr
    next if length($_) > 2048;
    if (m{\A[A-Z](\d{6})}) { # valid A-number
        ($aseqno, $cc, $offset, $parm1) = split(/\t/);
        if ($parm1 !~ m{FAIL}) {
            $parm1 =~ s{\, *ogf}{};
            $parm1 =~ s{[ \[\{\]\}]}{}g; # remove superfluous characters
            my ($recurrence, @terms) = split(/\,/, $parm1);
            $termlist = join(",", map { s{a\(\d+\)\=}{}; $_ } @terms);
            print join("\t", $aseqno, "bva", $offset, $recurrence, $termlist, 0, 0) . "\n";
        } else {
        }
    } # valid A-number
} # while <>
__DATA__
A267991	guf	0	[{(-8*n-32)*a(n)+(4*n+20)*a(n+1)+(10*n+42)*a(n+2)+(-5*n-26)*a(n+3)+(-2*n-10)*a(n+4)+(n+6)*a(n+5), a(0) = 1, a(1) = 4, a(2) = 5, a(3) = 15, a(4) = 21}, ogf]
A154086	guf	0	FAIL
Error, (in interpmat) time expired |ratinterp.mi:516|
A156404	guf	0	[{76215235218633197762*a(n+1)+793844442381291179496*a(n+3)-447888269541954038322*a(n+5)-1752822241180666151655*a(n+7)+485055681570061947180*a(n+9)+623508255355166467698*a(n+11), a(0) = 1, a(1) = 0, a(2) = 810, a(3) = 0, a(4) = 23280, a(5) = 0, a(6) = 68180, a(7) = 0, a(8) = 175765, a(9) = 0, a(10) = 760131, a(11) = 0, a(12) = 2108280, a(13) = 0, a(14) = 3657680, a(15) = 0, a(16) = 5281910, a(17) = 0, a(18) = 13033260, a(19) = 0, a(20) = 29182380, a(21) = 0, a(22) = 37198440, a(23) = 0, a(24) = 46154300, a(25) = 0, a(26) = 85583500, a(27) = 0, a(28) = 202480300, a(29) = 0, a(30) = 193358000}, ogf]
A156414	guf	0	[{(8363*n-33620)*a(n)+41*a(n+4), a(0) = 1, a(1) = 0, a(2) = 0, a(3) = 0, a(4) = 820, a(5) = 0, a(6) = 0, a(7) = 0, a(8) = 3360, a(9) = 0, a(10) = 0, a(11) = 0, a(12) = 36432, a(13) = 13751, a(14) = 0, a(15) = 0, a(16) = 31360, a(17) = 0, a(18) = 0, a(19) = 0, a(20) = 195030, a(21) = 56610, a(22) = 0, a(23) = 0, a(24) = 267840, a(25) = 0, a(26) = 0, a(27) = 0, a(28) = 311160, a(29) = 591360, a(30) = 0, a(31) = 0, a(32) = 1153590, a(33) = 0, a(34) = 0, a(35) = 0, a(36) = 1588985, a(37) = 1579898, a(38) = 0, a(39) = 0, a(40) = 3060152, a(41) = 0, a(42) = 0, a(43) = 0, a(44) = 6895464, a(45) = 5338980, a(46) = 0, a(47) = 0}, ogf]
A172743	guf	0	[{(100*n^3+950*n^2+2850*n+2700)*a(n)+(-70*n^3-735*n^2-2530*n-2865)*a(n+1)+(-14*n^3-161*n^2-610*n-763)*a(n+2)+(-18*n^3-225*n^2-934*n-1287)*a(n+3)+(2*n^3+27*n^2+120*n+175)*a(n+4), a(0) = 1, a(1) = 7, a(2) = 55, a(3) = 415}, ogf]
