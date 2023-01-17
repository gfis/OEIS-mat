#!perl

# Normalize eta signature(s)
# @(#) $Id$
# 2023-01-17, Georg Fischer
#
#:# Usage:
#:#   perl normsig.pl [-d mode] [srcsig|-c|-|file...] > tarsig
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
my $etasig = "";
# get options
while (scalar(@ARGV) > 0 && ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{\-c}) {
        $from_clip = 1;
    } elsif ($opt  =~ m{\-d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt eq "-") {
        $from_clip = 0;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

if (scalar(@ARGV) > 0) {
    my $arg = $ARGV[0];
    if ($arg =~ m{\A\[}) {
        $etasig = $arg;
    }
}
if (0) {
} elsif ($etasig ne "") {
    if ($debug >= 1) {
        print "args source: $etasig\n";
    }
    print &normalize($etasig);
} elsif ($from_clip) {
    $etasig = `powershell -command Get-Clipboard`;
    if ($debug >= 1) {
        print "clip source: $etasig\n";
    }
    print &normalize($etasig);
} else { # from file(s)
    while (<>) {
        s/\r?\n//;
        my ($aseqno, $callcode, $offset, $sig, @rest) = split(/\t/, $_);
        if ($debug >= 2) {
            print "file source: $sig\n";
        }
        $etasig = &normalize($sig);
        print join("\t", $aseqno, $callcode, $offset, $etasig, @rest) . "\n";
    } # while <>
} # from file(s)
#----
sub normalize {
    my ($sig) = @_;
    $sig =~ s{\s}{}g; # remove whitespace
    $sig =~ s{\]\,\[}{\;}g; # "],[" - ";"
    $sig =~ s{[\[\]]}{}g; # remove [ ]
    my %hash = ();
    foreach my $pair (split(/\;/, $sig)) {
        my ($spread, $expon) = split(/\,/, $pair);
        my $key = $expon < 0 ? sprintf("n%08d", $spread) : sprintf("p%08d", $spread);
        if ($debug >= 1) {
            print "spread=$spread, expon=$expon, key=$key\n";
        }
        $hash{$key} = $expon;
    } # foreach $pair
    my $sep = "[";
    my $result = "";
    foreach my $key (reverse(sort(keys(%hash)))) {
        my $spread = substr($key, 1) + 0;
        $result .= "$sep$spread,$hash{$key}";
        $sep = ";";
    }
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
