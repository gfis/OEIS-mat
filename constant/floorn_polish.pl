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
    $name =~ s{[\;\:]}{\,}g; # normalize to ","
    $name =~ s{[\(\,]?complementofA\d+.*}{};
    $name =~ s{ceiling}{ceil}ig;
    $name =~ s{(ceil|floor|round|frac)}{lc($1)}ieg;
    $name =~ s{\,\[\.?\](\=|denotes|is|represents)(the)?floor(function)?}{}; # remove explanation
    $name =~ s{\,(\{\.?\}|frac)denotesthefract\w*}{}; # remove explanation
    $name =~ s{\,\{\.?\}\=frac\w*}{}; # remove explanation
    $name =~ s{\(thegoldenratio\.?\)?|isthegoldenratio}{}i; # remove expanation
    $name =~ s{\=goldenratio}{\=phi}g; # normalize to "phi"
    $name =~ s{pi}{Pi}g; # for Maple
    $name =~ s{gamma\(}{GAMMA\(}ig; # for Maple
    $name =~ s{cuberootof(\d)}{$1\^\(1\/3\)}g;
    $name =~ s{\(1\+sqrt\(5\)\)\/2}{phi}g;
    $name =~ s{\|}{abs\(}; # no! global
    $name =~ s{\|}{\)};
    $name =~ s{\)([a-z])}{\)\*$1}g; # insert "*" behind ")"
    $name =~ s{(\d)([a-z])}{$1\*$2}g; # insert "*" behind digit
    $name =~ s{(\W)([ne])([a-z])(\W)}{$1$2\*$3$4}g;
    $name =~ s{floor\[([^\]]*)\]}{floor\($1\)}g;
    $name =~ s{\*forx=}{\,x\=}g;
    $name =~ s{n(cot|csc)\(}{n\*$1\(}g; # insert "*"
    if ($name =~ s{\,fcomputesthefractionalpart}{}) {
    	$name =~ s{f\(}{frac\(}g;
    }
    $name =~ s{cotangent}{cot}g;
    $name =~ s{tau}{phi}g;
    $name =~ s{phi\=phi}{phi}g;
    $name =~ s{\,phi\Z}{}g;
    $name =~ s{\[}{floor\(}g;
    $name =~ s{\]}{\)}g;
    $name =~ s{\{}{frac\(}g;
    $name =~ s{\}}{\)}g;

    $name =~ s{phi\=phi}{phi}g;
    $name =~ s{phi\=phi}{phi}g;
    $name =~ s{phi\=phi}{phi}g;
    
    
    if (0) {
    } elsif ($name =~ m{A\d\d\d+}) {
        $nok = 1; # A-number
    } elsif ($name =~ m{acciconstant}) {
        $nok = 2;
    } elsif ($name =~ m{(\W)[abcxyA-Z]\(}) {
        $nok = 3;
    } elsif ($name =~ m{(floors?|ceil)of}) {
    	$nok = 4;
    } elsif ($name =~ m{H_n}) {
        $nok = 5;
    } elsif ($name =~ m{fraction|sigma}) {
        $nok = 6;
    } elsif ($name =~ m{solution}) {
        $nok = 7;
    } elsif ($name =~ m{\w{7}}) {
        $nok = 8;
    } elsif ($name =~ m{with}) {
        $nok = 9;
    }
    if ($nok == 0) {
        print join("\t", $aseqno, $superclass, $name) . "\n";
    } else { 
    	print STDERR join("\t", $aseqno, "nok=$nok", $name) . "\n";
    }
} # while
__DATA__

    $name =~ s{\(except for initial zero\)}{};
    $name =~ s{\,? *complement of A\d+}{}; # remove remark
    $name =~ s{\,? *(where )?\[ *\] (denotes|represents) (the )?floor.*}{}; # remove explanation
    $name =~ s{\,? *(where )?\{ *\} (denotes|represents) (the )?frac.*}{}; # remove explanation
    $name =~ s{ceiling}{ceil}g; # for Maple
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
A184929	null	n+[rn/s]+[tn/s]+[un/s],[]=floor,r=sin(Pi/2),s=sin(Pi/3),t=sin(Pi/4),u=sin(Pi/5)
A184930	null	n+[rn/t]+[sn/t]+[un/t],[]=floor,r=sin(Pi/2),s=sin(Pi/3),t=sin(Pi/4),u=sin(Pi/5)
A184931	null	n+[rn/u]+[sn/u]+[tn/u],[]=floor,r=sin(Pi/2),s=sin(Pi/3),t=sin(Pi/4),u=sin(Pi/5)
A185546	null	floor((1/2)*(n+1)^(3/2));complementofA185547
A185548	null	floor(floor(n^(5/2))^(2/3))
A185549	null	ceil(n^(3/2));complementofA185550
A185592	null	floor(n^(3/2))*floor(1+n^(3/2))*floor(2+n^(3/2))/6
A185593	null	floor(n^(3/2))*floor(3+n^(3/2))/2
