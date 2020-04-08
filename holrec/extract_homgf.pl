#!perl

# Grep generating functions of type (o)ordinary or (e)exponential for JoeisPreparer 
# @(#) $Id$
# 2020-01-05: $factor
# 2020-04-08, Georg Fischer: copied from holrec/extract_hosqrt.pl
#
#:# Usage:
#:#   perl extract_homgf.pl $(COMMON)/cat25.txt > gfsqrt1.tmp
#:#   $(RAMATH).sequence.JoeisPreparer -f         gfsqrt1.tmp
#--------------------------------------------------------------
use strict;
use integer;
use warnings;

my $line;
my $aseqno;
my $expr;
my $factor; # $factor/sqrt()
my $gftype; # "e" if e.g.f, "o" otherwise
my $callcode = "homgf";

while(<>) {
    # s{\s+\Z}{}; # chompr
    $line   = $_;
    $gftype = "o";
    if ($line =~ m{onject}) { # ignore
    #                              1        2                 3                          4                    5           
    } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+(Expansion of\s*)?([EO]\.)?[Gg]\.f\.\s*\:?\s*(A\([t-z]\)\s*\=\s*)?([^\.\,\;\=]+)}i) { 
        $aseqno  = $1;
        $gftype  = substr(lc($3 || "o"), 0, 1);
        $expr    = lc($5);
        if ($expr =~ m{sqrt[\(\[]|\^\(\-?\d+\/\d+\)}) {
            $expr =~ s{\s}{}g;
            # $expr =  lc($expr);
            $expr =~ s{(where|\-\_).*}{};
            my $ok = 1;
            foreach my $word ($expr =~ m{([a-z]\w+)}g) {
                if ($word ne 'sqrt') {
                    $ok = 0;
                }
            } # foreach $word
            if ($ok == 0) { # bad
            } elsif ($expr =~ m{[\~a-p]}) {
            } else {
                $expr =~ tr{\[\]\{\}}
                           {\(\)\(\)}; # egalize brackets
                $expr =~ s{sqrt}{\%}g;
                my %letters = ();
                foreach my $letter ($expr =~ m{([q-z])}g) {
                    $letters{$letter} = 1;
                }
                my $word = join("", sort(keys(%letters)));
                if (length($word) == 1) {
                    $expr =~ s{$word}{x}g;
                    my $sqno = ($expr =~ s{\%}{sqrt}g) || 0;
                    print join("\t", $aseqno, $callcode, 0, $expr, $gftype) . "\n";
                }
            }
        }
    }
} # while <>
__DATA__
