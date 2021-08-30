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

my ($aseqno, $callcode, $offset, $name, @rest);
my $nok; # assume ok
# while (<DATA>) {
while (<>) {
    $nok = 0;
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    next if ! m{\AA\d+};
    ($aseqno, $callcode, $offset, $name, @rest) = split(/\t/, $line);
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
A190343	floor	0	floor(n^((n-1)/2))
A190504	floor	0	n+floor(s*n/r)+floor(t*n/r)+floor(u*n/r),r=phi,s=r+1,t=r+2,u=r+3
A190505	floor	0	n+floor(r*n/s)+floor(t*n/s)+floor(u*n/s),r=phi,s=r+1,t=r+2,u=r+3
A190506	floor	0	n+floor(r*n/t)+floor(s*n/t)+floor(u*n/t),r=phi,s=r+1,t=r+2,u=r+3
A190507	floor	0	n+floor(r*n/u)+floor(s*n/u)+floor(t*n/u),r=phi,s=r+1,t=r+2,u=r+3
A190508	floor	0	n+floor(s*n/r)+floor(t*n/r)+floor(u*n/r),r=phi,s=r^2,t=r^3,u=r^4
