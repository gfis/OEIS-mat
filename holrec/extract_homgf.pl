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
my $mode = "sqrt"; # default
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
my $expr;
my $gftype; # "egf" if e.g.f, "ogf" otherwise
my $callcode = "homgf";
my $ok = 1;
while(<>) {
    $line   = $_;
    #                         1        2                 3                          4                    5           
    if ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?([EO]\.)?[Gg]\.f\.\s*\:?\s*(A\([t-z]\)\s*\=\s*)?([^\.\,\;\=]+)}i) { 
        $gftype = "ogf";
        $aseqno = $1;
        $gftype = substr(lc($3 || "o"), 0, 1) . "gf";
        $expr   = $5;
        $line   =~ s{\s+\Z}{}; # chompr
        $expr   = lc($expr);
        $expr   =~ s{(where|\-\s*\_|\[From).*}{};
        $expr   =~ s{\s}{}g;
        if (($expr =~ m{[a-z_][a-z_]}) or ($expr =~ m{\^\(\-?\d+\/\d+\)})) { # word or ^(n/m)
            $ok = 1;
            if ($expr =~ m{[\'\!]}) {
                $ok = 0; # derivative or factorial
            }
            my %letters = ();
            foreach my $word ($expr =~ m{([a-z_]+)}g) {
                if (length($word) == 1) {
                    $letters{$word} = 1;
                } else { # length >= 2
                    if (0) {
                    } elsif ($mode eq "sqrt" and ($word !~ m{sqrt})                                ) {
                        $ok = 0; # wrong function
                    } elsif ($mode eq "func" and ($word !~ m{sqrt|besseli|exp|log|(arc)?(sin|cos|tan|cot|sec|sct)h?})) {
                        $ok = 0; # wrong function
                    } elsif ($mode eq "sump" and ($word !~ m{(sum|product|prod)_?})) {
                        $ok = 0; # wrong function
                    } elsif ($mode eq "all" and 0 == 1) { #   and ($word !~ m{sqrt|exp|log|(arc)?(sin|cos|tan|cot|sec|sct)h?})) {
                        $ok = 0; # wrong function
                    } else {
                    }
                }
            }  # foreach $word
            if (scalar(%letters) == 1) {
                $expr =~ s{(\A|[^a-z])([a-z])([^a-z]|\Z)}{${1}x$3}g; # unify variable to "x"
            } else {
                $ok = 0; # more than 1 variable
            }
            if ($ok == 0) { # bad
                print "# $line\n";
            } else {
                &output();
            }
        } # with word or ^(n/m)
    } # if %NF line
} # while <>

sub output {
	$expr =~ s{(arc?(sin|cos|tan|cot)h?)\^2\*x}{$1\(x\)\^2}g;
    $expr =~ tr{\[\]\{\}}
               {\(\)\(\)}; # equalize brackets
    print join("\t", $aseqno, $callcode . substr($gftype, 0, 1), 0, $expr, $gftype) . "\n";
} # output
__DATA__
