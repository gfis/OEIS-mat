#!perl

# Extract expressions with binomial|stirling
# Superceedes sum_pari.pl !
# @(#) $Id$
# 2023-08-28: seq4 input format
# 2023-08-21, Georg Fischer
#
#:# Usage:
#:#   perl expr_pari.pl input.seq4 > output.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my %zops = 
  ( "+", ".add("
  , "-", ".subtract("
  , "*", ".multiply("
  , "/", ".divide("
  );
my %znames = (0, "Z.ZERO", 1, "Z.ONE", 2, "Z.TWO"  , 3, "Z.THREE", 4, "Z.FOUR"
             ,5, "Z.FIVE", 6, "Z.SIX", 7, "Z.SEVEN", 8, "Z.EIGHT", 9, "Z.NINE", 10, "Z.TEN", -1
             , "Z.NEG_ONE");
my ($aseqno, $callcode, $offset1, $name, $form, $prefix, $nok);
my ($expr, $list);
my @parms;
$callcode = "lambda";
my $max_ivar = 0; # maximum of $ivar below
my $ivar; # generate variable names V{ivar}_
$offset1 = 0;
my $line;
my $func1_pattern = qr/abs|bell|bigomega|core|eulerphi|fibonacci|floor|gpf|hammingweight|lpf|moebius|numdiv|prime|primepi|omega|rad|sign|sqrtint/;
my $func2_pattern = qr/bitand|bitxor|gcd|kronecker|log|logint|lcm|max|min|[Mm]od|sigma|sqrtn|sqrtnint|valuation/;

while (<>) {
    $line = $_;
    if ($debug >= 3) {
        print "# line=$line";
    }
    $line =~ s/\s+\Z//; # chompr
    $nok = 0;
    ($aseqno, $callcode, $offset1, $name) = split(/\t/, $line);
    if ($debug >= 1) {
        print "# aseqno=$aseqno, name=$name\n";
    }
    $name =~ s{\(PARI[^\)]*\) *}{}; # e.g. "A248705 (PARI: For b-file)"
    $name =~ s/[\{\}]//g; # remove any  "{" ... "}"
    $name =~ s{\A +}{}; # remove leading spaces
    #                             1  1
    if ($name =~ m{^ *(a|$aseqno)\(n\) *\= *(.*)}i) {
        $form = $2;
        $form =~ s/[ \{\}]//g;  # spaces and
        $form =~ s/\;.*//;      # end of statement
        $form =~ s/\\\\.*//;    # end-of-line comment with "\\" at the end
        $name =~ s/\\\\.*//;    # same with original line
        $form =~ s/\/\*.*//;    # C-style comment with "/*" - ignore the rest
        $name =~ s/\/\*.*//;    # same with original line
        # $form =~ s/\\\\/\//g;     # "\" -> "/", integer division
        if ($debug >= 2) {
            print "# aseqno=$aseqno, form=$form\n";
        }
    } else {
        # $nok = 1;
        next;
    }

    my @dummy = map {
        if (! m{$func1_pattern|$func2_pattern|binomial|if|prod|stirling\d?|Stirling2|sum|[a-z]\d+}i) {
            $nok = "2/$_";
        }
        $_
        } ($form =~ m{([A-Za-z]\w+)}g);

    $expr = $form;
    if ($expr =~ m{(\ba\([a-z]\))}) {
        $nok = "4/$1";
    }
    $list = "";
    $ivar = 0; # cf. above, $max_ivar
    my ($a, $b, $c, $x, $y, $z);
    my $loop_check;

    # substitute "*()", "^2", sum
    #            1     1
    $expr =~ s{\b([a-z])\^2\b}{$1\*$1}g;                                  # k^2 -> k*k
    #            1         1    2         23      34         4
    $expr =~ s{\(([a-z]|\d+)\*\(([a-z]|\d+)([\+\-])([a-z]|\d+)\)\)}                                 {\($1\*$2$3$1\*$4\)}g; # (k*(n-3)) -> (k*n-k*3)
    #             1    12         2    3         34      45         5
#   $expr =~    s{([\-])([a-z]|\d+)\*\(([a-z]|\d+)([\+\-])([a-z]|\d+)\)}                            {"$1$2\*" . (($3 eq "+") ? "-" : "+") . "$4$2\*$5"}eg; # -k*(n-3) -> -k*n+k*3
    #               1 (           )1  
    $expr =~ s{floor(\([a-z]+\/\w+\))}                                                              {$1}g;
    #               1 ( ( a + b          ) / d  )1
    $expr =~ s{floor(\(\([a-z0-9\+\-\*]+\)\/\d+\))}                                                 {$1}g;

    if (1) { # noloop
        # "if" must first be tested
        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                    (1      1  2   2  3  3
               $expr =~ m{if\(([^\,]+)\,(\d+)\,(.*)}                                                )) { # if(n<=2,0,...
            $a = $1;
            $b = $2;
            $c = $3;
            $x = &newvar();
            $y = &newvar();
            $expr    =~ s{if\(([^\,]+)\,([^\,]+)\,(.*)}                                             {IF\($x\,Z\.valueOf\($y\)\,$c}i; # assume that the closing ")" is at the end
            &append($x, $a);
            &append($y, $b);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check IF: expr=$expr, list=$list\n";
        }
    
        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                 prod (1   1 =2      2 ,3      3 ,
               $expr =~ m{prod\((\w+)\=([^\,]+)\,([^\,]+)\,}i                                       )) { # "prod(k=0,n,"  -> "INTPROD(0,n,k,"
            $a = $1;
            $b = $2;
            $c = $3;
            $x = &newvar();
            $y = &newvar();
            $z = &newvar();
            #             prod (1   1 =2      2 ,3      3 ,
            $expr    =~ s{prod\((\w+)\=([^\,]+)\,([^\,]+)\,}                                        {INTPROD\($x\,$y\,$z\,}i;
            if ($debug >= 2) {
                print "# aseqno=$aseqno $x=$b $y=$c $z=$a expr=$expr\n";
            }
            &append($x, $b);
            &append($y, $c);
            &append($z, $a);  # move the lambda variable behind!
        } # while
        if ($loop_check <= 0) {
            print "# loop_check INTPROD: expr=$expr, list=$list\n";
        }

        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                   sum (1   1 =2      2 ,3      3 ,
               $expr =~ m{\bsum\((\w+)\=([^\,]+)\,([^\,]+)\,}i                                     )) { # "sum(k=0,n,"  -> "INTSUM(0,n,k,"
            $a = $1;
            $b = $2;
            $c = $3;
            $x = &newvar();
            $y = &newvar();
            $z = &newvar();
            #             sum (1      1 =2      2 ,3      3 ,
            $expr    =~ s{sum\((\w+)\=([^\,]+)\,([^\,]+)\,}                                        {INTSUM\($x\,$y\,$z\,}i;
            if ($debug >= 2) {
                print "# aseqno=$aseqno $x=$b $y=$c $z=$a expr=$expr\n";
            }
            &append($x, $b);
            &append($y, $c);
            &append($z, $a);  # move the lambda variable behind!
        } # while
        if ($loop_check <= 0) {
            print "# loop_check INTSUM: expr=$expr, list=$list\n";
        }

        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                 sumdiv (1      1 ,2      2 ,
               $expr =~ m{sumdiv\(([^\,]+)\,([^\,]+)\,}i                                            )) { # "sumdiv(n,d, "  -> "SUMDIV(x,y,"
            $a = $1;
            $b = $2;
            $x = &newvar();
            $y = &newvar();
            $expr    =~ s{sumdiv\(([^\,]+)\,([^\,]+)\,}                                             {DIVSUM\($x\,$y\,}i;
            &append($x, $a);
            &append($y, $b);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check SUMDIV: expr=$expr, list=$list\n";
        }
    
        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                 1              1 (2                     2 )
               $expr =~ m{($func1_pattern)\(([a-z0-9\+\-\*\^\/\%]+)\)}                              )) { # bell(k)
            $a = $2;
            $x = &newvar();
            $expr    =~ s{($func1_pattern)\(([a-z0-9\+\-\*\^\/\%]+)\)}                              {$1\($x\)};
            &append($x, $a);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check func1: expr=$expr, list=$list\n";
        }

        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                  1             1  2                         2  3                     3
               $expr =~ m{($func2_pattern)\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)} )) { # gcd(a,b)
            $a = $2;
            $b = $3;
            $x = &newvar();
            $y = &newvar();
            $expr    =~ s{($func2_pattern)\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)} {$1\($x\,$y\)};
            &append($x, $a);
            &append($y, $b);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check func2: expr=$expr, list=$list\n";
        }

        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                          (1                         1 ,2                     2 )
               $expr =~ m{binomial\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}i        )) { # binomial(a,b)
            $a = $1;
            $b = $2;
            $x = &newvar();
            $y = &newvar();
            $expr    =~ s{binomial\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}         {BIN\($x\,$y\)}i;
            &append($x, $a);
            &append($y, $b);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check BIN: expr=$expr, list=$list\n";
        }

        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                           1                         1  2                     2
               $expr =~ m{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}i        )) { # stirling(a,b)
            $a = $1;
            $b = $2;
            $x = &newvar();
            $y = &newvar();
            $expr    =~ s{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}         {STIR1\($x\,$y\)}i;
            &append($x, $a);
            &append($y, $b);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check STIR1: expr=$expr, list=$list\n";
        }

        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                            1                         1  2                     2
               $expr =~ m{Stirling2\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}i       )) { # Stirling2(a,b)
            $a = $1;
            $b = $2;
            $x = &newvar();
            $y = &newvar();
            $expr    =~ s{Stirling2\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}        {STIR2\($x\,$y\)}i;
            &append($x, $a);
            &append($y, $b);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check STIR2: expr=$expr, list=$list\n";
        }

        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                           1                         1  2                     2      3    3
               $expr =~ m{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%\(\)]+)\,([12])\)}i )) { # stirling(a,b,{1|2})
            $a = $1;
            $b = $2;
            $c = $3;
            $x = &newvar();
            $y = &newvar();
            $expr    =~ s{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%\(\)]+)\,([12])\)} {STIR$c\($x\,$y\)}i;
            &append($x, $a);
            &append($y, $b);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check STIRc: expr=$expr, list=$list\n";
        }
    
        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                          1                                  1
               $expr =~ m{\(\-1\)\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))}                           )) { # (-1)^x
            $a = $1;
            $x = &newvar();
            $expr    =~ s{\(\-1\)\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))}                           {POW_1\($x\)};
            &append($x, $a);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check POW_1: expr=$expr, list=$list\n";
        }

        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                         1                                   1
               $expr =~      m{2\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))}                            )) { # 2^x
            $a = $1;
            $x = &newvar();
            $expr    =~      s{2\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))}                            {POW2\($x\)};
            &append($x, $a);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check POW2: expr=$expr, list=$list\n";
        }

        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                         1                                   1
               $expr =~         m{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\!}                          )) { # x!
            $a = $1;
            $b = $2;
            $x = &newvar();
            $expr    =~         s{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\!}                          {FACTORIAL\($x\)};
            &append($x, $a);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check FACTORIAL: expr=$expr, list=$list\n";
        }

        $loop_check = 16;
        while (-- $loop_check >= 0 and (
        #                        1                                   1  2                                  2         x   x y   y
               $expr =~        m{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\^([a-z0-9]|\([a-z0-9\+\-\*\^\/\%]+\))}  )) { # (n-k)^(3*k)
            $a = $1;
            $b = $2;
            $x = &newvar();
            $y = &newvar();
            $expr    =~        s{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\^([a-z0-9]|\([a-z0-9\+\-\*\^\/\%]+\))}  {POW(VALOF($x),$y)};
            &append($x, $a);
            &append($y, $b);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check POW: expr=$expr, list=$list\n";
        }
    
        $loop_check = 16;
        while (-- $loop_check >= 0 and (
               #            1                     1
               $expr =~ m{\(([a-z0-9\+\-\*\^\/\%]+)\)}                                              )) { # (n-3*k+17)
            $a = $1;
            $x = &newvar();
            $expr    =~ s{\(([a-z0-9\+\-\*\^\/\%]+)\)}                                              {VALOF($x)};
            &append($x, $a);
        } # while
        if ($loop_check <= 0) {
            print "# loop_check VALOF: expr=$expr, list=$list\n";
        }
    
    } # if noloop
    @parms = ();
    push(@parms, $expr, $list);
    $name =~ s{binomial}{binom}g;
    $name =~ s{stirling}{stirl}g;
    if ($ivar > $max_ivar) {
        $max_ivar = $ivar;
    }

    if ($nok eq "0") {
        print        join("\t", $aseqno, $callcode, 0,         @parms, $name) . "\n";
    } else {
        print STDERR join("\t", $aseqno, $callcode, "nok$nok", $form , $name) . "\n";
    }
} # while <>
print "# max_ivar = $max_ivar\n";
#----
sub newvar {
    $ivar ++;
    return "V$ivar" . "V";
} # newvar
#----
sub append {
    my ($var, $value) = @_;
    if ($value !~ m{\)[\*\/\^]}) { # no inner ")op("
        $value =~ s{\A\((.*)\)\Z}                                                               {$1}; # (...) not necessary
    }
    #           1              1
    $value =~ s{(\(\w[\+\-]\w\))\^2}                                                            {$1\*$1}g; # avoid "^"
    #                                              1     1   1                     1
    $value =~                                 s{2\^([a-z]|\d+|\([a-z0-9\+\-\*\/]+\))}           {Z\.ONE\.shiftLeft\($1\)}g; # 2^k
    #           1     1   1 (                  )1 ^2     2   2 (                  )2
    $value =~ s{([a-z]|\d+|\([a-z0-9\+\-\*\/]+\))\^([a-z]|\d+|\([a-z0-9\+\-\*\/]+\))}           {Z\.valueOf\($1\)\.pow\($2\)}g; # 3^k
    if ($value !~ m{[\w\+\-\*\/]+\Z}) { # no trailing ")"
        #           )1     12             2
        $value =~ s{([\+\-])([\w\+\-\*\/]+)\Z}                                                  {($1 eq "+") ? "\.add\($2\)" : "\.add\(\-$2\)"}e; # ")-n-1+k" -> ").add(-n-1+k)"
    }
    if ($value =~ m{Z\.}) {
        #            1                    1   2  2
        $value =~ s{^([a-z0-9\+\-\*\/\(\)])Z\.(.*)}                                             {"Z.valueOf(" . substr($1, 0, length($1) - 1) . ")" . $zops{substr($1, -1)} . "Z.$2)"}e; 
        $value =~ s{([^\+])\+(.*)}                                                              {$1\.add\($2\)};
        $value =~ s{([^\-])\-(.*)}                                                              {$1\.subtract\($2\)};
        $value =~ s{([^\*])\*(.*)}                                                              {$1\.multiply\($2\)};
    }
    $value =~ s{([a-z0-9]+)\.}                                                                  {Z\.valueOf\($1\)\.}g;  # int expr before ".Z-op"
    if ($value =~ m{\/}) {
        # $nok = "3//x";
    }
    $list .= "$var=$value;"
} # append
#--------------------------------------------
__DATA__
A357394 a(n)=sum(k=1,n,(2*n)^(k-1)*stirling(n,k,2))
A357334 a(n)=sum(k=1,n,(3*k)^(k-1)*abs(stirling(n,k,1)))
A357338 a(n)=sum(k=1,n,(3*k)^(k-1)*stirling(n,k,1))
