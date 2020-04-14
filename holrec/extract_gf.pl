#!perl

# Grep generating functions of type (o)rdinary or (e)xponential for JoeisPreparer 
# @(#) $Id$
# 2020-04-08, Georg Fischer: copied from holrec/extract_hosqrt.pl
#
#:# Usage:
#:#   perl extract_homgf.pl [-m (sqrt|func)] $(COMMON)/cat25.txt > homgf1.tmp
#:#       -m selection of functions
#-----------------------------------------------------------------------------
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
#----
my $mode = "extr"; # default
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{m}) {
        $mode = shift(@ARGV);
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
my $callcode = "homgf";
my $offset   = 0;
my $ok = 1;
my %letters = ();
my $letter;
if (0) {
} elsif ($mode =~ m{^extr}) {
    while(<>) {
        $line   = $_;
        #                         1        2                 3                          4                    5         6 
        if ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?([EO]\.)?[Gg]\.f\.\s*\:?\s*(A\([a-z]\)\s*\=\s*)?([^\.\;]+)(.*)}i) { 
            $expr   = " $5";
            $rest   = $6;
            if ($rest !~ m{\A\.\.\.}) {
                $gftype = "ogf";
                $aseqno = $1;
                $gftype = substr(lc($3 || "o"), 0, 1) . "gf";
                if ($aseqno eq $oseqno) {
                    $ano ++;
                } else {
                    $oseqno = $aseqno;
                    $ano = 0;
                } 
                $expr   =~ s{\-\s*[a-zA-Z\ _\.\,]+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d\d \d\d\d\d}{}; # remove - a.b. author, Apr 13 2020
                if ($expr =~ m{Catalan}i) {
                    $expr =~ s{(\W)c\(}{${1}Catalan\(}ig;
                }
                $expr   =~ s{(where|\-\s*\_|\[From).*}{};
                $expr   =~ s{\A\s+}{};
                $expr   =~ s{\s+\Z}{};
        #       $expr   =~ s{\s}{}g;
                $callcode = "homgf" . substr($gftype, 0, 1) . $ano;
                &output();
            } # rest not "..."
        } # if %NF line
    } # while <>
    # mode extract

} elsif ($mode =~ m{^linr}) {
    while(<>) {
        s{\s+\Z}{}; # chompr
        $line   = $_;
        ($aseqno, $callcode, $offset, $expr, $gftype) = split(/\t/, $line);
        $expr =~ s{\s}{}g;
        if ($expr =~ m{\A([0-9t-z\+\-\/\*\^\(\)])+\Z}) { # ( + - * / ) t u v w x y z
            if ($expr !~ m{\^\D}) { # not a natural number power
                if ($expr !~ m{[a-z][a-z]}) { # not 2 letters
                    %letters = ();
                    foreach $letter ($expr =~ m{([a-z])}g) { # collect the different ones
                        $letters{$letter} = 1;
                    } # foreach
                    if (scalar(%letters) == 1) {
                        $expr =~ s{[a-z]}{x}g; # unify to x
                        $callcode = "lingf" . substr($gftype, 0, 1);
                        &output();
                    } else {
                        print "#4vars "; &output();
                    }
                } else {
                    # print "#3 "; &output();
                }
            } else {
                print "#2^nok "; &output();
            }
        } else {
            # print "#1 "; &output();
        }
    } # while <>
    # mode linrec
    
} else {
    die "invalid mode \"$mode\"\n";
} # mode
sub output {
    $expr =~ s{(arc?(sin|cos|tan|cot)h?)\^2\*x}{$1\(x\)\^2}g; # care for sin^2(x)
    $expr =~ tr{\[\]\{\}}
               {\(\)\(\)}; # equalize brackets
    print join("\t", $aseqno, $callcode, 0, "$expr", $gftype) . "\n";
} # output
__DATA__
