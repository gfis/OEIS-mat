#!perl

# @(#) $Id$
# 2024-08-27, Georg Fischer
#
#:# Filter records, extract callcodes for ramath/../JoeisPreparer into a file and execute them
#:# Usage:
#:#   perl joeisprep.pl [-d mode] infile.seq4 > outfile.seq4
#:#       -d debugging mode: 0=none, 1=some, 2=more
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $jprep_cmd = "java -cp \$GITS/ramath/dist/ramath.jar org.teherba.ramath.sequence.JoeisPreparer";
my $filename  = "joeisprep.tmp";

my $debug   = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  eq "-d") {
        $debug     =  shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

# select the following callcodes only:
my %jprep_cc = qw(
    bva 1
    ogf 1
    );
open(TMP, ">", $filename) || die "cannot write $filename";
#while (<DATA>) {
while (<>) {
    if (m{\AA\d+\s}) { # starts with A-number tab
        s/\s+\Z//; # chompre
        my ($aseqno, $callcode, $offset1, @parms) = split(/\t/);
        if (defined($jprep_cc{$callcode})) {
            if ($callcode eq "ogf") {
                $callcode = "lingf";
            }
            print TMP join("\t", $aseqno, $callcode, $offset1, @parms) ."\n";
        }
    }
} # while
close(TMP);
my $result = `$jprep_cmd -f $filename`;
print "$result\n";
__DATA__
# test data
A249786	bva	0	(256*n^3+1536*n^2+576*n-704)*a(n)+(-48*n^2-384*n-696)*a(n+3)+(-n^3-18*n^2-107*n-210)*a(n+6)	0	1	(A^2-4*x)^3-(-A^3+2)^2
