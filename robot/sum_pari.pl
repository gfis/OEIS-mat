#!perl

# Extract sums with binomial|stirling
# @(#) $Id$
# 2023-08-20, Georg Fischer
#
#:# Usage:
#:#   perl sum_pari.pl input.cat25-type > sumbin.gen
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

my ($aseqno, $callcode, $offset1, $name, $form, $prefix, $nok);
my @parms;
$callcode = "sumbin";
$offset1 = 0;
my $line;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $nok = 0;
    my ($aseqno, $name) = split(/ /, $line, 2);
    $name =~ s{\(PARI[^\)]*\)}{}; # e.g. %o A248705 (PARI: For b-file)
    if ($name =~ m{polcoeff|numerator|denominator}) {
        next;
    }
    #                          1     1     2  2
    if ($name =~ m{a\(n\) *\= *([^s]*)sum\((.*)}) {
        $prefix = $1 || "";
        $form = $2;
        if ($debug >= 2) {
            print "# aseqno=$aseqno, name=$name\n";
        }
        $form =~ s/[ \{\}]//g; 	# spaces and surrounding "{" ... "}"
        $form =~ s/\;.*//;      # end of statement
        $form =~ s/\\\\.*//;    # comment with "\\" at the end
        $form =~ s/\\/\//g;     # "\" -> "/", integer division
        $form =~ s/\) *\Z//;    # trailing ")" of "sum("
    } else {
        $nok = 1;
    }
    
    my @dummy = map { 
        if (! m{binomial|stirling|abs|gcd}) { 
            $nok = "2/$_"; 
        }
        $_
        } ($form =~ m{([A-Za-z]\w+)}g);
    if ($form =~ m{binomial}) {
        if ($form =~ m{stirling}) {
            $callcode = "sumbist";
        } else {
            $callcode = "sumbin";
        }
    } else {
        $callcode = "sumstir";
    }
    
    my ($var, $max, $cont) = split(/\,/, $form, 3);
    my ($expr, $list) = ($cont, ""); # remaining expression, extracted variables
    my $ivar = 0;
    my ($a, $b, $c, $x, $y, $z);
    #          1     12         2    3         34      45         5
    $expr =~ s{([^\-])([a-z]|\d+)\*\(([a-z]|\d+)([\+\-])([a-z]|\d+)\)} {$1$2\*$3$4$2\*$5}g;	# (k*(n-3) -> (k*n-k*3
    #          1    12         2    3         34      45         5
    $expr =~ s{([\-])([a-z]|\d+)\*\(([a-z]|\d+)([\+\-])([a-z]|\d+)\)}  {"$1$2\*" . (($3 eq "+") ? "-" : "+") . "$4$2\*$5"}eg;	# -k*(n-3) -> -k*n+k*3
    #                           1                         1  2                     2
    while ($expr =~ m{binomial\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)} ) { # binomial(a,b)
        $a = $1;
        $b = $2;
        $x = "V" . ($ivar ++);
        $y = "V" . ($ivar ++);
        $expr    =~ s{binomial\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)} {BIN\($x\,$y\)};
        $list   .= "$x=$a;$y=$b;";
    } # while
    #                           1                         1  2                     2
    while ($expr =~ m{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)} ) { # stirling(a,b)
        $a = $1;
        $b = $2;
        $x = "V" . ($ivar ++);
        $y = "V" . ($ivar ++);
        $expr    =~ s{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%]+)\)} {STIR1\($x\,$y\)};
        $list   .= "$x=$a;$y=$b;";
    } # while
    #                           1                         1  2                     2      3    3
    while ($expr =~ m{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%\(\)]+)\,([12])\)} ) { # stirling(a,b,{1|2})
        $a = $1;
        $b = $2;
        $c = $3;
        $x = "V" . ($ivar ++);
        $y = "V" . ($ivar ++);
        $expr    =~ s{stirling\(([a-z0-9\+\-\*\^\/\%\(\)]+)\,([a-z0-9\+\-\*\^\/\%\(\)]+)\,([12])\)} {STIR$c\($x\,$y\)};
        $list   .= "$x=$a;$y=$b;";
    } # while
    #                          1                                  1
    while ($expr =~ m{\(\-1\)\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))} ) { # (-1)^k
        $a = $1;
        $b = $2;
        $x = "V" . ($ivar ++);
        $expr    =~ s{\(\-1\)\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))} {POW_1\($x\)};
        $list   .= "$x=$a;";
    } # while
    #                    1                                   1
    while ($expr =~ m{2\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))}       ) { # 2^k
        $a = $1;
        $b = $2;
        $x = "V" . ($ivar ++);
        $expr    =~ s{2\^([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))}       {POW2\($x\)};
        $list   .= "$x=$a;";
    } # while
    #                 1                                   1
    while ($expr =~ m{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\!}        ) { # k!
        $a = $1;
        $b = $2;
        $x = "V" . ($ivar ++);
        $expr    =~ s{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\!}        {FACTORIAL\($x\)};
        $list   .= "$x=$a;";
    } # while
    #                 1                                   1  2                                  2
    while ($expr =~ m{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\^([a-z0-9]|\([a-z0-9\+\-\*\^\/\%]+\))}  ) { # (n-k)^(3*k) 
        $a = $1;
        $b = $2;
        $x = "V" . ($ivar ++);
        $expr    =~ s{([a-z]|\d+|\([a-z0-9\+\-\*\^\/\%]+\))\^([a-z0-9]|\([a-z0-9\+\-\*\^\/\%]+\))}  {POW(VAL($x),$y)};
        $list   .= "$x=$a;";
    } # while
    #               1                 1
    $expr =~ s{abs\((STIR\d\(V\d,V\d\))\)} {A$1}g; # abs(STIRi(V0,V1)) -> ASTIRi(V0,V1)

    @parms = ();
    push(@parms, $expr, $list, $var, $max, $prefix);
    $name =~ s{binomial}{binom}g;
    $name =~ s{stirling}{stirl}g;

    if ($nok eq "0") {
        print        join("\t", $aseqno, $callcode, 0,         @parms, $name) . "\n";
    } else {
        print STDERR join("\t", $aseqno, $callcode, "nok$nok", $form , $name) . "\n";
    }
} # while <>
#--------------------------------------------
__DATA__
A357394	a(n)=sum(k=1,n,(2*n)^(k-1)*stirling(n,k,2))
A357334	a(n)=sum(k=1,n,(3*k)^(k-1)*abs(stirling(n,k,1)))
A357338	a(n)=sum(k=1,n,(3*k)^(k-1)*stirling(n,k,1))
