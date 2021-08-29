#!perl

# Split expressions over several seq4 records, later be recombined by expr_join.pl
# @(#) $Id$
# 2021-08-29, Georg Fischer
#
#:# Usage:
#:#   perl expr_split.pl [-d debug] input.seq4 > output.seq4
#
# The records will be sorted by aseqno and callcode, 
# and the callcode ending in "_z" has the main expression.
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
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
my ($aseqno, $superclass, $name, @rest);
my $nok; # assume ok
# while (<DATA>) {
while (<>) {
    $nok = 0;
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    next if ! m{\AA\d+};
    ($aseqno, $superclass, $name, @rest) = split(/\t/, $line);
    my $orig_name = $name;
    
    my $cc = "floor_";
    $name =~ s{\,\,+}{\,}g; # only one separator
    foreach my $part(split(/\,/, $name)) {
        $part =~ s{\A((\w)\=)?(.+)}{$3};
        my $var = $2;
        $part =~ s{\;}{\,}g; # e.g. "agm(a;b)"
        my $code = defined($var) ? ("m" . uc($var)) : "z"; # "z" is the highest lowercase letter and may not be a variable name
        print join("\t", $aseqno, "$cc$code", 0, $part) . "\n";
    } # foreach
    # $name =~ s{[\;\:]}{\,}g; # normalize to ","
} # while
__DATA__
A184809	null	n+floor(sqrt(3/2)*n)
A184909	null	n+floor(s*n/r)+floor(t*n/r),r=2^(1/4),s=2^(1/2),t=2^(3/4)
A184910	null	n+floor(r*n/s)+floor(r*n/t),r=2^(1/4),s=2^(1/2),t=2^(3/4)
A184911	null	n+floor(r*n/t)+floor(s*n/t),r=2^(1/4),s=2^(1/2),t=2^(3/4)
