#!perl

# Extract expressions with binomial|stirling
# Superceedes sum_pari.pl !
# @(#) $Id$
# 2023-08-21, Georg Fischer
#
#:# Usage:
#:#   perl expr_pari.pl input.cat25-type > output.seq4
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
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $nok = 0;
    ($aseqno, $name) = split(/ /, $line, 2);
    $name =~ s{\(PARI[^\)]*\)}{}; # e.g. %o A248705 (PARI: For b-file)
    if ($name =~ m{polcoeff}) {
        next;
    }
    $name =~ s/[\{\}]//g; # remove any surrounding "{" ... "}"
    $name =~ s{\A +}{}; # remove leading spaces
    #                          1  1
    if ($name =~ m{^ *a\(n\) *\= *(.*)}) {
        $form = $1;
        if ($debug >= 2) {
            print "# aseqno=$aseqno, name=$name\n";
        }
        $form =~ s/[ \{\}]//g;  # spaces and
        $form =~ s/\;.*//;      # end of statement
        $form =~ s/\\\\.*//;    # end-of-line comment with "\\" at the end
        $name =~ s/\\\\.*//;    # same with original line
        $form =~ s/\/\*.*//;    # C-style comment with "/*" - ignore the rest
        $name =~ s/\/\*.*//;    # same with original line
        $form =~ s/\\/\//g;     # "\" -> "/", integer division
    } else {
        # $nok = 1;
        next;
    }

    my @dummy = map {
        if (! m{abs|bell|binomial|floor|gcd|if|lcm|stirling|Stirling2|sum}i) {
            $nok = "2/$_";
        }
        $_
        } ($form =~ m{([A-Za-z]\w+)}g);

    $expr = $form;
    if ($expr =~ m{(a\([a-z]\))}) {
        $nok = "4/$1";
    }
    $list = "";
    $ivar = 0; # cf. above, $max_ivar
    my ($a, $b, $c, $x, $y, $z);

    # substitute "*()", "^2", sum
    #            1     1
    $expr =~ s{\b([a-z])\^2\b}{$1\*$1}g;                                  # k^2 -> k*k
    #            1         1    2         23      34         4
    $expr =~ s{\(([a-z]|\d+)\*\(([a-z]|\d+)([\+\-])([a-z]|\d+)\)\)}
        {\($1\*$2$3$1\*$4\)}g;                                            # (k*(n-3)) -> (k*n-k*3)
    #             1    12         2    3         34      45         5
#   $expr =~    s{([\-])([a-z]|\d+)\*\(([a-z]|\d+)([\+\-])([a-z]|\d+)\)}
#       {"$1$2\*" . (($3 eq "+") ? "-" : "+") . "$4$2\*$5"}eg;            # -k*(n-3) -> -k*n+k*3
    #               1 (           )1  
    $expr =~ s{floor(\([a-z]+\/\w+\))}
        {$1}g;
    #               1 ( ( a + b          ) / d  )1
    $expr =~ s{floor(\(\([a-z0-9\+\-\*]+\)\/\d+\))}
        {$1}g;

    # "if" must first be tested
    #                    (1      1  2   2  3  3
    while ($expr =~ m{if\(([^\,]+)\,(\d+)\,(.*)}                                                ) { # if(n<=2,0,...
        $a = $1;
        $b = $2;
        $c = $3;
        $x = &newvar();
        $y = &newvar();
        $expr    =~ s{if\(([^\,]+)\,(\d+)\,(.*)}                                                {IF\($x\,Z\.valueOf\($y\)\,$c}; # assume that the closing ")" is at the end
        &append($x, $a);
        &append($y, $b);
    } # while
    #                           1                       1
    while ($expr =~     m{bell\(([a-z0-9\+\-\*\^\/\%]+)\)}                                      ) { # bell(k)
        $a = $1;
        $x = &newvar();
        $expr    =~     s{bell\(([a-z0-9\+\-\*\^\/\%]+)\)}                                      {BELL\($x\)};
        &append($x, $a);
    } # while
    while ($expr =~ m{binomial\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}         ) { # binomial(a,b)
        $a = $1;
        $b = $2;
        $x = &newvar();
        $y = &newvar();
        $expr    =~ s{binomial\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}         {BIN\($x\,$y\)};
        &append($x, $a);
        &append($y, $b);
    } # while
    #                           1                         1  2                     2
    while ($expr =~ m{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}         ) { # stirling(a,b)
        $a = $1;
        $b = $2;
        $x = &newvar();
        $y = &newvar();
        $expr    =~ s{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}         {STIR1\($x\,$y\)};
        &append($x, $a);
        &append($y, $b);
    } # while
    #                            1                         1  2                     2
    while ($expr =~ m{Stirling2\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}i       ) { # Stirling2(a,b)
        $a = $1;
        $b = $2;
        $x = &newvar();
        $y = &newvar();
        $expr    =~ s{Stirling2\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)}        {STIR2\($x\,$y\)}i;
        &append($x, $a);
        &append($y, $b);
    } # while
    #                           1                         1  2                     2      3    3
    while ($expr =~ m{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%\(\)]+)\,([12])\)} ) { # stirling(a,b,{1|2})
        $a = $1;
        $b = $2;
        $c = $3;
        $x = &newvar();
        $y = &newvar();
        $expr    =~ s{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%\(\)]+)\,([12])\)} {STIR$c\($x\,$y\)};
        &append($x, $a);
        &append($y, $b);
    } # while
    #                   sum (1      1 =2      2 ,3      3 ,
    while ($expr =~ m{\bsum\(([a-z]+)\=([^\,]+)\,([^\,]+)\,}                                    ) { # "sum(k=0,n,"  -> "INTSUM(0,n,k,"
        $a = $1;
        $b = $2;
        $c = $3;
        $x = &newvar();
        $y = &newvar();
        $z = &newvar();
        #             sum (1      1 =2      2 ,3      3 ,
        $expr    =~ s{sum\(([a-z]+)\=([^\,]+)\,([^\,]+)\,}                                      {INTSUM\($x\,$y\,$z\,};
        if ($debug >= 2) {
            print "# aseqno=$aseqno $x=$b $y=$c $z=$a expr=$expr\n";
        }
        &append($x, $b);
        &append($y, $c);
        &append($z, $a);  # move the lambda variable behind!
    } # while
    #                 sumdiv (1      1 ,2      2 ,
    while ($expr =~ m{sumdiv\(([^\,]+)\,([^\,]+)\,}                                             ) { # "sumdiv(n,d, "  -> "SUMDIV(x,y,"
        $a = $1;
        $b = $2;
        $x = &newvar();
        $y = &newvar();
        $expr    =~ s{sumdiv\(([^\,]+)\,([^\,]+)\,}                                             {SUMDIV\($x\,$y\,};
        &append($x, $a);
        &append($y, $b);
    } # while

    #                          1                                  1
    while ($expr =~ m{\(\-1\)\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))}                           ) { # (-1)^x
        $a = $1;
        $x = &newvar();
        $expr    =~ s{\(\-1\)\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))}                           {POW_1\($x\)};
        &append($x, $a);
    } # while
    #                         1                                   1
    while ($expr =~      m{2\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))}                            ) { # 2^x
        $a = $1;
        $x = &newvar();
        $expr    =~      s{2\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))}                            {POW2\($x\)};
        &append($x, $a);
    } # while
    #                         1                                   1
    while ($expr =~         m{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\!}                          ) { # x!
        $a = $1;
        $b = $2;
        $x = &newvar();
        $expr    =~         s{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\!}                          {FACTORIAL\($x\)};
        &append($x, $a);
    } # while
    #                        1                                   1  2                                  2         x   x y   y
    while ($expr =~        m{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\^([a-z0-9]|\([a-z0-9\+\-\*\^\/\%]+\))}  ) { # (n-k)^(3*k)
        $a = $1;
        $b = $2;
        $x = &newvar();
        $y = &newvar();
        $expr    =~        s{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\^([a-z0-9]|\([a-z0-9\+\-\*\^\/\%]+\))}  {POW(VALOF($x),$y)};
        &append($x, $a);
        &append($y, $b);
    } # while
    my $loop_check = 16;
    while (-- $loop_check >= 0 and (
           #            1                     1
           $expr =~ m{\(([a-z0-9\+\-\*\^\/\%]+)\)}                    )                         ) { # (n-3*k+17)
        $a = $1;
        $x = &newvar();
        $expr    =~ s{\(([a-z0-9\+\-\*\^\/\%]+)\)}                                              {VALOF($x)};
        &append($x, $a);
    } # while
    if ($loop_check <= 0) {
        print "# loop_check: expr=$expr, list=$list\n";
    }
    $expr =~ s{\A(\-?[a-z]|\-?\d+)}                                                             {VALOF\($1\)};  # int at the beginning of the expr
    #          1     1  2               2
    $expr =~ s{(\A|\W)\((\-?[a-z]|\-?\d+)}                                                      {$1\(VALOF\($2\)}g; # "(int"

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
    if ($value !~ m{\)\Z}) { # no trailing ")"
        #            )1      12                 2
        $value =~ s{\)([\+\-])([a-z0-9\+\-\*\/]+)\Z}                                            {\)\.add\($2\)}; # ")-n-1+k" -> ").add(-n-1+k)"
    }
    if ($value =~ m{Z\.}) {
        #            1                    1   2  2
        $value =~ s{^([a-z0-9\+\-\*\/\(\)])Z\.(.*)}                                             {"Z.valueOf(" . substr($1, 0, length($1) - 1) . ")" . $zops{substr($1, -1)} . "Z.$2)"}e; 
        $value =~ s{([^\+])\+(.*)}                                                              {$1\.add\($2\)};
        $value =~ s{([^\-])\-(.*)}                                                              {$1\.subtract\($2\)};
        $value =~ s{([^\*])\*(.*)}                                                              {$1\.multiply\($2\)};
    }
    $value =~ s{([a-z0-9]+)\.}                                                                  {Z\.valueOf\($1\)\.}g;  # int expr before ".Z-op"
    if ($value =~ m{1\/}) {
        $nok = "3/1/x";
    }
    $list .= "$var=$value;"
} # append
#--------------------------------------------
__DATA__
A357394 a(n)=sum(k=1,n,(2*n)^(k-1)*stirling(n,k,2))
A357334 a(n)=sum(k=1,n,(3*k)^(k-1)*abs(stirling(n,k,1)))
A357338 a(n)=sum(k=1,n,(3*k)^(k-1)*stirling(n,k,1))
