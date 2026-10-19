#!perl

# @(#) $Id$
# 2026-10-19, Georg Fischer
#
#:# emit code for a Horner's scheme
#:# Usage:
#:#   perl horner.pl [-d debug] vector > formula.joeis
#:#       -d debugging mode: 0=none, 1=some, 2=more
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  eq "-d") {
        $debug     =  shift(@ARGV); 
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

if (scalar(@ARGV) > 0) {
    expand(shift(@ARGV));
} else {
    while (<DATA>) {
        expand($_);
    }
}
sub expand {
    my ($vector) = @_; 
    $vector =~ s{[^\-0-9,]}{}g;
    my @coeffs = reverse(split(/\,/, $vector));
    if ($debug >= 1) {
        print "[" . join("\,", @coeffs) . "]\n";
    }
    my $form = "";
    foreach my $elem (@coeffs) {
        my $coeff = ($elem =~ m{\A\-}) ? ".-(" . substr($elem, 1) . ")" : ".+($elem)";
        $form .= ".*(n)$coeff"
    } # foreach $coeff 
    #                 (  )     (1   1 )
    $form =~ s{\A\.\*\(n\)\.\+\((\d+)\)\.\*\(n}{Z.valueOf\($1\*n};
    $form =~ s{\A\.\*\(n\)\.\-\((\d+)\)\.\*\(n}{Z.valueOf\(\-$1\*n};
    $form =~ s{\.\+\(0\)}{}g; # remove ".+(0)"
    print "$form\n";
} # expand
__DATA__
[2,3,4]
[2,0,1,0,1,-4]

