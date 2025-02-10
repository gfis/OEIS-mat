#!perl

# Grep (differential) equations of the form "A(x)^d = ..." and prepare them for "jprep -cc post"
# @(#) $Id$
# 2025-02-10, Georg Fischer: copied from satis.pl
#
#:# Usage:
#:#   grep -P "A\(x\)(\^\d+)? *\=" $(COMMON)/jcat25.txt | grep -P "^\%[NF]" \
#:#   | perl polyx.pl > (aseqno, ~~expr)
#---------------------------------
use strict;
use integer;
use warnings;

my $aseqno;
my $poly;
my $line;
my $expr; 
my $expon;
my $rest;
my $gfType;

while(<>) {
    s{\.\s*\Z}   {}; # chompr
    s{\. \- _.*} {}; # remove author
    $line = $_;
    if (0) {
    #                         1     1       2  2
    } elsif ($line =~ m{A\(x\)(\^\d+)? *\= *(.*)}) {
        $expon = $1 || "^1";
        $expr = $2;
        if ($line =~ m{\A\%[NF] (A\d+)}) {
            $aseqno = $1;
        }
        $gfType = "o";
        if ($line =~ m{e\.g\.f\.}i) {
            $gfType = "e";
        }
        $expr =~ s{with A\(\d\).*}{}; # remove initial terms
        $expr =~ s{A\'\(x\)}{dif\(A\(x\)\)}g; # derivative
        if ($expr =~ s{Integral}{int\(}i) {
            $expr =~ s{dx}{\)}g;
        }
        $expr =~ s{ }{}g; # remove spaces
        $expr =~ tr{\[\]}  # MMA
                   {\(\)}; # -> normal brackets
        $expr =~ s{Series[_\-]Reversion}  {rev}ig;
        $expr =~ s{d\/dx}                 {dif}ig;
        if (defined($expr) && length($expr) >= 4) {
            print join("\t", $aseqno, "polyx", 0, ";$expr", $expon, $gfType, $expr) . "\n";
        }
    }
} # while <>
#----
__DATA__
sub polish {
    my ($gf, $expr) = @_;
    my ($gf1, $gf2) = ("A", "\QA(x)\E"); # default
    if ($gf =~ m{\=}) { # "G.f. A = A(x) satis...
        ($gf1, $gf2) = split(/\=\:?/, $gf);
    } else { # no "G.f. A(x) :"
        if ($expr =~ m{\A([^\=]+)\=}) { # part before 1st "(" in expression
            $gf2 = $1;
            if ($gf2 =~ m{\A([^\(]+)}) { # part before "("
                $gf1 = $1;
            } else {
                $gf1 = "$1(x)";
            }
            # before 1st "("
        } # else take default
    } # no g.f.
    if ($gf1 =~ m{\(}) { # exchange, normalize to A = A(x)
        my $temp = $gf1; $gf1 = $gf2; $gf2 = $temp;
    }
    # $gf1 =~ s{([\(\)])}{\\$1}g;
    # $gf2 =~ s{([\(\)])}{\\$1}g;
    # $expr = "\Q$expr\E";
    $expr =~ s{\Q$gf1\E([^\(])}{\Q$gf2\E$1}g; # replace all A with A(x)
    $expr =~ s{\\}{}g;

    if ($expr =~ m{\A[Aygxtuq0-9\(\)\-\+\*\/\^\=]+\Z}) { # arithmetic expressions
        #          1         2
        $expr =~ s{([a-zA])\(([a-z])\)}{A\[$2\]}g;
        if ($expr =~ m{[a-zA]\(}) {
            $expr = "??1 $expr"; # void
        } else { 
            # make annihilator, imply ... = 0
            if (0) {
            } elsif ($expr =~ s{\A0\=}     {}         ) { # done
            } elsif ($expr =~ s{\=0\Z}     {}         ) { # done
            } elsif ($expr =~ s{\A([^\+\-]+)\=}{-$1\+}) { 
            } else {
                # $expr =~ s{\A}{#?? };
                $expr = "??2 $expr";  # void
            }
        }
    } else {
        $expr = "??3 $expr"; # void
    }
    $expr =~ tr{\[\]}{\(\)};
    $expr =~ s{A\(x\)}{A}g;
    $expr =~ s{(\d|\))([A-Za-z])}{$1\*$2}g;
    $expr =~ s{\+\-}{\-}g;
    if ($expr =~ m{y}) {
        $expr = "";
    }
    return $expr;
} # polish

