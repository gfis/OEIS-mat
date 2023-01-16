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
    $name =~ s/[\.\;].*//; 
    $name =~ s/ in powers of.*//i; 
    $name =~ s/^Expansion of *//;
    next if $name =~ m{ [\+\-] };
    next if $name =~ m{bcdf-pr-su-zA-Z]};
    $name =~ s/ //g;
    my $qpf = "-1/1";
    my $init = 1;
    if ($name =~ s{^q\^\((\-?\d+\/\d+)\)\*}{}) {
    	$qpf = $1;
    }
    print join("\t", $aseqno, $callcode, 0, $name, "\"$qpf\"", "\", $init\"") . "\n";
} # while <>
#--------------------
__DATA__
A093068 etapr   0       (eta(q^3)^2*eta(q^7)*eta(q^63))/(eta(q)*eta(q^9)*eta(q^21)^2)
A100535 etapr   0       q^(-11/24)*2*eta(q^2)^2*eta(q^8)^2/(eta(q)^5*eta(q^4))
A105094 etapr   0       8*(eta(q^2)/eta(q)^2)^8
A113418 etapr   0       (eta(q^2)^7*eta(q^4)/(eta(q)*eta(q^8))^2-1)/2
A113661 etapr   0       ((eta(q^2)^15*eta(q^3)^2*eta(q^12)^2)/(eta(q)^6*eta(q^4)^6*eta(q^6)^5)-1)/6
A115977 etapr   0       16*(eta(q)*eta(q^4)^2/eta(q^2)^3)^8
A119952 etapr   0       q^6*eta(q^2)*eta(q^7)*eta(q^9)*eta(q^28)*eta(q^36)*eta(q^126)/(eta(q)*eta(q^4)*eta(q^14)*eta(q^18)*eta(q^63)*eta(q^252))
A143752 etapr   0       eta(q^3)*eta(q^4)*eta(q^5)*eta(q^60)/(eta(q)*eta(q^12)*eta(q^15)*eta(q^20))
A145726 etapr   0       eta(q)*eta(q^4)*eta(q^6)*eta(q^10)*eta(q^15)*eta(q^60)/(eta(q^2)*eta(q^3)*eta(q^5)*eta(q^12)*eta(q^20)*eta(q^30))
A145727 etapr   0       (eta(q^2)*eta(q^30))^3/(eta(q)*eta(q^4)*eta(q^6)*eta(q^10)*eta(q^15)*eta(q^60))
A145782 etapr   0       eta(q)*eta(q^4)*eta(q^6)^4*eta(q^10)^4*eta(q^15)*eta(q^60)/(eta(q^2)*eta(q^3)*eta(q^5)*eta(q^12)*eta(q^20)*eta(q^30))^2
A145786 etapr   0       (eta(q)*eta(q^4)*eta(q^6)*eta(q^10)*eta(q^15)*eta(q^60))^2/(eta(q^2)^4*eta(q^3)*eta(q^5)*eta(q^12)*eta(q^20)*eta(q^30)^4)