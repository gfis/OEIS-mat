#!perl
# Polish formualae for floor|ceil|roudn|frac
# @(#) $Id$
# 2021-08-29, Georg Fischer
#
#:# Usage: (cf. makefile)
#:#   perl floorn.pl [-d debug] input > output
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

my $offset = 0;
my $nok; # assume ok
# while (<DATA>) {
while (<>) {
    $nok = 0;
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    next if ! m{\AA\d+};
    my ($aseqno, $superclass, $name, @rest) = split(/\t/, $line);
    my $orig_name = $name;

    $name =~ s{golden ratio}{phi}g; # normalize to "phi"
    $name =~ s{\(except for initial zero\)}{};
    $name =~ s{\,? *complement of A\d+}{}; # remove remark
    $name =~ s{[\;\,] *\[ *\] *\= *floor.*}{}; # remove explanation
    $name =~ s{[\;\,] *\{ *\} *\= *frac.*}{}; # remove explanation
    $name =~ s{\,? *(where )?\[ *\] (denotes|represents) (the )?floor.*}{}; # remove explanation
    $name =~ s{\,? *(where )?\{ *\} (denotes|represents) (the )?frac.*}{}; # remove explanation
    $name =~ s{\(?complement of A\d+.*}{};
    $name =~ s{ceiling}{ceil}g; # for Maple
    $name =~ s{pi}{Pi}g; # for Maple
    $name =~ s{\A[abc]\(n\) *\=? *}{};
    if (0) {
    } elsif ($name =~ m{(mod|sum|\.\.)|prod|binom|\!|fibon|lucas|concat|prime|number}i) { # skip the ones with "mod", "sum" or ".." 
        $nok = 1; # wrong functions
    } elsif ($name =~ m{A\d\d\d+\(}) {
        $nok = 2; # A-number
    } elsif ($name =~ m{acci constant|if n is even}) {
        $nok = 4;
    } elsif ($name =~ m{([n\d\+\-\*\^ ]+)?(floor|ceil(ing)?|round|frac)}i) {
        $name =~ s{([n\d\+\-\*\^ ]+)?(floor|ceil(ing)?|round|frac)}{($1 || "") . lc($2)}ie;
        if ($name =~ m{(\W)[a-dxy]\(}) { # still contains a(n...)
            $nok = 7;
        }
    } else {
        $nok = 8;
        print STDERR "$aseqno, nok=8, name=\"$name\"\n";
    }
    if ($nok == 0)  {
        $name =~ s{(\d)([a-zA-Z])}{$1\*$2}g; # insert "*"
        $name =~ s{(\d)\[}{$1\*\[}g; # insert "*"
        if ($name =~ s{floor\[}{floor\(}g) { # normalize "floor[" -> "floor("
            $name =~ s{\]}{\)}g;
        }
        if ($name =~ s{[\,\;]? *r *\= *golden +ratio *\,}{}) { # normalize to "phi"
            $name =~ s{\=r}{\=phi}g;
        }
        $name =~ s{phi\^\-1}{1\/phi}g;
        $name =~ s{where phi *\= *.*}{}g;
        if ($name =~ s{[\,\;]? *tau *\= *golden *ratio( *\= *\(1 *\+ *sqrt\(5\)\) *\/ *2)?}{}) {  # normalize to "phi"
            $name =~ s{tau}{phi}g;
        }
        $name =  &insert_mul($name);
        if ($name =~ s{r\=golden *ratio\,?}{}) { # normalize to "phi"
            $name =~ s{(\W)r(\W)}{${1}phi$2}g;
        }
        
        my %vhash = ();
        if ($name =~ s{( *with|\,? *where|\;) *\(([^\)]+)\) *\= *\(([^\)]+)\).*}{}) { # extract the variables
            #          1                    1    2      2          3      3
            my $varlist = $2;
            my $explist = $3;
            my @vars = split(/\, */, $varlist);
            my @exps = split(/\, */, $explist);
            if (scalar(@vars) == scalar(@exps)) {
                my $list = "";
                for (my $ivar = 0; $ivar < scalar(@vars); $ivar ++) {
                    $list .= ",$vars[$ivar]=$exps[$ivar]";
                    $vhash{$vars[$ivar]} = $exps[$ivar];
                } # for $ivar
                $name .= $list;
            }
        } else {  
            $name =~ s{( *with|\,? *where|\;) *}{\,}g; 
        }
        foreach my $var (keys(%vhash)) { # insert nested variables
            $vhash{$var} =~ s{([bcdefgrstuvwx])}{$vhash{$1}}eg;
        } # foreach key
        $name =~ s{\[}{floor\(}g; # normalize [...] -> floor(...)
        $name =~ s{\]}{\)}g; # normalize
        $name =~ s{\{}{frac\(}g; # normalize {...} -> frac(...)
        $name =~ s{\}}{\)}g; # normalize
        $name =~ s{ }{}g; # remove spaces
        $name =~ s{\;}{\,}g; # normalize to ","
    #   if ($name =~ s{\, *x\=([^\.\,\;]+)}{}) { # special treatment of "x" - the only nested one?
    #       my $x = $1;
    #       $name =~ s{x}{$x}g;
    #   }
        $name =~ s{(\W)n\*(\w)(\W)}{$1$2\*n$3}g; # convert Z*CR to CR*Z
        my $cc = "floor_";
        if ($mode eq "old") { # old code
            $name =~ s{\,\,+}{\,}g; # only one separator
            if (0 or ($name =~ m{\An([\+\-\*])?(floor|ceil|round|frac)\(})) {
                foreach my $part(split(/\, */, $name)) {
                    $part =~ s{\A((\w)\=)?(.+)}{$3};
                    my $code = defined($2) ? ("m" . uc($2)) : "z"; # "z" is the highest lowercase letter and may not be a variable name
                    print join("\t", $aseqno, "$cc$code", 0, $part) . "\n";
                } # foreach
            } elsif ($nok == 0) {
                $nok = 5;
            }
        } else { # new code
            $name =~ s{\,\,+}{\,}g; # only one separator
            if (($name =~ m{\A([n\d\+\-\*\^ ]+)?(floor|ceil|round|frac)\(})) {
                foreach my $part(split(/\, */, $name)) {
                    $part =~ s{\A((\w)\=)?(.+)}{$3};
                    my $code = defined($2) ? ("m" . uc($2)) : "z"; # "z" is the highest lowercase letter and may not be a variable name
                    print join("\t", $aseqno, "$cc$code", 0, $part) . "\n";
                } # foreach
            } elsif ($nok == 0) {
                $nok = 6;
            }
        #   my ($var, $mVar);
        #   $name =~ s{\,.*}{}; # remove all behind main formula
        #   if (1 or ($name =~ m{\An(\+)?floor\(})) {
        #       foreach $var (keys(%vhash)) {
        #           $mVar = "m" . uc($var);
        #           $name =~ s{(\W)$var(\W)}{$1$mVar$2}g; # replace "r" by "mR" etc.
        #           print join("\t", $aseqno, "$cc$mVar", 0, "$vhash{$var}") . "\n";
        #       } # variables
        #       $mVar = "z"; # "z" is the highest lowercase letter and may not be a variable name
        #       print     join("\t", $aseqno, "$cc$mVar", 0, $name, $orig_name) . "\n";
        #   } else {
        #       print STDERR "$line\n";
        #   }
        }
    }
    if ($nok > 0) {
       print STDERR "# nok=$nok: $name # $line\n";
    }
} # while
#----
sub insert_mul {
    my ($name) = @_;
    $name =~ s{(\W)([a-z])([a-z])(\W)}{$1$2\*$3$4}g; # \W = non-word char.
    $name =~ s{([\)\]])([a-z])(\W)}   {$1\*$2$3}g; 
    $name =~ s{(\W)([a-z])([\[\(])}   {$1$2\*$3}g; 
    return $name;
} # insert_mul
__DATA__
#--------------------------------
A051498	null	a(n) = floor(tan(n)^3).	sign,synth	0..72	nyi

# A190427	uence	a(n) = [(b*n+c)*r] - b*[n*r] - [c*r], where (r,b,c)=(golden ratio,2,1) and []=floor.	nonn,	1..10000	floor
# A190496	null	a(n) = [(bn+c)r]-b[nr]-[cr], where (r,b,c)=(sqrt(2),3,2) and []=floor.	nonn,	1000
# A190504	null	n+[ns/r]+[nt/r]+[nu/r]; r=golden ratio, s=r+1, t=r+2, u=r+3.	nonn,synth	1..69	nyi
# A190505	null	n+[nr/s]+[nt/s]+[nu/s];  r=golden ratio, s=r+1, t=r+2, u=r+3.	nonn,synth	1..71	nyi
# A190506	null	n+[nr/t]+[ns/t]+[nu/t];  r=golden ratio, s=r+1, t=r+2, u=r+3.	nonn,synth	1..74	nyi
# A190507	null	n+[nr/u]+[ns/u]+[nt/u];  r=golden ratio, s=r+1, t=r+2, u=r+3.	nonn,changed,synth	1..76	nyi
# A190508	null	n+[ns/r]+[nt/r]+[nu/r]; r=golden ratio, s=r^2, t=r^3, u=r^4.	nonn,synth	1..68	nyi
# 
# A190754	null	a(n)=n+[nr/u]+[ns/u]+[nt/u]+[nv/u]+[nw/u], where r=sinh(x),s=cosh(x),t=tanh(x),u=csch(x),v=sech(x),w=coth(x),x=Pi/2.	nonn,changed,synth	1..65	nyi

# A184820	null	n+[n/t]+[n/t^2];tisthetribonaccicon*stan*t.
# A184821	null	n+[n*t]+[n/t];tisthetribonaccicon*stan*t.
# A184822	null	n+[n*t]+[n*t^2];tisthetribonaccicon*stan*t.
# A184823	null	n+[n/t]+[n/t^2]+[n/t^3];tisthetetranaccicon*stan*t.
# A184824	null	n+[n*t]+[n/t]+[n/t^2];tisthetetranaccicon*stan*t.
# A184825	null	n+[n*t]+[n*t^2]+[n/t];tisthetetranaccicon*stan*t.
# A184826	null	n+[n*t]+[n*t^2]+[n*t^3];tisthetetranaccicon*stan*t.
# A184835	null	n+[n/t]+[n/t^2]+[n/t^3]+[n/t^4];tisthepen*tanaccicon*stan*t.
# A184836	null	n+[n*t]+[n/t]+[n/t^2]+[n/t^3];tisthepen*tanaccicon*stan*t.
# A184837	null	n+[n*t]+[n*t^2]+[n/t]+[n/t^2];tisthepen*tanaccicon*stan*t.
# A184838	null	n+[n*t]+[n*t^2]+[n*t^3]+[n/t];tisthepen*tanaccicon*stan*t.
# A184839	null	n+[n*t]+[n*t^2]+[n*t^3]+[n*t^4];tisthepen*tanaccicon*stan*t.