#!perl

# Grep PARI equations and prepare them for the polyx chain
# @(#) $Id$
# 2025-02-14, Georg Fischer: copied from polyx_prep.pl
#
#:# Usage:
#:#   perl gpoly_prep.pl input.cat25 > output.seq4
#---------------------------------
use strict;
use integer;
use warnings;

my $line;
my $aseqno;
my $oseqno = "A000000"; # old, for a group of A-numbers
my $offset1 = 0;
my $formula;
my $oldform;
my $polys; 
my $expon = "^1";
my $gfType;
my $nok = "";
my @parts; # separated by ";"

while(<>) {
    s{\s*\Z}{}; # chompr
    $line = $_;
    $nok = "";
    ($aseqno, $formula) = split(/\t/, $line);
    $formula =~ s{ }{}g; # remove spaces
    if ($formula !~ m{\+x\*O\(x\^n\)}g) {
        $nok = "no_xO(n)";
    } else {
        $formula =~ s{\+x\*O\(x\^n\)}{}; # remove O(n)
        @parts = split(/\;/, $formula);
        if (scalar(@parts) != 3) {
            $nok = "#parts<>3";
        } else {
            $gfType  =  ($parts[2] =~ m{n\! *\* *polcoeff}) ? 1 : 0;
            $polys   =  &get_poly($parts[0]);
            $formula =  $parts[1];
            #                           1   1   2         2
            if ($formula =~ s{for\(\w+\=(\d+)\,n([\+\-]\d+)?\,A\=}{}) {
                $offset1 = $1;
            }
            $oldform =  $formula;
            $formula =~ s{\)\Z}{}; # remove trailing ")" of "for("
            $formula =~ s{(\, )?(with|where|for) .*}{};   # remove initial terms and conditions
            $formula =~ s{A\'\(x\)}{dif\(A\(x\)\)}g; # derivative A'(x)
            $formula =~ s{A\'\(}{difA\(}g;           # derivative A'(...
            
            $formula =~ s{subst\(A\,x\,}         {A\(}g;
            $formula =~ s{intformal}             {int}g;
            $formula =~ s{(Series[_\-])?Reversion|serreverse}{rev}ig;
            $formula =~ s{deriv}                 {dif}ig;
            $formula =~ s{LambertW}              {lambertW}ig;
            $formula =~ s{AGM}                   {agm}ig;
            $formula =~ s{Sqrt}                  {sqrt}ig;
            $formula =~ s{arc(sin|cos|tan)}      {a$1}ig;
            $formula =~ s{^A\=}                  {}; # when formula contains no A

            $formula =~ s{A\'\(}                 {\#\'\(}g;   # shield A'(
            $formula =~   s{A\(}                   {\#\(}g;   # shield A(

            $formula =~ s{A}                     {A\(x\)}g;

            $formula =~ s{#\'\(}                 {A\'\(}g;    # unshield A(
            $formula =~   s{#\(}                   {A\(}g;    # unshield A(
            if ($formula =~ m{subst\(}) {
                $nok = "subst";
            }
            if ($formula =~ m{\Wn\W}) {
                $nok = "var_n";
            }
        }
    }
    if (length($nok) == 0) {
        print        join("\t", $aseqno, "polyx", $offset1, ";$formula", $expon, $gfType, $oldform, $polys, $parts[0]) . "\n";
    } else {
        print STDERR join("\t", $aseqno, "$nok" , $offset1, ";$formula", $expon, $gfType, $oldform, $polys, $parts[0]) . "\n";
    }
} # while <>
#----
sub get_poly {
    my ($polstr) = @_; # = $parms[0], e.g. "(A=x+x^2)"
    my $max_exp = 0;
    my @polys = (0);
    #                   (A1 =2               23      3 1  )
    if ($polstr =~ m{\A\(A(\=([0-9x\+\-\*\^]+)(\,X\=x)?)?\)\Z}) {
        $polstr = $2 || 0;
        foreach my $elem (split(/([\+\-])/, $polstr)) { # include the separators
            my $factor = 1;
            my $sign   = 1;
            my $iexp   = 0;
            if (0) { # the separators
            } elsif ($elem eq "+") {
                $sign  = 1;
            } elsif ($elem eq "-") {
                $sign  = -1;
            } else { # the powewrs of x
                if (0) {
                } elsif ($elem eq "x") {
                    $factor= 1;
                    $iexp  = 1;
                } else {
                    if ($elem =~ s{\A(\d+)\*?}{}) {
                        $factor = $1;
                        # $iexp may be 0
                    }
                    if ($elem !~ m{x}) {
                        $iexp = 0;
                    #                      1 ^2   21
                    } elsif ($elem =~ m{\Ax(\^(\d+))?\Z}) {
                        $iexp = $2 || 1;
                    } else {
                        $nok = "$elem?1";
                    }
                }
                while (scalar(@polys) <= $iexp) {
                    push(@polys, 0);
                }
                $polys[$iexp] = $sign * $factor;
                if ($iexp > $max_exp) {
                    $max_exp = $iexp;
                }
            } # endif
        } # foreach summand
        @polys = splice(@polys, 0, $max_exp + 1);
    } else {
        # print STDERR "# nopoly: $polstr\n";
        # $nok = "nopoly";
    }
    return "[" . join(",", @polys) . "]";
} # get_poly
__DATA__
A168479	(A=1+x);for(i=1,n,A=(1+A*serreverse(x/(A+x*O(x^n))))^3);polcoeff(A,n)}
A168653	(A=1+x);for(i=1,n,A=1+A^3*serreverse(x*(A+x*O(x^n))));polcoeff(A,n)}
A171214	(A=x+x^2);for(i=1,n,A=x+x*subst(A,x,subst(A,x,x/3+O(x^n))));3^(n*(n-1)/2)*polcoeff(A,n)}
A171454	(A=1+x+x*O(x^n));for(i=1,n,A=1+4*x*agm(1,A^2));polcoeff(A,n)}
A171455	(A=1+x+x*O(x^n));for(i=1,n,A=1+2*x*agm(1,A^4));polcoeff(A,n)}
A171792	(A=x+x^2);for(i=1,n*(n+1)/2,A=(x+subst(A,x,x+x^2+x*O(x^n)))/2);ceil(polcoeff(A,n))}
A177406	(A=x+x^2);for(i=1,n,A=x+subst(A,x,27*(A+x*O(x^n))^6)^(1/3));polcoeff(A,n)}
A177408	(A=x+x^2);for(i=1,n,A=x+subst(A,x,4*(A+x*O(x^n))^4)^(1/2));polcoeff(A,n)}
A179486	(A=x+x^3);for(i=0,n,A=serreverse(x-subst(A,x,x^3+x^2*O(x^(2*n)))));polcoeff(A,2*n-1)}
A179487	(A=x+x^3);for(i=0,n,A=serreverse(x-subst(A,x,x^3+x^2*O(x^(2*n)))));polcoeff(A^3,2*n-1)}
A183607	(A=1+x);for(i=1,n,A=1/(1-x-x*deriv(x^2*A'/(A+x*O(x^n)))));polcoeff(A,n)}
A184506	(A=1+x+x*O(x^n));for(i=1,n,A=1+1/x*serreverse(x/A)*serreverse(x*A)+x*O(x^n));polcoeff(A,n)}
A184509	(A=1+x+x*O(x^n));for(i=1,n,A=1+x*serreverse(x/A)/serreverse(x*A)+x*O(x^n));polcoeff(A,n)}
A185753	(A=x+x^2);for(i=1,n,A=2*A-x-(x/serreverse(A+x^2*O(x^n))-1)^2);polcoeff(x/serreverse(A+x^2*O(x^n)),n)}
A185754	(A=x+x^2);for(i=1,n,A=2*A-x-(x/serreverse(A+x*O(x^n))-1)^2);polcoeff(A,n)}
A187814	(A=1+x+x*O(x^n));for(i=1,n,A=1/(1/subst(A,x,x^2)+2*x*subst(A,x,x^2)-4*x*A^2+x*O(x^n))^(1/2));polcoeff(A,n)}
A189897	(A=1+x);for(i=1,n,A=exp(x*(n-i+1)*A+x*O(x^n)));n!*polcoeff(exp(x*A),n)}
A191557	(A=x+x^2+x*O(x^n));for(i=1,n,A=A-(subst(A,x,A)-x*sqrt(1+4*A^3/x^2))/2);polcoeff(A,n)}
A191565	(A=x+x^2+x*O(x^n));for(i=1,n,A=A-(subst(A,x,A)-x*sqrt(4*x+A^2/x^2)));polcoeff(A,n)}
A193098	(A=x);for(i=1,n,A=intformal(1+subst(A,x,subst(A,x,A+O(x^(n+1))))));n!*polcoeff(A,n)}
