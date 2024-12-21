#!perl

# @(#) $Id$
# 2024-12-21, Georg Fischer: copied from struct.pl
#
#:# Postprocess parentheses, remove superfluous ones in the 4th field $(PARM1) by a postfix transformation.
#:# Usage:
#:#   perl postparen.pl [-d debug] infile.seq4 > outfile.seq4
#:#       -d debugging mode: 0=none, 1=some, 2=more
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  eq "-d") {
        $debug     =  shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($aseqno, $callcode, $offset, @parms, $inits, $seqlist, @rest);
my $lambda; # the outermost lambda parameter tuple
my $lamvars; # lambda expression parameter names (single lc char.)
my $root;
my $form;
my $iparm = 0; # $(PARM1)
my $semic = ";";
my $idiv  = "~"; # symbol for integer division
my $eq    = "=";
my $colon = ":";

while (<DATA>) {
# while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_;
    if ($line =~ m{\AA\d+\t}) {
        ($aseqno, $callcode, $offset, @parms) = split(/\t/, $line);
        $form = $parms[$iparm];
        #              1      1
        while ($form =~ s{\(\(([^\)\(]+)\)\)}{\($1\)}g) {
        }
        $parms[$iparm] = $form;
        print join("\t", $aseqno, $callcode, $offset, @parms) . "\n";
    } else {
        print "$line\n"; # copy all other lines
    }
} # while
#-------- end of main --------

__DATA__
A243035	lsmtraf	0	n -> 9*10^((f+(n+1)))
A229361	lsmtraf	0	n -> 97+41*Z2((n))
A229361	lsmtraf	0	n -> 97+41*Z2((((n+4))))
