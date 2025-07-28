#!perl

# Convert from postfix to infix notation
# @(#) $Id$ 
# 2025-07-26: /b
# 2025-07-14: polys, legendreP; *CZ=73
# 2025-06-15: .* = dot product, hadamardMultiply; more parentheses
# 2025-06-10: negative integers and shifts, pow
# 2025-06-08: additional o.g.f.s referenced by B,C,D,E (preferred); *FP=11 
# 2025-05-29: besselI(0,x)
# 2025-05-11: additional o.g.f.s referenced by S, T, U, V
# 2025-05-03: additional o.g.f.s referenced by s0, s1 ... 
# 2025-03-07: operand n
# 2025-02-15: /(op2); *BirgitW=80
# 2025-02-06: remove leading unary "+"
# 2025-02-02, Georg Fischer: copied from ../gits/joeis-lite/internal/fischercr_infix.pl
#
#:# Usage:
#:#   perl postfix_infix.pl [-d debug] postfix_string
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
my $fileName = "";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{f}) {
        $fileName  = $opt;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my %mPrioMap; # maps operators to a numerial priority
my $mPrimPrio; # priority for primaries, higher than all others
my $mPrio = 0;
&assignPriorities();
my ($op1, $op2);
my @mStack;
my @mPolys;
my @mAnums;
my $mSep;

if (length($fileName) == 0) { # 1 or 2 arguments
    my  $postfix;
    my  $polstr  = shift(@ARGV);
    if ($polstr !~ m{\A\[}) {
        $postfix = $polstr;
        $polstr  = "[[1]]";
    } else {
        $postfix = shift(@ARGV);
    }
    $mSep   = ($postfix =~ m{^\W}) ? substr($postfix, 0, 1) : ",";
    @mPolys = &expand_polys($polstr);
    foreach (my $poli = 0; $poli < scalar(@mPolys); $poli ++) { 
        my $temp = $mPolys[$poli];
        $temp =~ s{\A(\d+)\,(.*)}{$2 prio=$1}; 
        print "p$poli = $temp\n";
    }
    print join(",", &toInfix($postfix)) . "\n";
} else { # read from seq4 file
    my $line;
    # while (<DATA>) {
    while (<>) {
        $line = $_;
        $line =~ s/\s+\Z//; # chompr
        if ($line =~ m{\AA\d+\tpoly}) { # starts with aseqno, polx...
            my ($aseqno, $callcode, $offset, $polstr, $postfix, @rest) = split(/\t/, $line);
            $polstr  =~ s{\"}{}g;
            $postfix =~ s{\"}{}g;
            $mSep   = ($postfix =~ m{^\W}) ? substr($postfix, 0, 1) : ",";
            @mPolys  = &expand_polys($polstr);
            $polstr  = &toInfix($postfix);
            print join("\t", $aseqno, $callcode, $offset, "\"$polstr\"", "\"$postfix\"", @rest) . "\n";
        } else {
            print "$line\n";
        }
    } # while <>
} # from seq4 file
# end main
#--------
# Set one priority for a list of operators in the HashMap
sub setPrio {
    my @opers = @_;
    ++$mPrio;
    foreach my $oper (@opers) {
      $mPrioMap{$oper} = $mPrio;
    }
} # setPrio

# Store various priorities for operator lists in the HashMap
sub assignPriorities() {
    $mPrio = 0;
    &setPrio("+", "-");
    &setPrio("*", "/", ".*", "./", "*n", "/n", "^n");
    &setPrio("^", ".^");
    &setPrio("\'");
    &setPrio("~", "(", ")"); # unary minus
    $mPrimPrio = $mPrio + 1; # higher than all other priorities
} # assignPriorities

# pop one element from the stack, and enclose it in parentheses depending on priorities
sub popElem {
    my ($tarPrio) = @_;
    my $elem = pop(@mStack);
    #            1   1
    $elem =~ s{\A(\d+)$mSep}{}; # extract the priority
    my $srcPrio = $1;
    if ($srcPrio < $tarPrio) {
        $elem = "($elem)";
    }
    return $elem;
} # popElem

# convert to infix notation
sub toInfix {
    my ($postfix) = @_;
    &assignPriorities();
    my @posts;
    if ($postfix =~ m{^\W}) {
        $mSep = substr($postfix, 0, 1);
        @posts = split(/$mSep/, substr($postfix, 1));
    } else {
        $mSep = ",";
        @posts = split(/$mSep/, $postfix);
    }
    @mStack = ();
    foreach my $post (@posts) {
        my $prio = $mPrioMap{$post};

        if (0) {
        } elsif ($post =~ m{\A\/\Z}) {                # /op2 => /(op2)
            $op2 = &popElem($prio + 1);
            $op1 = &popElem($prio);
            if ($post =~ m{\A[\+\-]\Z}) {
                $post = " $post ";
            }
            push(@mStack, "$prio${mSep}$op1$post$op2");
        } elsif (defined($prio)) {                    # one of the binary arithmetic operators + - * / ^ .* ./
            $op2 = &popElem($prio);
            $op1 = &popElem($prio);
            if ($post =~ m{\A[\+\-]\Z}) {
                $post = " $post ";
            }
            push(@mStack, "$prio${mSep}$op1$post$op2");
        } elsif ($post =~ m{\AA\Z}) {                 # the target g.f. A(x)
            push(@mStack, "$mPrimPrio${mSep}A(x)");   
        } elsif ($post =~ m{\An\Z}) {                 # variable n
            push(@mStack, "$mPrimPrio${mSep}n");      
        } elsif ($post =~ m{\Ax\Z}) {                 # variable x
            push(@mStack, "$mPrimPrio${mSep}x");      
        } elsif ($post =~ m{\Ap(\d+)\Z}) {            # polynomial p0, p1 ...
            push(@mStack, "($mPolys[$1])");           
        } elsif ($post =~ m{\A(\-?\d+)\Z}) {          # integer number 1, 2, -2 ...
            my $int = $1;
            push(@mStack, "$mPrimPrio${mSep}" . (($int =~ m{\A\-}) ? "($int)" : $int));

        } elsif ($post =~ m{\A\<(\-?\d+)\Z}) {        # <shift -> multiply by power of x
            my $shift = $1;
            my $multPrio = $mPrioMap{"*"};
            $op1 = &popElem($multPrio);
            if ($shift < 0) {
                $shift = "($shift)"; # () if negative 
            }
            push(@mStack, "$multPrio${mSep}x" . ($shift eq "1" ? "" : "\^$shift") . "*$op1");

        } elsif ($post =~ m{\A\>(\-?\d+)\Z}) {        # >shift -> divide by power of x
            my $shift = -($1);
            my $multPrio = $mPrioMap{"*"};
            $op1 = &popElem($multPrio);
            if ($shift < 0) {
                $shift = "($shift)"; # () if negative 
            }
            push(@mStack, "$multPrio${mSep}x" . ($shift eq "1" ? "" : "\^$shift") . "*$op1");

        } elsif ($post =~ m{\A\^(\d+(\/\d+)?)?\Z})  { # power, maybe with (rational) exponent in same element
            my $powPrio = $mPrioMap{"^"};
            if (length($post) == 1) {
                $op2 = &popElem($powPrio);
                $op1 = &popElem($powPrio);
            } else {
                $op2  = substr($post, 1);
                if ($op2 =~ m{\/}) { # rational
                    $op2 = "($op2)";
                }
                $post = substr($post, 0, 1);
                $op1  = &popElem($powPrio);
            }
            push(@mStack, "$powPrio${mSep}$op1" . ($op2 eq "1" ? "" : "$post$op2"));

        } elsif ($post =~ m{\A(agm|besselI|legendreP|pow)\Z}) { # function calls with 2 operands: agm, besselI, pow
            $op2 = &popElem($mPrimPrio + 1);
            $op1 = &popElem($mPrimPrio + 1);
            push(@mStack, "$mPrimPrio${mSep}$post($op1, $op2)");

        } elsif ($post =~ m{\A([a-z][a-zA-Z]+|[\*\/]n\!|[\*\/\^]n)\Z}) {  # function calls exp, neg, int, rev, lambertW etc., *n!, /n!, ,*n, /n, ^n
            if (0) {
            } elsif ($post eq "rev") {
                $post = "reverse";
            } elsif ($post eq "int") {
                $post = "integral";
            }
            $op1 = &popElem($mPrimPrio + 1);
            if (0) {
            } elsif ($post eq "dif") {
                if ($op1 eq "(A(x))") {
                    push(@mStack, "$mPrimPrio${mSep}A\'\(x\)");
                } else {
                    push(@mStack, "$mPrimPrio${mSep}$op1\'");
                }
            } elsif ($post eq "neg") {
                push(@mStack, "$mPrimPrio${mSep}-$op1");
            } elsif ($post eq "sub") {
                push(@mStack, "$mPrimPrio${mSep}A$op1");
            } elsif ($post eq "*n!") {
                push(@mStack, "$mPrimPrio${mSep}$op1*n!");
            } elsif ($post eq "/n!") {
                push(@mStack, "$mPrimPrio${mSep}$op1/n!");
            } else {
                push(@mStack, "$mPrimPrio${mSep}$post$op1");
            }

        } elsif ($post =~ m{\A[BCDESTUV]\Z}) {        # g.f.s. of additional source sequences
            $op1 = &popElem($mPrimPrio + 1);
            push(@mStack, "$mPrimPrio${mSep}$post$op1");

        } else {
            print "# undefined postfix element=\"$post\"\n";
        }
    } # foreach $post
    if (scalar(@mStack) != 1) {
        print "# stack not exhausted: " . join(" / ", @mStack) . "\n";
    }
    $mStack[0] =~ s{\A(\d+)${mSep}}{}; # extract the priority
    return $mStack[0];
} # toInfix

# expand the polynomials
sub expand_polys {
    my ($matrix) = @_;
    my @polys = ();
    $matrix =~ s{ }{}g; # remove spaces
    $matrix =~ s{\A[\'\"]?\[+}{}; # remove surrounding quotes and square brackets
    $matrix =~ s{\]+[\'\"]?\Z}{};
    $matrix =~ s{\]*\,?(A\d.+)}{}; # extract/remove any list of additional o.g.f.s
    my $ogflist = $1 || "";
    @mAnums = split(/\,/, $ogflist);
    for (my $iseq = 0; $iseq < scalar(@mAnums); $iseq ++) {
        print chr(ord('S') + $iseq) . " = $mAnums[$iseq]\n";
    }
    my @plists = split(/\]\,\[/, $matrix);
    foreach my $plist (@plists) {
        my @factors = split(/\,/, $plist);
        my $result = "";
        my $prio = $mPrimPrio; # for a number or a single "x"
        my $sumLen = 0;
        for (my $expon = 0; $expon < scalar(@factors); $expon ++) {
            my $fact = $factors[$expon];
            if ($fact ne 0) { # contributes to the polynomial in x
                $sumLen ++;
                if ($fact !~ m{\A\-}) {
                    $fact = "+$fact";
                }
                if (0) {
                } elsif ($expon == 0) {
                    $result .= $fact;
                } else {
                    if (abs($fact) == 1) {
                        $result .= substr($fact, 0, 1) . "x";
                    } else {
                        $result .= "$fact*x";
                        $prio = $mPrioMap{"*"};
                    }
                    if ($expon >= 2) {
                        $result .= "^$expon";
                        $prio = $mPrioMap{"*"};
                    }
                } # >= 2
            } # facvt != 0
        } # for $expon
        if ($sumLen >= 2) { # several summands
            $prio = $mPrioMap{"+"};
        }
        $result =~ s{\A\+}{}; # remove leading unary "+"
        push(@polys, "$prio${mSep}$result");
    } # foreach $plist
    return @polys;
} # expand_polys
#--------------------------------
__DATA__
A100615 polyx 0 "[[1],[0,1]]" ",p1,p1,exp,p0,-,/,^2"  1 1 E.g.f.: (x/(exp(x)-1))^2
A174512 poly  0 "[[1],[0,0,1]]" ",p1,sub,^2,p1,sub,^3,<1,+" G.f. satisfies: A(x) = A(x^2)^2 + x*A(x^2)^3.
A174513 poly  0 "[[1],[0,0,1]]" ",p1,sub,^2,p1,sub,^4,<1,+" G.f. satisfies: A(x) = A(x^2)^2 + x*A(x^2)^4.
A183036 poly  0 "[[1],[1,0,-1],[1,-1],[0,0,1],[0,0,0,0,1]]" ",p1,p2,^2,/,p3,sub,^2,*,p4,sub,/"  G.f. satisfies: A(x) = (1-x^2)/(1-x)^2 * A(x^2)^2/A(x^4).
A183038 poly  0 "[[1],[1,0,0,-1],[1,-1],[0,0,0,1],[0,0,0,0,0,0,0,0,0,1]]" ",p1,p2,^3,/,p3,sub,^2,*,p4,sub,/"  G.f. satisfies: A(x) = (1-x^3)/(1-x)^3 * A(x^3)^2/A(x^9).
A195200 poly  0 "[[1],[0,0,1]]" ",p1,sub,^3,p1,sub,^2,<1,+" G.f. satisfies: A(x) = A(x^2)^3 + x*A(x^2)^2.
A213091 poly  0 "[[1]]" ",1,x,A,^2,<1,neg,sub,/,+"  G.f. satisfies: A(x) = 1 + x/A(-x*A(x)^2).
A213092 poly  0 "[[1]]" ",1,x,A,^3,<1,neg,sub,/,+"  G.f. satisfies: A(x) = 1 + x/A(-x*A(x)^3).
A213093 poly  0 "[[1]]" ",1,x,A,^4,<1,neg,sub,/,+"  G.f. satisfies: A(x) = 1 + x/A(-x*A(x)^4).
A215114 poly  1 "[[0,1],[0,1,2]]" ",p1,A,sub,sub,<1,+"  G.f. satisfies: A(x) = x + 2*x^2 + x*A(A(A(x))).
A215116 poly  1 "[[0,1],[0,1,3]]" ",p1,A,sub,sub,sub,<1,+"  G.f. satisfies: A(x) = x + 3*x^2 + x*A(A(A(A(x)))).
A215118 poly  1 "[[0,1],[0,1,4]]" ",p1,A,sub,sub,sub,sub,<1,+"  G.f. satisfies: A(x) = x + 4*x^2 + x*A(A(A(A(A(x))))).
A223026 poly  0 "[[1],[0,0,1],[0,8]]" ",p1,sub,^4,p2,+,^1/8"  G.f. satisfies: A(x)^8 = A(x^2)^4 + 8*x.
A223142 poly  0 "[[1],[0,0,1],[0,4]]" ",p1,sub,^2,p2,+,^1/2"  G.f. satisfies: A(x)^2 = A(x^2)^2 + 4*x.
A223143 poly  0 "[[1],[0,0,1],[0,9]]" ",p1,sub,^3,p2,+,^1/3"  G.f. satisfies: A(x)^3 = A(x^2)^3 + 9*x.
