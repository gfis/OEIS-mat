#!perl

# Expand psi(x) * psi(x^k) into an EPSIG
# @(#) $Id$
# 2023-01-26, Georg Fischer: copied from theta3_epsig.pl
#
#:# Usage:
#:#     perl psipsik_epsig.pl [-d mode] > output.seq4
#:#         -d  debugging level (0=none (default), 1=some, 2=more)
#:# Ramanujan's psi has EPSIG="[2,2;1,-1]"
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $cc = "etaprod";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
my $line;
my ($aseqno, $callcode, $offset, $psik, @rest);
my $name;

while (<DATA>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    next if $line !~ m{\AA\d+\t}; # does not start with aseqno tab
    ($aseqno, $callcode, $offset, $psik, @rest) = split(/\t/, $line);
    $callcode = $cc;
    $psik =~ s{\s}{}g; # remove whitespace; so far it is a simple list of integers
    print join("\t", $aseqno, "etaproq", $offset, &psipsik_pow($psik), 0, 1, $name) . "\n";
} # while <>
#----
sub psipsik_pow { # A286813() (0, "[16,2;2,2;8,-1;1,-1]", "-9/8");
    # Ramanujan's psi has EPSIG="[2,2;1,-1]"
    my ($k) = @_;
    my $k2 = 2 * $k;
    $name = "psi(q) * psi(q^$k)";
    my $pqfnum = (2*$k2 + 4 - $k - 1);
    my $div = &gcd($pqfnum, 24);
    $pqfnum /= $div;
    my $pqfden = 24/$div;
    return "[$k2,2;2,2;$k,-1;1,-1]\t-$pqfnum/$pqfden";
} # psipsik_pow
#----
sub gcd { # from https://www.perlmonks.org/?node_id=109872
  my ($a, $b) = @_;
  ($a,$b) = ($b,$a) if $a > $b;
  while ($a) {
    ($a, $b) = ($b % $a, $a);
  }
  return $b;
} # gcd
#----------------
__DATA__
Related to the number of positive odd solutions to equation x^2 + k*y^2 = 8*n + k + 1: 
A008441	psipsik	0	1
A033761	psipsik	0	2
A033762	psipsik	0	3
A053692	psipsik	0	4
A033764	psipsik	0	5
A259896	psipsik	0	6
A035162	psipsik	0	7
A286813	psipsik	0	8
