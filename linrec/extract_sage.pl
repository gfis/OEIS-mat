#!perl

# Extract the numerators and denominators of generating functions
# @(#) $Id$
# 2019-05-01, Georg Fischer
#
#:# Usage:
#:#   wget https://github.com/eluzhnica/ISFA/blob/master/generatingFunctions
#:#   perl extract_sage.pl [-d debug] infile > outfile
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
my $aseqno;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if (0) {
    } elsif ($line =~ m{^def\s+(\w+)}) {
        $aseqno = $1;
    } elsif ($line =~ m{^\s+return}) {
        my $numerator = "";
        my $denominator = "";
        my $comt = "";
        my @dens;
        if ($line =~ m{\[\(([^\]]+)\)[\,\]]}) {
            my $fraction = $1;
            $fraction =~ s{\*\*}{\^}g;
            ($numerator, @dens) = split(/\//, $fraction);
            $denominator = "";
            if (0) {
            } elsif (scalar(@dens) == 0) {
            	$denominator = "";
            } elsif (scalar(@dens) > 1) {
            	$denominator = "((" . join(")*(", @dens) . "))";
            } else {
            	$denominator = $dens[0];
            }
            if (($fraction =~ m{[a-wyzA-Z]}) or ($fraction =~ m[\d{5}])) {
                $comt = "# E5 ";
            }
            if ($denominator !~ m{^\(}) {
                $comt = "# ?(?? ";
            }
            if (&nesting_diff($numerator) != 0 or &nesting_diff($denominator) != 0) {
            	$comt = "# ?()? ";
            }
        } else {
            $comt = "# ???";
        }
        print join("\t", $comt . $aseqno, "sage", $numerator, $denominator) . "\n";
    } else {
        # ignore
    }
} # while <>
#----
sub nesting_diff {
	my ($parm) = @_;
	my $op = scalar($parm =~ m{\(}g);
	my $cp = scalar($parm =~ m{\)}g);
	return $op - $cp;
} # nesting_diff
#--------------------------------------------
__DATA__

def A000008():
    x = SR.var('x')
    return { 'ogf': [(1/((1-x)*(1-x**2)*(1-x**5)*(1-x**10)))] }



def A000012():
    x = SR.var('x')
    return { 'ogf': [(1/(1-x))] }



def A000027():
    x = SR.var('x')
    return { 'ogf': [(x/(1-x)**2)] }



def A000032():
    x = SR.var('x')
    return { 'ogf': [((2-x)/(1-x-x**2))] }

