#!perl

# Grep lines with recurrences from cat25.txt
# @(#) $Id$
# 2019-12-07, Georg Fischer
#
#:# Usage:
#:#   perl grep_rectab.pl ../common/cat25.txt
#:#   | perl pre_rectab.pl [-a init] > outfile
#:#       -a additional initial terms (more than order)
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.2";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug  = 0;
my $ainit  = 0; # additional initial terms
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{a}) {
        $ainit  = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) {
    s{\s+\Z}{};
    if (m{\A\%([NF])}) { # name or formula
        my $line = substr($_, 3); # remove %x
        $line =~ s{\..*}{}; # remove all behind "."
        my $cond = "";
        if ($line =~ m{((for|if|when|with)\s*n\s*\>?\=?\s*\d+)}) {
            $cond = $1;
            $line =~ s{$cond}{};
        }
        my $aseqno = substr($line, 0, 7);
        $line = substr($line, 7);
        $line =~ s{\s}{}g;
        if (($line =~ m{\A[an\,\;\-\+\*\^\d\(\)\=]+\Z}) and ($line =~ m{a\(n})) {
            print join("\t", $aseqno, $line . "; $cond") . "\n";
        }
    } # name or formula
} # while <>
__DATA__
