#!perl

# Search for minimal k such that n! + k^2 = m^2, or -1 if no such k exists.
# 2020-11-26, Georg Fischer
#
#:# Usage:
#:#   perl brocard.pl
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $n = 1;
my $n2 = $n * $n;
while ($n2 >= 0) {
	if ($n2 =~ m{\A(\d+)(000+1)\Z}) {
		my ($lp, $rp) = ($1, $2);
		if (($lp & 0xff) == 0) {
		    print join("\t", $n, $n2, $1, $2) . "\n" 
		}
	}
    ++$n;
    $n2 = $n * $n;
}
__DATA__
88778751        7881666629120001        788166662912    0001
20! =        2432902008176640000
