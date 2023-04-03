#!perl

# Filter output of nisolut.pl and extract those with aöö non-diagonal elements = 0.
# @(#) $Id$
# 2023-01-24, Georg Fischer: copied from nisolut.pl; DvH=81
#
#:# Usage:
#:#     cat gramdiag.man \
#:#     | perl theta3_epsig.pl [-d mode] > output.seq4
#:#         -d  debugging level (0=none (default), 1=some, 2=more)
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
my ($aseqno, $callcode, $offset, $powlist, $dummy1, $dummy2, $name);
my @diags;

while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    next if $line !~ m{\AA\d+\t}; # does not start with aseqno tab
    ($aseqno, $callcode, $offset, $powlist, $dummy1, $dummy2, $name) = split(/\t/, $line);
    $callcode = $cc;
    $powlist =~ s{\s}{}g; # remove whitespace; so far it is a simple list of integers
    my @result = ();
    foreach my $diag(split(/\,/, $powlist)) {
        push(@result, &theta3_pow($diag));
    }
    print join("\t", $aseqno, $callcode, $offset, join(",", @result), "-1/1", 0, 1, $name) . "\n";
} # while <>
#----
sub theta3_pow { 
    my ($expon) = @_;
    my @sig = (2, 5, 4, -2, 1, -2); # EPSIG(theta_3)
    $sig[0] *= $expon;
    $sig[2] *= $expon;
    $sig[4] *= $expon;
    return "[$sig[0],$sig[1];$sig[2],$sig[3];$sig[4],$sig[5]]";
} # theta3_pow
#----------------
__DATA__
A320139	gramdiag	0	1,2,3,4			Number of integer solutions to a^2 + 2*b^2 + 3*c^2 + 4*d^2 = n.	
