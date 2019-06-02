#!perl

# Extract formulas for decimal expansion sequences
# @(#) $Id$
# 2019-05-28, Georg Fischer
#
#:# Usage:
#:#   make -f gener.make decexp_nimpl
#:#   perl extract_decexp.pl [-d debug] decexp_nimpl.tmp > outfile
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
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

my $line;
my $code;
my $comt     = "";
my $content;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    my ($aseqno, $form, @rest) = split(/\t/, $line);
	$form =~ s{Decimal\s+expansion\s+of\s+(the\s+constant\s+)?}[};
    $form =~ s{\s*\.\s*\Z}{};
    $form =~ s{\s}{}g;
    $form = lc($form);
    my @words = grep {! m{(e|Pi|log|exp|sqrt} ($form =~ m{[a-z\_]+}g);
    if (0) {
    } elsif (scalar(@words) == 0) {
    	print join("\t", $aseqno, $form);
    } else {
        # ignore
    }
} # while <>
#----
sub nesting_diff {
    my ($parm) = @_;
    if (! defined($parm)) {
        $parm = "";
    }
    my $op = ($parm =~ s/\(/\{/g);
    my $cp = ($parm =~ s/\)/\}/g);
    return $op - $cp;
} # nesting_diff
#--------------------------------------------
__DATA__
# OEIS as of February 28 14:44 EST 2019
A037222	Decimal expansion of Pi*e^2.	nonn,cons,synth
A037996	Decimal expansion of Pi*exp(2*Pi-Pi^2/2).	cons,nonn,synth
