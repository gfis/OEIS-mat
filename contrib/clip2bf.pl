#!perl

# Generate a b-file from a term list in the Windows clipboard 
# @(#) $Id$
# 2019-11-06, Georg Fischer
#
#:# Usage:
#:#   perl clip2bf.pl [-o ofs] > b123456.txt
#:#       -o offset, index of first term, default 0 
#---------------------------------
use strict;
use integer;
use warnings;
use POSIX;

my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my @parts = split(/\s+/, asctime(localtime(time)));  #  "Fri Jun  2 18:22:13 2000\n\0"
#                                             0   1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $parts[1], $parts[2], $parts[4]);

my $offset = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{o}) {
        $offset = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $clip = `powershell -command Get-Clipboard`;
$clip =~ s{\A[^\-0-9]*}{};
$clip =~ s{[^\-0-9]*\Z}{};
$clip =~ s{\\\r?\n\s*}{}g;
my @terms = split(/[^\-0-9]+/, $clip);
print "# Table of n, a(n) for n = $offset.." . ($offset + scalar(@terms) - 1) . "\n";
print "# Georg Fischer, $sigtime\n";
foreach my $term (@terms) {
    print "$offset $term\n";
    $offset ++;
} # foreach
