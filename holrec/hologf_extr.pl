#!perl

# Grep generating functions of type (o)rdinary or (e)xponential from jcat25.txt
# @(#) $Id$
# 2022-11-09, Georg Fischer: copied from holrec/gf_extract.pl
#
#:# Usage:
#:#   perl hologf_extr.pl $(COMMON)/jcat25.txt > output
#-----------------------------------------------------------------------------
use strict;
use integer;
use warnings;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
#----
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my $line;
my $aseqno;
my $oseqno = ""; # old aseqno
my $ano = 0; # current number of g.f. in this $aseqno
my $expr;
my $rest;
my $gftype; # "egf" if e.g.f, "ogf" otherwise
my $callcode;
my $offset   = 0;
my $ok = 1;

while(<>) {
    $line   = $_;
    if ($line =~ m{Conjecture|Empirical|Apparant|Appears}i) {
        # ignore
    #                              1        2                 3                              4                    5         6 
    } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?([EO]\.)?[Gg]\.f\.\s*[\:\=]?\s*(A\([a-z]\)\s*\=\s*)?([^\.\;]+)(.*)}i) { 
        $expr   = " $5";
        $rest   = $6;
        $aseqno = $1;
        $gftype = substr(lc($3 || "o"), 0, 1) . "gf";
        if ($expr =~ m{sum|add|prod|mul|satisf|fibon|exp|column|row|floor|ceil|hypergeom|Series_Reversion}i) {
            # ignore
        } elsif ($rest !~ m{\A\.\.\.}) {
            if ($aseqno eq $oseqno) {
                $ano ++;
            } else {
                $oseqno = $aseqno;
                $ano = 0;
            } 
            $expr   =~ s{\-\s*[a-zA-Z\ _\.\,]+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d\d \d\d\d\d}{}; # remove - a.b. author, Apr 13 2020
            $expr   =~ s{(\W|\A)c\(}{$1 . "Catlan("}eig;
            $expr   =~ s{(with|where|\-\s*\_|\[From).*}{};
            $expr   =~ s{Bessel_([A-Z])}{Bessel$1}g;
            $expr   =~ s{\A\s+}{};
            $expr   =~ s{\s+\Z}{};
            $expr   =~ s{\,\Z}{};
            $callcode = "hologf" . substr($gftype, 0, 1);
            &output();
        } # rest not "..."
    } # if %NF line
} # while <>
#---------
sub output {
    $expr =~ s{(arc?(sin|cos|tan|cot)h?)\^2\*x}{$1\(x\)\^2}g; # care for sin^2(x)
    $expr =~ tr{\[\]\{\}}
               {\(\)\(\)}; # equalize brackets
    print join("\t", $aseqno, $callcode, 0, "$expr", $gftype) . "\n";
} # output
__DATA__
