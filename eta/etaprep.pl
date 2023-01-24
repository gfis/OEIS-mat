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
    $callcode = "etaprod";
    $name =~ s/[\.\;].*//; 
    $name =~ s/ in powers of.*//i; 
    $name =~ s/^Expansion of *//;
    next if $name =~ m{ [\+\-] };
    next if $name =~ m{[bcdf-pr-su-zA-Z]};
    $name =~ s/ //g;
    my $factor = "1";
    my $qpf = "-1/1";
    my $init = 1;
    if ($name =~ s{^(\-?\d+)\*}{}) { # with constant factor
        $factor = $1;
        $callcode = "etaprodf";
    } # constant
    if ($name =~ s{^q\^\(?(\-?\d+(\/\d+)?)\)?\*}{}) { # with leading power of q factor
        $qpf = $1;
        if ($qpf !~ m{\/}) {
            $qpf .= "/1";
        }
    } # leading qpf
    print join("\t", $aseqno, $callcode, 0, $name, "\"$qpf\"", "\", $init\"", $factor, $name) . "\n";
} # while <>
#--------------------
__DATA__
A093068	etaprod	0	(eta(q^3)^2*eta(q^7)*eta(q^63))/(eta(q)*eta(q^9)*eta(q^21)^2)	"-1/1"	", 1"
A100535	etaprod	0	2*eta(q^2)^2*eta(q^8)^2/(eta(q)^5*eta(q^4))	"-11/24"	", 1"
A105094	etaprod	0	8*(eta(q^2)/eta(q)^2)^8	"-1/1"	", 1"
