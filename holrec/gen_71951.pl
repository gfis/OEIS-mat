#!perl

# Generate holonomic recurrences for the columns of A071951
# @(#) $Id$
# 2021-02-01, Georg Fischer; SBW
#
#:# Usage:
#:#   perl gen_71951 > hr.gen
#
#---------------------------------
use strict;
use integer;
use warnings;

while (<DATA>) {
    s{\s+\Z}{};
    my $line = $_;
    my ($aseqno, $k, @rest) = split(/\s+/, $line);
    if ($aseqno =~ m{\AA}) {
        my $expr = "1/(1";
        # A089277: G.f.: 1/product(1- p*(p+1)*x, p=1..6)
        for (my $p = 1; $p <= $k; $p ++) {
            $expr .= "*(1 - $p*($p+1)*x)";
        } # for $p
        $expr .= ")";
        print join("\t", $aseqno, "pfract", 0, $expr) . "\n";
    }
} # while <>    
__DATA__
# A000079 (powers of 2), 
A000079	1			Powers of 2
A016129	2			A016129 Expansion of 1/((1-2*x)+(1-6*x)).
A016309	3
A071952	4
A089274	5
A089277	6
A090007	7
A090008	8
A090009	9
A090010	10
