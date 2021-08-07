#!perl

# Determine the interval boundaries for the Newton algorithm from the offset and a termlist in $parms[3]
# @(#) $Id$
# 2021-08-01: negate for callcode = ...n
# 2021-07-28, Georg Fischer
#
#:# Usage:
#:#   perl interval.pl [-d debug] [-w width] seq4_in > seq4_out
#:#       -w width, number of relevant digits for boundaries (default: 4)
#--------------------------------------------------------
use strict;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
my $width = 4; # number of relevant digits for boundaries
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{w}) {
        $width     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) {
    my $line = $_;
    next if $line !~ m{\AA\d+};
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $callcode, @parms) = split(/\t/, $line);
    my $offset   = $parms[0];
    my $termlist = $parms[3];
    $termlist =~ s{\,}{}g;
    $parms[3] = &deconst($offset, -1, $termlist); # sprintf("%4.2f", $target - $dist);
    $parms[4] = &deconst($offset, +1, $termlist); # sprintf("%4.2f", $target + $dist);
    if ($callcode =~ m{n\Z}) { # ends with "n"
        my $temp  = -$parms[4]; # negate and exchange 
        $parms[4] = -$parms[3];
        $parms[3] =  $temp;
    }
    $parms[6] = $termlist;
    print join("\t", $aseqno, $callcode, @parms) . "\n";
} # while
#----
sub deconst { # global: $width
    my ($offset, $sign, $termlist) = @_;
    $termlist =~ m{\A(0*)};
    my $w2 = length($1) + $width; # increase by number of leading zeroes in $termlist
    my $result = ("0." . substr($termlist, 0, $w2)) *(10 ** $offset);
    my $dist = $result * $sign * 0.02;
    $result = sprintf("%.3f", $result + $dist);
    $result =~ s{ }{}g;
    return $result;
} # deconst
__DATA__
A019679	infix	0	CR.TWO.multiply(x).sin().subtract(CR.THREE.multiply(x).sin().pow(CR.TWO))		2,6,1,7,9,9,3,8,7	0	sin(2*x)-(sin(3*x))^2	0	0	null	null	null
A105199	infix	1	CR.TWO.multiply(x).sin().subtract(CR.ONE.multiply(x).sin().pow(CR.TWO))		1,1,0,7,1,4,8,7,1	0	sin(2*x)-(sin(1*x))^2	0	0	null	null	null
A195695	infix	0	CR.FOUR.multiply(x).sin().subtract(CR.TWO.multiply(x).sin().pow(CR.TWO))		6,1,5,4,7,9,7,0,8	0	sin(4*x)-(sin(2*x))^2	0	0	null	null	null
A197133	infix	0	CR.ONE.multiply(x).sin().subtract(CR.TWO.multiply(x).sin().pow(CR.TWO))		2,7,2,9,7,1,8,4,9	0	sin(1*x)-(sin(2*x))^2	0	0	null	null	null
