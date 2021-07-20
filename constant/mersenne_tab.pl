#!perl

# Extract parameters from the table https://oeis.org/A195284 and A195304
# @(#) $Id$
# 2021-07-17, Georg Fischer
#
#:# Usage:
#:#   perl philo_tab.pl [-d debug] > philo_tab.tmp
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $ignore = 1;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{i}) {
        $ignore    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
while (<DATA>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if (0) {
    } elsif ($line =~ m{ 2\^(\d+) ?\- *1}) {
    	my $expon = $1;
    	&output(substr($line, 0, 7), $expon);
    } else {
        # ignore
    }
} # while
#----
sub output {
    my ($aseqno, $expr) = @_;
    if ($aseqno =~ m{\AA[0-9]}) {
        print join("\t", $aseqno, "zbasex", 0, "Z.ONE.shiftLeft($expr).subtract(Z.ONE)", "Mersenne 2^$expr-1") . "\n";
    }
} # output
__DATA__
A169681	Fini39	Decimal expansion of 2^127 - 1.
A169684	Fini33	Decimal expansion of 2^107 - 1.
A169685	Fini157	Decimal expansion of 2^521 - 1.
A204063 Fini    Decimal expansion of 2^607 - 1, the 14th
A248931 Fini    Decimal expansion of 2^1279 - 1, the 15t
A248932 null    Decimal expansion of 2^2203 - 1, the 16th Mersen
A248933 null    Decimal expansion of 2^2281 - 1, the 17th Mersen
A248934 null    Decimal expansion of 2^3217 - 1, the 18th Mersen
A248935 null    Decimal expansion of 2^4253 - 1, the 19th Mersen
A248936 null    Decimal expansion of 2^4423 - 1, the 20th Mersen
A275977 null    Decimal expansion of 2^9689 - 1, the 21st Mersen
A275979 null    Decimal expansion of 2^9941 - 1, the 22nd Mersen
A275980 null    Decimal expansion of 2^11213 - 1, the 23rd Merse
A275981 null    Decimal expansion of 2^19937 - 1, the 24th Merse
A275982 null    Decimal expansion of 2^21701 - 1, the 25th Merse
A275983 null    Decimal expansion of 2^23209 - 1, the 26th Merse
A275984 null    Decimal expansion of 2^44497 - 1, the 27th Merse
A089065 null    Decimal expansion of 2^13466917 - 1, the 39th Me
A089578 null    Decimal expansion of 2^20996011 - 1, the 40th Me
A117853	null    Decimal expansion of 2^30402457 - 1, the 43th .
A193864 null    Decimal expansion of 2^43112609 - 1, the 47th Me
A267875 null    Decimal expansion of 2^74207281 - 1
A344983 null    Decimal expansion of 2^77232917 - 1
A344984 null    Decimal expansion of 2^82589933 - 1
