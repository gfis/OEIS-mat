#!perl

# Normalize eta product signature(s)
# @(#) $Id$
# 2023-01-24: concatenate several epsigs and join same qpows
# 2023-01-17, Georg Fischer
#
#:# Usage:
#:#   perl norm_epsig.pl [-d mode] [srcsig|-c|-|file...] > tarsig
#:#       -d    debugging mode: 0=none, 1=some, 2=more debugging output
#:#       -c    read from clipboard
#:#       file  read from file in seq4 format (eta signature in $(PARM1))
#:#       -     read from STDIN in seq4 format
#:#       sig   eta signature, for example [3,2],[7,1],[63,1],[1,-1],[9,-1],[21,-2] A093068
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
my $from_clip  = 0;
my $epsig = "";
my $from_file = 1;
# get options
while (scalar(@ARGV) > 0 && ($ARGV[0] =~ m{\A[\-\+]})) { # starts with "-" or "+"
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{\-c}) {
        $from_clip = 1;
        $from_file = 0;
    } elsif ($opt  =~ m{\-d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt eq "-") {
        $from_file = 1;
        $from_clip = 0;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

if (scalar(@ARGV) > 0) {
    my $arg = $ARGV[0];
    if ($arg =~ m{\A\[}) { # starts with "["
        $epsig = $arg;
        $from_file = 0;
        $from_clip = 0;
    } else {
        $from_file = 1;
        $from_clip = 0;
    }
}
if ($debug >= 2) {
    print "#d2 from_file=$from_file, from_clip= $from_clip, epsig=\"$epsig\"\n";
}
if (0) {
} elsif ($epsig ne "") {
    if ($debug >= 1) {
        print "args source: $epsig\n";
    }
    print &normalize($epsig);
} elsif ($from_clip) {
    $epsig = `powershell -command Get-Clipboard`;
    if ($debug >= 1) {
        print "clip source: $epsig\n";
    }
    print &normalize($epsig);
} else { # from file(s)
    while (<>) {
        s/\r?\n//;
        my $line = $_;
        if ($debug >= 2) {
            print "#d3 line=$line\n";
        }
        next if $line !~ m{\AA\d};
        my ($aseqno, $callcode, $offset, $epsig, @rest) = split(/\t/, $line);
        if ($debug >= 2) {
            print "#d4 line=$line\n";
        }
        $epsig = &normalize($epsig);
        print join("\t", $aseqno, $callcode, $offset, $epsig, @rest) . "\n";
    } # while <>
} # from file(s)
#----
sub normalize {
    my ($epsig) = @_;
    $epsig =~ s{\s}{}g; # remove whitespace
    $epsig =~ s{\]\,?\[}{\;}g; # "],[" -> ";", there may be several lists to be concatenated
    $epsig =~ s{[\[\]]}{}g; # remove all [ ]
    my %hash = (); # keys are the qpows only
    foreach my $pair (split(/\;/, $epsig)) { # pairs are separated by ";"
        my ($qpow, $epow) = split(/\,/, $pair);
        my $key = $qpow;
        if ($debug >= 1) {
            print "#d1 (qpow,epow) = ($qpow,$epow), key=$key\n";
        }
        $hash{$key} = defined($hash{$key}) ? ($hash{$key} + $epow) : $epow; # add to same qpow if that exists
    } # foreach $pair

    my %hapn = (); # attach "p" or "n" in front of the keys, and leading zeros before the qpos
    foreach my $key (keys(%hash)) { 
        my $qpow = $key;
        my $epow = $hash{$key};
        my $keypn = $epow < 0 ? sprintf("n%08d", $qpow) : sprintf("p%08d", $qpow); # expand numbers to 8 digits with leading zeros for proper sort
        if ($debug >= 2) {
            print "#d2 (qpowpn,epowpn) = ($qpow,$epow)\n";
        }
        $hapn{$keypn} = $epow;
    } # foreach $key

    my @qpows = ();
    my @epows = ();
    my $result = "";
    foreach my $key (reverse(sort(keys(%hapn)))) { # sort into positive, negative groups and by descending qpow in each group
        my $qpow = substr($key, 1) + 0; # remove "p", "n" and the leading zeros
        my $epow = $hapn{$key};
        if ($debug >= 3) {
            print "#d3 (qpow,epow) = ($qpow,$epow)\n";
        }
        $result .= ";$qpow,$epow";
    } # foreach $key
    $result =~ s{^\;}{\[};
    return "$result]";
} # normalize
#----
__DATA__
A093068	etaprod	0	[3,2],[7,1],[63,1],[1,-1],[9,-1],[21,-2]	-1/1	, 1	eta(q^3)^2*eta(q^7)*eta(q^63)/eta(q)/eta(q^9)/eta(q^21)^2
A100535	etaprod	0	[1,1],[2,2],[8,2],[1,-5],[4,-1]	-11/24	, 1	2*eta(q^2)^2*eta(q^8)^2/eta(q)^5/eta(q^4)
A105094	etaprod	0	[1,1],[2,8],[1,-16]	-1/1	, 1	8*eta(q^2)^8/eta(q)^16
A113418	etaprod	0	[2,1],[1,1]	-1/1	, 1	1/2*eta(q^2)^7*eta(q^4)/eta(q)^2/eta(q^8)^2-1/2
or
A093068	etaprod	1	[3,2;7,1;63,1;1,-1;9,-1;21,-2]	-1/1	, 1
A100535	etaprod	0	[1,1;2,2;8,2;1,-5;4,-1]	-11/24	, 1
A105094	etaprod	0	[1,1;2,8;1,-16]	-1/1	, 1
A113418	etaprod	1	[2,1;1,1]	-1/1	, 1
