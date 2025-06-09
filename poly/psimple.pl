#!perl

# Try to extract simple polynomials from the expression in $(PARM2)
# @(#) $Id$
# 2025-06-08, Georg Fischer; *FP=11
#
#:# Usage:
#:#     perl psimple.pl [-d mode] input.seq4 > output.seq4
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

my  ($aseqno, $callcode, $offset, $polys, $postfix, @rest);
my ($src, $tar, $ipoly, $pname, @parts, %hash, $pn);
while (<>) {
#while (<DATA>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    (                $aseqno, $callcode, $offset, $polys, $postfix, @rest) = split(/\t/, $line);
    $ipoly = 0;         
    $postfix =~ s{\s}{}g; # remove whitespace 
    @parts = ();
    %hash = ();
    while ($postfix =~ s{\(([\d\+\-\*\/\^x]+)\)}{\(\#\)}) {
        push(@parts, $1);
    } 
    if ($debug >= 1) {
        print "\n#0 postfix=$postfix, parts=[" . join(", ", @parts) . "]\n";
    }
    for (my $ip = 0; $ip < scalar(@parts); $ip ++) {
        $tar = &trans($parts[$ip]);
            if ($debug >= 2) {
                print "#1 ip=$ip, parts[ip]=$parts[$ip], tar=$tar\n";
            }
        if (length($tar) >= 3) {
            if (!defined($hash{$tar})) { # new
                $polys =~ s{\]\"}{\],$tar\"};
                $ipoly ++;
                $pn = "p$ipoly";
                $hash{$tar} = $pn;
            } else {  
            	  $pn = $hash{$tar};
            }
            if ($debug >= 2) {
                print "#2 ip=$ip, tar=$tar, pn=$pn\n";
            }
            $parts[$ip] = $pn;
        } 
        $postfix =~ s{\#}{$parts[$ip]}; 
    } # foreach
    print join("\t", $aseqno, $callcode, $offset, $polys, $postfix, @rest) . "\n";
} # while <>   
#----
sub trans { # translate a polynomial into a bracketed list of coefficients [c0,c1,...]
    my ($part) = @_; 
    my $result = ""; 
    if (0) {
    #                     1      12      234   4  3  5     5
    } elsif ($part =~ m{\A(\-?\d+)([\-\+])((\d+)\*)?x(\/\d+)?\Z}) {  # 1-4*x/5
        my ($c0, $op, $c1, $den) = ($1 || 1, $2, $4 || 1, $5 || "/1");
        $op =~ s{\+}{};
        $c1 = "$op$c1"; 
        $den =~ s{\A\/1\Z}{};
        $result = "$c0,$c1$den";
    #                     1            1 2     2
    } elsif ($part =~ m{\A(\-?\d+\*|\-|)x(\/\d+)?\Z}) {  # 2*x/3
        my ($c0, $op, $c1, $den) = (0, "", $1 || 1, $2 || "/1");
        $c1 =~ s{\*}{};
        $c1 =~ s{\A\-\Z}{\-1};
        $den =~ s{\A\/1\Z}{};
        $result = "$c0,$c1$den";
        $result =~ s{\A0\,1\Z}{};
    }
    return "[$result]";
}
#--------------------------------------------
__DATA__
A354264	poly	0	"[1]"	1/(1+4*log(1-x))	 	 	 	 	 	 * E.g.f.: 1/(1+4*log(1-x)).
A354286	poly	0	"[1]"	1/(-1-x)^(2/(1+2*log(1-x)))	 	 	 	 	 	 * E.g.f.: 1/(-1-x)^(2/(1+2*log(1-x))).	fake -
A354309	poly	0	"[1]"	1/(1-2*x)^(x/2)	 	 	 	 	 	 * E.g.f.: 1/(1-2*x)^(x/2).
A354311	poly	0	"[1]"	exp(x/2*(exp(2*x)-1))	 	 	 	 	 	 * E.g.f.: exp(x/2*(exp(2*x)-1)).
A354311	poly	0	"[1]"	exp(-x/2*(exp(-2*x)-1))	 	 	 	 	 	 * E.g.f.: exp(-x/2*(exp(-2*x)-1)).
A354311	poly	0	"[1]"	exp(-2*x/2*(exp(-x)-1))	 	 	 	 	 	 * E.g.f.: exp(-2*x/2*(exp(-x)-1)).
A354311	poly	0	"[1]"	exp(2*x/2*(exp(x)-1))	 	 	 	 	 	 * E.g.f.: exp(2*x/2*(exp(x)-1)).
