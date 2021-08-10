#!perl

# Determine the correct sign of the root
# @(#) $Id$
# 2021-08-10, Georg Fischer: copied from interval.pl
#
#:# Usage:
#:#   perl signify.pl [-d debug] [-f ../../../OEIS-mat/common/asjon] [-s skip] seq4_in > seq4_out
#:#       -f directory for *.json files
#:#       -s number of leading digits to skip
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
my $skip  = 2; # number of relevant digits for boundaries
my $ajson_dir = "../common/ajson";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{f}) {
        $ajson_dir = shift(@ARGV);
    } elsif ($opt  =~ m{2}) {
        $skip      = shift(@ARGV);
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
    $termlist = substr($termlist, $skip); # skip 4 at the beginning
    my $cmd = "grep -E \"[^A]$termlist\" $ajson_dir/$aseqno.json";
    my $example = `$cmd`;
    my $oldcc = $callcode;
    if ($example =~ m{(x\=\-|\"\-|: *\-)[\.\d]}) { # is negative
        if ($callcode =~ m{n\Z}) { # is already "...n"
            # ok
        } else {
            $callcode .= "n";
        }
    } else { # is positive
        if ($callcode =~ m{n\Z}) { 
            $callcode =~ s{n\Z}{}; # remove "n"
        } else { 
            # ok
        }       
    }
    if ($debug > 0) {
        print STDERR "$aseqno: signify $oldcc -> $callcode, termlist=$termlist, example=$example\n";
    }
    print join("\t", $aseqno, $callcode, @parms) . "\n";
} # while
__DATA__
A305326	decsolv	1	x.pow(3).subtract(CR.FOUR.multiply(x)).subtract(CR.TWO)		2,2,1,4,3,1,9,7,4	0	x^3-4*x-2	0	0			
A305327	decsolv	0	x.pow(3).subtract(CR.FOUR.multiply(x)).subtract(CR.TWO)		5,3,9,1,8,8,8,7,2	0	x^3-4*x-2	0	0			
A305328	decsolv	1	x.pow(3).subtract(CR.FOUR.multiply(x)).subtract(CR.TWO)		1,6,7,5,1,3,0,8,7	0	x^3-4*x-2	0	0			
