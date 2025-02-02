#!perl

# Convert from postfix to infix notation
# @(#) $Id$
# 2025-02-02, Georg Fischer: copied from ../gits/joeis-lite/internal/fischercr_infix.pl
#
#:# Usage:
#:#   perl postfix_infix.pl [-d debug] postfix_string 
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $mPrio = 0;
my %mPrioMap; # maps operators to a numerial priority
my $mPrimPrio; # priorit for primaries, higher than all others
my ($op1, $op2);
my @mStack = ();
my $mSep;

&assignPriorities();
my $expr = shift(@ARGV);
print &toInfix($expr) . "\n";

# Store priorities for various operators in the HashMap
sub setPrio {
    my @opers = @_;
    ++$mPrio;
    foreach my $oper (@opers) {
      $mPrioMap{$oper} = $mPrio;
    }
} # setPrio

# Store priorities for various operators in the HashMap
sub assignPriorities() { 
    $mPrio = 0;
    &setPrio("+", "-");
    &setPrio("*", "/");
    &setPrio("^");
    &setPrio("\'");
    &setPrio("~", "(", ")"); # unary minus
    $mPrimPrio = $mPrio + 1; # higher than all others
} # assignPriorities

# pop one element from the stack, and enclose it in parentheses depending on priorities
sub popElem {
    my ($tarPrio) = @_;
    my $elem = pop(@mStack);
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
    $mSep = substr($postfix, 0, 1);
    my @posts = split(/$mSep/, substr($postfix, 1));
    @mStack = ();
    foreach my $post (@posts) {
        my $prio = $mPrioMap{$post};
        if (defined($prio)) { # one of the binary arithmetic operators 
            $op2 = &popElem($prio);
            $op1 = &popElem($prio);
            push(@mStack, "$prio$mSep$op1$post$op2");
        } elsif ($post eq "A") { # the G.f. itself
            push(@mStack, "$mPrimPrio${mSep}A(x)");
        } elsif ($post eq "x") { # variable x
            push(@mStack, "$mPrimPrio${mSep}x");
        } elsif ($post =~ m{\A(\d+)\Z}) { # integer number
            push(@mStack, "$mPrimPrio${mSep}$1");
        } elsif ($post =~ m{\A\<(\d+)\Z}) { # shift -> multiply by power of x
            my $shift = $1;
            my $multPrio = $mPrioMap{"*"};
            $op1 = &popElem($multPrio);
            push(@mStack, "$multPrio${mSep}x" . ($shift == 1 ? "" : "\^$shift") . "*$op1");
        } elsif ($post =~ m{\A\^(\d*)\Z}) { # power, may with exponent in same element
            my $powPrio = $mPrioMap{"^"};
            if (length($post) == 1) {
                $op2 = &popElem($powPrio);
                $op1 = &popElem($powPrio);
            } else {
                $op2 = substr($post, 1);
                $post = substr($post, 0, 1);
                $op1 = &popElem($powPrio);
            }
            push(@mStack, "$powPrio${mSep}$op1" . ($op2 == 1 ? "" : "$post$op2"));
        } elsif ($post =~ m{\A([a-z]+)\Z}) { # function call exp, neg, int, rev etc.
            $op1 = &popElem($mPrimPrio + 1);
            push(@mStack, "$mPrimPrio$mSep$post$op1");
        } else {
            print "# undefined postfix element=\"$post\"\n";
        }
    } # foreach $post
    if (scalar(@mStack) != 1) {
        print "# stack not exhausted: " . join(" / ", @mStack) . "\n";
    }
    $mStack[0] =~ s{\A(\d+)$mSep}{}; # extract the priority
    return $mStack[0];
} # toInfix
#----
__DATA__
my $CRS = "REALS";
my %hash = 
    ( "arccos", "$CRS.acos"
    , "arcsin", "$CRS.asin"
    , "arctan", "$CRS.atan"
    , "arccot", "$CRS.acot"
    , "acos",   "$CRS.acos"
    , "asin",   "$CRS.asin"
    , "atan",   "$CRS.atan"
    , "acot",   "$CRS.acot"
    , "cosh",   "$CRS.cosh"
    , "sinh",   "$CRS.sinh"
    , "tan",    "$CRS.tan"
    , "tanh",   "$CRS.tanh"
    , "cot",    "$CRS.cot"
    , "coth",   "$CRS.coth"
    , "csc",    "$CRS.csc"
    , "sec",    "$CRS.sec"
    , "csch",   "$CRS.csch"

    , "omega",  "irvine.factor.factor.Jaguar.factor(mN).omega()" 
    , "phi",    "irvine.math.LongUtils.phi(mN)"
    , "sigma",  "irvine.factor.factor.Jaguar.factor(mN).sigma()"
    );

my @number_words = qw(ZERO ONE TWO THREE FOUR FIVE);  # SIX SEVEN EIGHT NINE TEN => undefined


my $line;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if ($line =~ m{\AA\d+\t}) { # starts with aseqno
        my ($aseqno, $callcode, $offset, $polys, $postfix, @rest) = split(/\t/, $line);
        my $callext = ""; # maybe "cr"
        my $s = substr($postfix, 0, 1); # first character is separator (";")
        # $postfix =~ s{\;2\;pi\;\*\;}{\;tau\;}g;
        # $postfix =~ s{\;sqrt\(\;2\;sqrt\)\;}{\;sqrt2\;}g;
        $postfix =~ s{\;1\;2\;\/\;}{\;half\;}g;
        $postfix =~ s{\;1\;3\;\/\;}{\;one_third\;}g;
        $postfix =~ s{\s+}{}g;
        $postfix = join($s, map {
            my $op = $_;
            if ($op =~ m{\A\d+\Z}) { # number
                if (length($op) >= 10) {
                    $op .= "L";
                }
            }
            $op
            } split(/$s/, $postfix));
        # $callcode = "dex_" might be changed to "dex_cr" (if ComputableReals must be included)
        @ops = split(/${s}/, substr($postfix, 1));
        @mStack = ();
        my $iop = 0;
        my $error = 0;
        while ($iop < scalar(@ops) and $error == 0) { 
            my $op = $ops[$iop]; 
            if (0) {
            } elsif ($op =~ m{\A(\d+L?)\Z}) { # number
                $op = "CR.valueOf($op)";
                push(@mStack, $op);
            } elsif ($op =~ m{\A(e|half|one_third|pi|sqrt2)\Z}i) { # named constant
                $op = "(CR." . uc($1) . ")";
                push(@mStack, $op);
            } elsif ($op =~ m{\A[a-z][a-z0-9]*\Z}) { # several letters variable name
                push(@mStack, $op);
            } elsif ($op =~ m{\A[a-z]\Z}) { # single letter variable name - cf. above
                push(@mStack, $op);
            } elsif ($op eq "+") { # +
                $op2 = pop(@mStack);
                $op1 = pop(@mStack);
                push(@mStack, "$op1.add($op2)");
            } elsif ($op eq "-.") { # unary -
                $op1 = pop(@mStack);
                push(@mStack, "$op1.negate()");
            } elsif ($op eq "-") { # -
                $op2 = pop(@mStack);
                $op1 = pop(@mStack);
                push(@mStack, "$op1.subtract($op2)");
            } elsif ($op eq "*") { # *
                $op2 = pop(@mStack);
                $op1 = pop(@mStack);
                push(@mStack, "$op1.multiply($op2)");
            } elsif ($op eq "/") { # /
                $op2 = pop(@mStack);
                $op1 = pop(@mStack);
                push(@mStack, "$op1.divide($op2)");
            } elsif ($op eq "^") { # ^
                $op2 = pop(@mStack);
                $op1 = pop(@mStack);
                if (0) {
                } elsif ($op2 eq "CR.TWO") {
                    push(@mStack, "$op1.multiply($op1)");
                } elsif ($op1 eq "CR.E") {
                    push(@mStack, "$op2.exp()");
                } else {
                    # ComputableReals.SINGLETON.pow(CR.FOUR, CR.THREE.inverse());
                    $callext = "cr";
                    push(@mStack, "$CRS.pow($op1,$op2)");
                }
            } elsif ($op =~ m{\(\Z}) { # start of function call
                # ignore
            } elsif ($op =~ m{\A(arcsin|arccos|arctan|sinh|cosh|tan|tanh|cot|coth|csc|sec|csch|sech)\)\Z}) { # end of function call
                $op = $1;
                $op1 = pop(@mStack);
                $callext = "cr";
                push(@mStack, "$hash{$op}($op1)");
            } elsif ($op =~ m{\A(sqrt|log|exp|sin|cos|abs|floor|ceil|round)\)\Z}) { # end of function call
                $op1 = pop(@mStack);
                $op =~ s{\)}{\(\)};
                push(@mStack, "$op1.$op");
            } elsif ($op =~ m{\A(zeta)\)\Z}) { # end of zeta call
                $op1 = pop(@mStack);
                if ($op1 =~ m{\ACR.valueOf\((\d+)\)\Z}) { # int parameter; 2nd would be precision?
                    $op1 = $1;
                    $callext = "cr";
                    push(@mStack, "Zeta.zeta($op1)");
                } else {
                    $op = "?4?";
                    $error = 1;
                }
            } elsif ($op =~ m{\A(gamma|eulergamma)\Z}) { # EulerGamma
                $callext = "cr";
                push(@mStack, "(EulerGamma.SINGLETON)");
            } elsif ($op =~ m{\A(log_?(\d+))\)\Z}) { # log_10, log_2 ...
                my $base = $2;
                $op1 = pop(@mStack);
                push(@mStack, "$op1.log().divide(CR.valueOf($base).log())");
            } else {
                $op1 = pop(@mStack) || "undef";
                if ($debug >= 1) {
                    print "# $aseqno ?1? op1=\"$op1\", op=\"$op\"\n";
                } 
                $op = "?1?";
                $iop = scalar(@ops); # break loop
                $error = 1;
            }
            $ops[$iop] = $op;
            $iop ++;
        } # while $iop
                
        my $result = "?5?";
        if ($base > 36) { # jOEIS DecimalExpansion restriction
            $result = "?2?";
        } elsif (scalar(@mStack) == 1 and $error == 0) {
            $result = pop(@mStack);
        } elsif (scalar(@ops) == 1) { 
            $result = "$ops[1]";
        } elsif (scalar(@ops) == 3) {
            $result = "($ops[0]$ops[2]$ops[1])";
        # A176534   dex 2   ;35;sqrt(;1295;sqrt);+;7;/  (35+sqrt(1295))/7
        } elsif ($postfix =~ m{\A\;(\d+L?)\;sqrt\(\;(\d+L?)\;sqrt\)\;\+\;(\d+L?)\;\/\Z}) {
            $result = "(CR.valueOf($1).add(CR.valueOf($2).sqrt())).divide(CR.valueOf($3))";
        # A176533   dex 2   ;15;4;sqrt(;15;sqrt);*;+;3;/    (15+4*sqrt(15))/3
        } elsif ($postfix =~ m{\A\;(\d+L?)\;(\d+L?)\;sqrt\(\;(\d+L?)\;sqrt\)\;\*\;\+\;(\d+L?)\;\/\Z}) {
            $result = "(CR.valueOf($1).add(CR.valueOf($2).multiply(CR.valueOf($3).sqrt()))).divide(CR.valueOf($4))";
        # A159811   dex 1   ;105507;65798;sqrt(;2;sqrt);*;+;223;2;^;/   (105507 + 65798*sqrt(2))/223^2
        } elsif ($postfix =~ m{\A\;(\d+L?);(\d+L?)\;sqrt\(\;(\d+L?)\;sqrt\)\;\*\;\+\;(\d+L?)\;2\;\^\;\/\Z}) {
            $result = "(CR.valueOf($1).add(CR.valueOf($2).multiply(CR.valueOf($3).sqrt()))).divide(CR.valueOf($4).multiply(CR.valueOf($4)))";
        } else {
            print "# $aseqno cr_infix: name=$name, ops=" . join(";", @ops) . ", stack=" . join(";", @mStack) . "\n";
            $result = "?3?";
        }
        if ($result !~ m{\?}) {
            $result =~ s{CR\.valueOf\(2\)\.sqrt\(\)}{CR\.SQRT2}g; # simplify sqrt(2)
            $result =~ s{CR\.valueOf\(([0-5])\)}{\(CR\.$number_words[$1]\)}g; # known number constants
            print join("\t", $aseqno, "$callcode$callext", $offset, $result, $keep0, $base, $name) . "\n";
        }
    } # if aseqno
} # while <>

#--------------------------------
__DATA__
A176533 dex 2   15,4,sqrt(),15,funct,*,+,3,/    (15+4*sqrt(15))/3
A176534 dex 2   35,sqrt(),1295,funct,+,7,/  (35+sqrt(1295))/7
A176535 dex 2   10,sqrt(),105,funct,+,2,/   (10 + sqrt(105))/2
A030644 dex 1   10,pi,- 10 - pi
A034948 dex 0   1,9801,/    1/9801
A036663 dex 0   1,98019801,/    1/98019801
A036664 dex 0   1,980198019801,/    1/980198019801
A036665 dex 0   1,9801980198019801,/    1/9801980198019801
A037222 dex 2   pi,e,2,^,*  pi*e^2
A037996 dex 2   pi,exp(),2,pi,*,pi,2,^,2,/,-,funct,*    pi*exp(2*pi-pi^2/2)
A040009 dex 0   pi,exp(),0,pi,2,^,2,/,-,funct,* pi*exp(-pi^2/2)
A049471 dex 1   tan(),1,funct   tan(1)
  