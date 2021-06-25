#!perl

# grep recurrences from APH's Maple programs
# @(#) $Id$
# 2021-06-13, Georg Fischer
#
#:# Usage:
#:#   grep -E "^%p" $(COMMON)/jcat25.txt \
#:#   | grep -P -A16 "a *\:\= *proc\(n\) *option *remember\; *\`if\` *\(n" \
#:#   | perl aphrec.pl > output.tmp
#---------------------------------
use strict;
use integer;
use warnings;

my $aseqno;
my $oseqno;
my $callcode;
my $offset;
my $poly;
my $line;
my $expr; 
my $rec;
my $cond;
my @inits;
my @factorials = (1,1,2,6,24,120,720,5040);

my $state = 0;
while(<>) {
    s{\s+\Z}{}; # chompr
    m{\A\%p (A\d+) (.*)};
    ($aseqno, $expr) = ($1 || "", $2 || "");
    if ($aseqno eq "") { 
        # ignore 
    } elsif ($state == 0) {
        if ($expr =~ m{a *\:\= *proc\(n\) *option *remember[\;\:] *(.*)}) {
            $rec    = $1;
            $state  = 1;
            $oseqno = $aseqno;
            $offset = 0;
            $callcode = "recur";
        }
    } elsif ($state == 1) {
        if (0) {
        } elsif ($aseqno ne $oseqno) {
            $state = 0;
        } elsif ($expr =~ m{\# _Alois P\.}) {
            if ($expr =~ m{seq\(a\(n\)\, *n *\= *(\d+)\.}) { # extract offset
                $offset = $1;
                &output();
            }
            $state = 0;
        } else {
            $rec =~ s{\s*end\s*[\:\;]\s*}{};
            $rec .= $expr;
        }
    }
} # while <>
#----
sub output {
    @inits = 1;
    $rec =~ s{\s*end\s*[\:\;]\s*}{};
    $rec =~ s{  +}{ }g; # keep 1 space only
    $rec =~ s{\A +}{}; # trim left
    my $nok = 0;
    if (0) {
    } elsif ($rec =~ m{local|add|mult|doublefactorial|tau|numbpart|sigma|padic|prime|pi|phi|fibonacci|signum|numtheory|combinat|parse}) {
        $nok = 1;
    } elsif ($rec =~ m{odd|ilog2|nops|ceil|floor|length|Bits|lcm|gcd|mod|signum|seq|max|min|iquo|irem|binomial}) {
        $nok = 2;
    } elsif ($rec =~ m{[bcRfgpst]\(}) {
        $nok = 3;
    } elsif ($rec =~ m{\>\>|\-\>|\%|a\(a}) {
        $nok = 4;
    }
    $rec =~ s{\s}{}g; # remove all spaces
    $rec =~ s{(\d+)\$(\d+)}{"$1," x $2}eg; # expand n$m notation
    $rec =~ s{\,([\,\]])}{$1}g;
    while ($rec =~ m{\$(\d+)\.\.(\d+)}) { # expand range $0..3 notation
        my ($start, $end) = ($1, $2);
        my $list = $start;
        while (++$start <= $end) {
            $list .= ",$start";
        }
        $rec =~ s{\$(\d+)\.\.$end}{$list};
    } # while range
    if ($rec !~ m{\`if\`\(n}) { # no initials
        $rec = "`if\`(n<$offset,0,$rec)";
    }
    if ($rec =~ m{\`if\`\(n\=(\d+)}) { # =above
        my $above = $1 + 1;
        $rec =~ s{\`if\`\(n\=(\d+)}{\`if\`\(n\<$above};
    }
    if ($rec =~ m{\`if\`\(n\<(\d+)\,(\d+)\,}) { # initial single value
        my $above = $1;
        my $value = $2;
        my $ind   = $offset;
        my $list  = $value;
        while (++$ind < $above) {
            $list .= ",$value";
        }
        $rec =~ s{\,$value\,}{\,\[$list\]\[n\+1]\,};
    } # initial single value
    if ($rec =~ m{\`if\`\(n\<(\d+)\,n\!\,}) { # initial factorials
        my $above = $1;
        my $ind = $offset;
        my $list = $factorials[$ind];
        while (++$ind < $above) {
            $list .= ",$factorials[$ind]";
        }
        $rec =~ s{\,n\!\,}{\,\[$list\]\[n\+1]\,};
    } # initial factorials
    if ($rec =~ m{\`if\`\(n\<(\d+)\,n\,}) { # initial numbers
        my $above = $1;
        my $ind = $offset;
        my $list = $ind;
        while (++$ind < $above) {
            $list .= ",$ind";
        }
        $rec =~ s{\,n\,}{\,\[$list\]\[n\+1]\,};
    } # initial numbers
    if ($rec =~ s{\`if\`\(n\<(\d+)\,\[([\,\d\-]+)\]\[n\+1\]\,}{}) { # [list][n+1],
        my $list = $2;
        @inits = split(/\,/, $list);
        splice(@inits, 0, $offset);
        $rec =~ s{\)\s*\Z}{}; # remove last ")"
        $callcode = "holos";
        if ($rec =~ s{\/([n\(\)\+\-\*\^\d]+)\Z}{}) {
            $rec = "-a(n)*$1+$rec";
        } else {
            $rec = "-a(n)+$rec";
        }
    }
    
    if ($nok == 0) {
        print        join("\t", $aseqno, $callcode, $offset, $rec, join(",", @inits), 0, 0, "Recurrence $rec") . "\n";
    } else {
        print STDERR join("\t", $aseqno, "rec$nok", $offset, $rec, join(",", @inits), 0, 0, "$rec") . "\n";
    }
} # output
__DATA__
--
%p A076042 a:= proc(n) option remember; `if`(n<0, 0,
%p A076042       ((s, t)-> s+`if`(s<t, t, -t))(a(n-1), n^2))
%p A076042     end:
%p A076042 seq(a(n), n=0..70);  # _Alois P. Heinz_, Jan 11 2020
%p A076079 1,seq(floor(evalf(ithprime(n)/n,100))*n,n=2..200);
--
%p A078509 a:= proc(n) option remember; `if`(n<4, 1,
%p A078509       (n-1)*a(n-1) +(n-3)*a(n-2) +a(n-3))
%p A078509     end:
%p A078509 seq(a(n), n=0..30);  # _Alois P. Heinz_, Jan 10 2014
%p A078521 # The function BellMatrix is defined in A264428.
--
%p A081798 a:= proc(n) option remember; `if`(n<3, 51*n^2-45*n+1,
%p A081798      ((3*n-2)*(30*n^2-50*n+13)*a(n-1)+(3*n-1)*(n-2)^2*a(n-3)
%p A081798      -(9*n^3-30*n^2+29*n-6)*a(n-2))/(n^2*(3*n-4)))
%p A081798     end:
%p A081798 seq(a(n), n=0..20); # _Alois P. Heinz_, Sep 22 2013

A071798 holos   1   `if`(n<3,(n-1)*n,n*((3*n^2-7*n+3)*a(n-1)-(2*n-3)*(n-1)^3*a(n-2))/(n-2)) [1] 0   0   Maple Recurrence `if`(n<3,(n-1)*n,n*((3*n^2-7*n+3)*a(n-1)-(2*n-3)*(n-1)^3*a(n-2))/(n-2))
A071896 holos   1   `if`(n<0,0,`if`(n=0,1,n*(n+1)/2*a(n-1)+a(n-2))) [1] 0   0   Maple Recurrence `if`(n<0,0,`if`(n=0,1,n*(n+1)/2*a(n-1)+a(n-2)))
A071917 holos   1   `if`(n=0,0,a(n-1)+pi(2*n-1)-pi(n))  [1] 0   0   Maple Recurrence `if`(n=0,0,a(n-1)+pi(2*n-1)-pi(n))
A072132 holos   1   `if`(n<4,n!,(-147456*(n+4)*(n-1)^2*(n-2)^2*(n-3)^2*a(n-4)+128*(33876+30709*n+6687*n^2+410*n^3)*(n-1)^2*(n-2)^2*a(n-3)-4*(1092*n^5+37140*n^4+455667*n^3+2387171*n^2+4649270*n+1206000)*(n-1)^2*a(n-2)+(-17075520+(22488312+(29223280+(10509820+(1764252+(154164+(6804+120*n)*n)*n)*n)*n)*n)*n)*a(n-1))/((n+16)*(n+7)^2*(n+15)^2*(n+12)^2))   [1] 0   0   Maple Recurrence `if`(n<4,n!,(-147456*(n+4)*(n-1)^2*(n-2)^2*(n-3)^2*a(n-4)+128*(33876+30709*n+6687*n^2+410*n^3)*(n-1)^2*(n-2)^2*a(n-3)-4*(1092*n^5+37140*n^4+455667*n^3+2387171*n^2+4649270*n+1206000)*(n-1)^2*a(n-2)+(-17075520+(22488312+(29223280+(10509820+(1764252+(154164+(6804+120*n)*n)*n)*n)*n)*n)*n)*a(n-1))/((n+16)*(n+7)^2*(n+15)^2*(n+12)^2))
A072133 holos   0   `if`(n<5,n!,((-1110790863+(1520978576+(1772290401+(607308786+(101671498+(9464664+(500874+(14124+165*n)*n)*n)*n)*n)*n)*n)*n)*a(n-1)-(1129886062*n+559908333*n^2+111239576*n^3+10655238*n^4+8778*n^6+491700*n^5+353895381)*(n-1)^2*a(n-2)+(258011271+234066216*n+58221266*n^2+5463876*n^3+172810*n^4)*(n-1)^2*(n-2)^2*a(n-3)-9*(4070430+1504292*n+117469*n^2)*(n-1)^2*(n-2)^2*(n-3)^2*a(n-4)+893025*(n-1)^2*(n-2)^2*(n-3)^2*(n-4)^2*a(n-5))/((n+20)^2*(n+8)^2*(n+18)^2*(n+14)^2)) [1] 0   0   Maple Recurrence `if`(n<5,n!,((-1110790863+(1520978576+(1772290401+(607308786+(101671498+(9464664+(500874+(14124+165*n)*n)*n)*n)*n)*n)*n)*n)*a(n-1)-(1129886062*n+559908333*n^2+111239576*n^3+10655238*n^4+8778*n^6+491700*n^5+353895381)*(n-1)^2*a(n-2)+(258011271+234066216*n+58221266*n^2+5463876*n^3+172810*n^4)*(n-1)^2*(n-2)^2*a(n-3)-9*(4070430+1504292*n+117469*n^2)*(n-1)^2*(n-2)^2*(n-3)^2*a(n-4)+893025*(n-1)^2*(n-2)^2*(n-3)^2*(n-4)^2*a(n-5))/((n+20)^2*(n+8)^2*(n+18)^2*(n+14)^2))
A076042 holos   0   `if`(n<0,0,((s,t)->s+`if`(s<t,t,-t))(a(n-1),n^2))   [1] 0   0   Maple Recurrence `if`(n<0,0,((s,t)->s+`if`(s<t,t,-t))(a(n-1),n^2))
A078509 holos   0   `if`(n<4,1,(n-1)*a(n-1)+(n-3)*a(n-2)+a(n-3))    [1] 0   0   Maple Recurrence `if`(n<4,1,(n-1)*a(n-1)+(n-3)*a(n-2)+a(n-3))
A081798 holos   0   `if`(n<3,51*n^2-45*n+1,((3*n-2)*(30*n^2-50*n+13)*a(n-1)+(3*n-1)*(n-2)^2*a(n-3)-(9*n^3-30*n^2+29*n-6)*a(n-2))/(n^2*(3*n-4))) [1] 0   0   Maple Recurrence `if`(n<3,51*n^2-45*n+1,((3*n-2)*(30*n^2-50*n+13)*a(n-1)+(3*n-1)*(n-2)^2*a(n-3)-(9*n^3-30*n^2+29*n-6)*a(n-2))/(n^2*(3*n-4)))
A092186 holos   0   `if`(n<2,2-n,(n*(3*n-1)*(n-1)*a(n-2)-4*a(n-1))/(12*n-16))   [1] 0   0   Maple Recurrence `if`(n<2,2-n,(n*(3*n-1)*(n-1)*a(n-2)-4*a(n-1))/(12*n-16))
A101292 holos   0   `if`(n<3,[1,2,5][n+1],((11*n^2+10*n-70)*a(n-1)-(34*n^2-81*n+60)*a(n-2)+(23*n-10)*(n-2)*a(n-3))/(11*n-24))   [1] 0   0   Maple Recurrence `if`(n<3,[1,2,5][n+1],((11*n^2+10*n-70)*a(n-1)-(34*n^2-81*n+60)*a(n-2)+(23*n-10)*(n-2)*a(n-3))/(11*n-24))
