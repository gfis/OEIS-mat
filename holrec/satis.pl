#!perl

# Grep (differential) equations of the form "satis.* (\w*) ."
# @(#) $Id$
# 2020-10-21: new attempt
# 2020-01-08, Georg Fischer
#
#:# Usage:
#:#   perl satis.pl $(COMMON)/cat25.txt > $@.tmp
#---------------------------------
use strict;
use integer;
use warnings;

my $aseqno;
my $poly;
my $line;
my $expr; 
my $rest;
my $gf;

while(<>) {
    s{\s+\Z}{}; # chompr
    $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    if (0) {
    } elsif ($line =~ m{\.\.\.}) { # ignore ellipsis
    #                              1        2                  3
    } elsif ($line =~ m{\A\%[NF]\s+(A\d+)\s+([^s]*)satis\w+\:? ([^\.]+)\.}) { 
        $aseqno = $1;
        $gf     = $2 || "";
        $rest   = $3;
        $expr   = $rest;
        $expr   =~ s{ }{}g;
        $gf     =~ s{(O\.g\.|G\.)f\.[ \:]*}{};
        $gf     =~ s{ }{}g;
        # $expr    =~ s{\,.*}{};
        if (0) {
        } elsif ($expr =~ m{[a-z][a-z0-9]}i) { # no where, for, all, sum, prod, no ellipsis
        } elsif ($expr =~ m{[\'\_\,\;]}) { # no derivatives yet, no underscores, A[x,y] etc.
        } else {
            $expr = &polish($gf, $expr);
            if ($expr ne "") {
                print join("\t", $aseqno, "satis", 0, $expr, "", "", substr($line, 11)) . "\n";
            }
        }
    }
} # while <>
#----
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
    return $expr;
} # polish
__DATA__
