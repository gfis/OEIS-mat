#!perl

# Prepare eta product descriptions
# @(#) $Id$
# 2023-01-16, Georg Fischer
#
#:# Usage:
#:#   perl etaprep.pl [-d mode] cut_cat25.fmt > output.seq4
#:#       -d    debugging mode: 0=none, 1=some, 2=more debugging output
#---------------------------------
use strict;
use integer;
use warnings;
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
# defaults for options
my $debug   = 0;
my $callcode = "etaprod";

# get options
while (scalar(@ARGV) > 0 && ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{\-d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) {
    s/\r?\n//;
    my ($aseqno, $name) = split(/ /, $_, 2);
    $callcode = "etaprod"; # default, without pqf
    $name =~ s/[\.\;].*//; 
    $name =~ s/ in powers of.*//i; 
    $name =~ s/^Expansion of *//;
    my $epsig = $name;
    next if $epsig =~ m{ [\+\-] };
    next if $epsig =~ m{[bcdf-pr-su-zA-Z]};
    $epsig =~ s/ //g;
    my $factor = "1";
    my $pqf = "-1/1";
    my $init = 1; # no longer used
    if ($epsig =~ s{^(\-?\d+)\*}{}) { # first: extract constant factor
        $factor = $1;
    } # constant
    if ($epsig =~ s{^q\^\(?(\-?\d+(\/\d+)?)\)?\*}{}) { # second: extract leading power of q factor
        $pqf = $1;
        if ($pqf !~ m{\/}) {
            $pqf .= "/1";
        }
    } # leading qpf
    if (0) {
    } elsif ($factor != 1) {
        $callcode =~ s{d}{f}; # "etaprof" with pqf and factor
    } elsif ($pqf ne "-1/1") {
        $callcode =~ s{d}{q}; # "etaproq" with pqf
    }
    print join("\t", $aseqno, $callcode, 0, $epsig, "\"$pqf\"", 0, $factor, $name) . "\n";
} # while <>
#--------------------
__DATA__
A093068	etaprod	0	(eta(q^3)^2*eta(q^7)*eta(q^63))/(eta(q)*eta(q^9)*eta(q^21)^2)	"-1/1"	", 1"
A100535	etaprod	0	2*eta(q^2)^2*eta(q^8)^2/(eta(q)^5*eta(q^4))	"-11/24"	", 1"
A105094	etaprod	0	8*(eta(q^2)/eta(q)^2)^8	"-1/1"	", 1"
