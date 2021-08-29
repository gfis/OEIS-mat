#!perl
# Extract parameters from Clark Kimberling's guides
# @(#) $Id$
# 2021-08-24, Georg Fischer
#
#:# Usage:
#:#   perl ck_guide_U.pl [-d debug] > output
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
my $asel = "0-9a-z"; # select all possible TAB codes
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{a}) {
        $asel      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
my $asave;
my $rsave;
my $hsave;
while (<DATA>) {
    my $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $line =~ s/ //g; # remove spaces
    xxbreak!!!!
    my ($aseqno, $superclass, $name, @rest) = split(/\t/, $line);
    next if $name =~ m{acci constant|if n is even};
    $name =~ s{\A[a-f]\(n\) *\= *}{};
    next if $name =~ m{[a-f]\(n};
    $name =~ s{ *\. *\Z}{};
    $name =~ s{ and }{\,}g;
    $name =~ s{\,? *complement of A\d+}{};
    $name =~ s{\, *\[ *\] (denotes|represents) the floor function}{}g; # remove explanation
    $name =~ s{[\;\,] *\[ *\] *\= *floor}{}g; # remove explanation
    if ($name =~ s{[\,\;]? *r *\= *golden +ratio *\,}{}) {
        $name =~ s{\=r}{\=phi}g;
    }
    if ($name =~ s{( *with|\,? *where|\;) *\(([^\)]+)\) *\= *\(([^\)]+)\).*}{}) {
        #          1                    1    2      2          3      3
        my $varlist = $2;
        my $explist = $3;
        my @vars = split(/\, */, $varlist);
        my @exps = split(/\, */, $explist);
        if (scalar(@vars) == scalar(@exps)) {
            my $list = "";
            for (my $ivar = 0; $ivar < scalar(@vars); $ivar ++) {
                $list .= ",$vars[$ivar]=$exps[$ivar]";
            } # for $ivar
            $name .= $list;
        }
    } else {
        $name =~ s{( *with|\,? *where|\;) *}{\,}g;
    }
    next if $name =~ s{n mod (\d+)}{mod\(n\,$1\)}g; # skip the ones with "mod(...)" 
    $name =  &insert_mul($name);
    if ($name =~ s{r\=golden *ratio\,?}{}) {
        $name =~ s{(\W)r(\W)}{${1}phi$2}g;
    }
    $name =~ s{\[}{floor\(}g; # normalize [...] -> floor(...)
    $name =~ s{\]}{\)}g; # normalize
    $name =~ s{(\d)([a-zA-Z])}{$1\*$2}g; # insert "*"
    $name =~ s{pi}{Pi}g;
    if ($name =~ s{\, *tau *\= *golden *ratio( *\= *\(1 *\+ *sqrt\(5\)\) *\/ *2)?}{}) {
        $name =~ s{tau}{phi}g;
    }
    $name =~ s{ }{}g; # remove spaces
    $name =~ s{\;}{\,}g; # remove spaces
    if ($name =~ s{\, *x\=([^\.\,\;]+)}{}) { # special treatment of "x" - the only nested one?
        my $x = $1;
        $name =~ s{x}{$x}g;
    }
    $name =~ s{\,\,+}{\,}g; # only one separator
    if ($name =~ m{\An(\+)?floor\(}) {
        foreach my $part(split(/\, */, $name)) {
            my $cc = "floor_";
            $part =~ s{\A((\w)\=)?(.+)}{$3};
            my $code = defined($2) ? ("m" . uc($2)) : "z"; # "Z" is the highest lowercase letter and may not be a variable name
            print join("\t", $aseqno, "$cc$code", 0, "$part") . "\n";
        } # foreach
    } else {
    }
} # while
#----
sub insert_mul {
	my ($name) = @_;
#   $name =~ s{n([b-er-y])}{n\*$1}g; # insert "*"
#   $name =~ s{([b-er-y])n}{$1\*n}g; # insert "*"
	$name =~ s{(\W)([a-z])([a-z])(\W)}{$1$2\*$3$4}g; # \W = non-word char.
	$name =~ s{([\)\]])([a-z])(\W)}   {$1\*$2$3}g; 
	$name =~ s{(\W)([a-z])([\[\(])}   {$1$2\*$3}g; 
	return $name;
} # insert_mul

# A208510
__DATA__
A034839	u	1    	1    	0    	1    x	    0	    	CCOT
A034867	v	1    	1    	0    	1    x	    0	    	CEN
A210221	u	1    	1    	0    	1    2	x   0	    	BBFF
A210596	v	1    	1    	0    	1    2	x   0	    	BBFF
A105070	v	1    	1    	0    	1    2	x   0	    	BN
A207605	u	1    	1    	0    	1    x	+1  0	    	BCFFN
A106195	v	1    	1    	0    	1    x	+1  0	    	BCFFN
A207606	u	1    	1    	0    	x    x	+1  0	    	DNT
A207607	v	1    	1    	0    	x    x	+1  0	    	DNT
A207608	u	1    	1    	0    	2x   x	+1  0	    	N
A207609	v	1    	1    	0    	2x   x	+1  0	    	C
A207610	u	1    	1    	0    	1    x	    1	    	CF
A207611	v	1    	1    	0    	1    x	    1	    	BCF
A207612	u	1    	1    	0    	1    2	x   1	    	BF
A207613	v	1    	1    	0    	1    2	x   1	    	BF
A207614	u	1    	1    	0    	1    x	+1  1	    	CN
A207615	v	1    	1    	0    	1    x	+1  1	    	CFN
A207616	u	1    	1    	0    	x    1	    1	    	CE
A207617	v	1    	1    	0    	x    1	    1	    	CNO
A029638	u	1    	1    	0    	x    x	    1	    	CDNO
A207635	v	1    	1    	0    	x    x	    1	    	CDNOZ
A207618	u	1    	1    	0    	x    2	x   1	    	N
A207619	v	1    	1    	0    	x    2	x   1	    	CFN
A207620	u	1    	1    	0    	x    x	+1  1	    	DET
A207621	v	1    	1    	0    	x    x	+1  1	    	DNO
A207622	u	1    	1    	0    	2x   1	    1	    	BT
A207623	v	1    	1    	0    	2x   1	    1	    	BN
A207624	u	1    	1    	0    	2x   x	    1	    	N
A102662	v	1    	1    	0    	2x   x	    1	    	CO
A207625	u	1    	1    	0    	2x   x	+1  1	    	T
A207626	v	1    	1    	0    	2x   x	+1  1	    	N
A207627	u	1    	1    	0    	2x   2	x   1	    	BN
A207628	v	1    	1    	0    	2x   2	x   1	    	BCE
A207629	u	1    	1    	0    	x+1  1	    1	    	CET
A207630	v	1    	1    	0    	x+1  1	    1	    	CO
A207631	u	1    	1    	0    	x+1  x	    1	    	DF
A207632	v	1    	1    	0    	x+1  x	    1	    	DEF
A207633	u	1    	1    	0    	x+1  2	x   1	    	F
A207634	v	1    	1    	0    	x+1  2	x   1	    	F
A207635	u	1    	1    	0    	x+1  x	+1  1	    	DN
A207636	v	1    	1    	0    	x+1  x	+1  1	    	CD
A160232	u	1    	x    	0    	1    2	x   0	    	BCFN
A208341	v	1    	x    	0    	1    2	x   0	    	BCFFN
A085478	u	1    	x    	0    	1    x	+1  0	    	CCOFT*
A078812	v	1    	x    	0    	1    x	+1  0	    	CEFN*
A208342	u	1    	x    	0    	x    x	    0	    	CCFNO
A208343	v	1    	x    	0    	x    x	    0	    	BBCDFZ
A208344	u	1    	x    	0    	x    2	x   0	    	CCFN
A208345	v	1    	x    	0    	x    2	x   0	    	CFZ
A094436	u	1    	x    	0    	x    x	+1  0	    	CFFN
A094437	v	1    	x    	0    	x    x	+1  0	    	CEFF
A117919	u	1    	x    	0    	2x   1	    0	    	BCNT
A135837	v	1    	x    	0    	2x   1	    0	    	BCET
A208328	u	1    	x    	0    	2x   x	    0	    	CCOP
A208329	v	1    	x    	0    	2x   x	    0	    	DPZ
A208330	u	1    	x    	0    	2x   x	+1  0	    	CNPT
A208331	v	1    	x    	0    	2x   x	+1  0	    	CN
A208332	u	1    	x    	0    	2x   2	x   0	    	CCE
A208333	v	1    	x    	0    	2x   2	x   0	    	DZ
A208334	u	1    	x    	0    	x+1  1	    0	    	CCNT
A208335	v	1    	x    	0    	x+1  1	    0	    	CCN*
A208336	u	1    	x    	0    	x+1  x	    0	    	CFNT*
A208337	v	1    	x    	0    	x+1  x	    0	    	ACFN*
A208338	u	1    	x    	0    	x+1  2	x   0	    	CNP
A208339	v	1    	x    	0    	x+1  2	x   0	    	BCNP
A202390	u	1    	x    	0    	x+1  x	+1  0	    	CFPTZ*
A208340	v	1    	x    	0    	x+1  x	+1  0	    	FNPZ*
A208508	u	1    	x    	0    	1    1	    1	    	CCES
A208509	v	1    	x    	0    	1    1	    1	    	BCO
A208510	u	1    	x    	0    	1    x	    1	    	CCCNOS*
A029653	v	1    	x    	0    	1    x	    1	    	BCDOSZ*
A208511	u	1    	x    	0    	1    2	x   1	    	BCFO
A208512	v	1    	x    	0    	1    2	x   1	    	BDFO
A208513	u	1    	x    	0    	1    x	+1  1	    	CCES*
A111125	v	1    	x    	0    	1    x	+1  1	    	COO*
A133567	u	1    	x    	0    	x    1	    1	    	CCOTT
A133084	v	1    	x    	0    	x    1	    1	    	BBCEN
A208514	u	1    	x    	0    	x    x	    1	    	CEFN
A208515	v	1    	x    	0    	x    x	    1	    	BCDFN
A208516	u	1    	x    	0    	x    2	x   1	    	CNN
A208517	v	1    	x    	0    	x    2	x   1	    	CCN
A208518	u	1    	x    	0    	x    x	+1  1	    	CFNT
A208519	v	1    	x    	0    	x    x	+1  1	    	NFFT
A208520	u	1    	x    	0    	2x   1	    1	    	BCTT
A208521	u	1    	x    	0    	2x   1	    1	    	BEN
A208522	u	1    	x    	0    	2x   x	    1	    	CCN
A208523	v	1    	x    	0    	2x   x	    1	    	CCO
A208524	u	1    	x    	0    	2x   x	+1  1	    	CT*
A208525	v	1    	x    	0    	2x   x	+1  1	    	ACNP*
A208526	u	1    	x    	0    	2x   2	x   1	    	CEN
A208527	v	1    	x    	0    	2x   2	x   1	    	CCE
A208606	u	1    	x    	0    	x+1  1	    1	    	CCS
A208607	v	1    	x    	0    	x+1  1	    1	    	CNO
A208608	u	1    	x    	0    	x+1  x	    1	    	CFOT
A208609	v	1    	x    	0    	x+1  x	    1	    	DEN*
A208610	u	1    	x    	0    	x+1  2	x   1	    	CO
A208611	v	1    	x    	0    	x+1  2	x   1	    	DE
A208612	u	1    	x    	0    	x+1  x	+1  1	    	CFNS
A208613	v	1    	x    	0    	x+1  x	+1  1	    	CFN*
A105070	u	1    	2x   	0    	1    1	    0	    	BN
A207536	v	1    	2x   	0    	1    1	    0	    	BCT
A208751	u	1    	2x   	0    	1    x	+1  0	    	CDPT
A208752	v	1    	2x   	0    	1    x	+1  0	    	CNP
A135837	u	1    	2x   	0    	x    1	    0	    	BCNT
A117919	v	1    	2x   	0    	x    1	    0	    	BCNT
A208755	u	1    	2x   	0    	x    x	    0	    	BCDEP
A208756	v	1    	2x   	0    	x    x	    0	    	BCCOZ
A208757	u	1    	2x   	0    	x    2	x   0	    	CDEP
A208758	v	1    	2x   	0    	x    2	x   0	    	CCEPZ
A208763	u	1    	2x   	0    	2x   x	    0	    	CDOP
A208764	v	1    	2x   	0    	2x   x	    0	    	CCCP
A208765	u	1    	2x   	0    	2x   x	+1  0	    	CE
A208766	v	1    	2x   	0    	2x   x	+1  0	    	CC
A208747	u	1    	2x   	0    	2x   2	x   0	    	CDE
A208748	v	1    	2x   	0    	2x   2	x   0	    	CCZ
A208749	u	1    	2x   	0    	x+1  1	    0	    	BCOPT
A208750	v	1    	2x   	0    	x+1  1	    0	    	BCNP*
A208759	u	1    	2x   	0    	x+1  2	x    	0   	CE
A208760	v	1    	2x   	0    	x+1  2	x    	0   	BCO
A208761	u	1    	2x   	0    	x+1  x	+1   	0   	BCCT*
A208762	v	1    	2x   	0    	x+1  x	+1   	0   	BNZ*
A208753	u	1    	2x   	0    	1    1	     	1   	BCS
A208754	v	1    	2x   	0    	1    1	     	1   	BO
A105045	u	1    	2x   	0    	1    2	x    	1   	BCCOS*
A208659	v	1    	2x   	0    	1    2	x    	1   	BDOSZ*
A208660	u	1    	2x   	0    	1    x	+1   	1   	CDS
A208904	v	1    	2x   	0    	1    x	+1   	1   	CNO
A208905	u	1    	2x   	0    	x    1	     	1   	BCT
A208906	v	1    	2x   	0    	x    1	     	1   	BNN
A208907	u	1    	2x   	0    	x    x	     	1   	BCN
A208756	v	1    	2x   	0    	x    x	     	1   	BCCE
A208755	u	1    	2x   	0    	x    2	x    	1   	CEN
A208910	v	1    	2x   	0    	x    2	x    	1   	CCE
A208911	u	1    	2x   	0    	x    x	+1   	1   	BCT
A208912	v	1    	2x   	0    	x    x	+1   	1   	BNT
A208913	u	1    	2x   	0    	2x   1	     	1   	BCT
A208914	v	1    	2x   	0    	2x   1	     	1   	BEN
A208915	u	1    	2x   	0    	2x   x	     	1   	CE
A208916	v	1    	2x   	0    	2x   x	     	1   	CCO
A208919	u	1    	2x   	0    	2x   x	+1   	1   	CT
A208920	v	1    	2x   	0    	2x   x	+1   	1   	N
A208917	u	1    	2x   	0    	2x   2	     	1   	CEN
A208918	v	1    	2x   	0    	2x   2	     	1   	CCNP
A208921	u	1    	2x   	0    	x+1  1	     	1   	BC
A208922	v	1    	2x   	0    	x+1  1	     	1   	BON
A208923	u	1    	2x   	0    	x+1  x	     	1   	BCNO
A208908	v	1    	2x   	0    	x+1  x	     	1   	BDN*
A208909	u	1    	2x   	0    	x+1  2	x    	1   	BN
A208930	v	1    	2x   	0    	x+1  2	x    	1   	DN
A208931	u	1    	2x   	0    	x+1  x	+1   	1   	BCOS
A208932	v	1    	2x   	0    	x+1  x	+1   	1   	BCO*
A207537	u	1    	x+1  	0    	1    1	     	0   	BCO
A207538	v	1    	x+1  	0    	1    1	     	0   	BCE
A122075	u	1    	x+1  	0    	1    x	     	0   	CCFN*
A037027	v	1    	x+1  	0    	1    x	     	0   	CCFN*
A209125	u	1    	x+1  	0    	1    2	x    	0   	BCFN*
A164975	v	1    	x+1  	0    	1    2	x    	0   	BF
A209126	u	1    	x+1  	0    	x    x	     	0   	CDFO*
A209127	v	1    	x+1  	0    	x    x	     	0   	DFOZ*
A209128	u	1    	x+1  	0    	x    2	x    	0   	CDE*
A209129	v	1    	x+1  	0    	x    2	x    	0   	DEZ
A102756	u	1    	x+1  	0    	x    x	+1   	0   	CFNP*
A209130	v	1    	x+1  	0    	x    x	+1   	0   	CCFNP*
A209131	u	1    	x+1  	0    	x    x	+1   	0   	CDEP*
A209132	v	1    	x+1  	0    	x    x	+1   	0   	CNPZ*
A209133	u	1    	x+1  	0    	x    x	+1   	0   	CDN
A209134	v	1    	x+1  	0    	x    x	+1   	0   	CCN*
A209135	u	1    	x+1  	0    	2x   x	+1   	0   	CN*
A209136	v	1    	x+1  	0    	2x   x	+1   	0   	CCS*
A209137	u	1    	x+1  	0    	x+1  x	     	0   	CFFP*
A209138	v	1    	x+1  	0    	x+1  x	     	0   	AFFP*
A209139	u	1    	x+1  	0    	x+1  2	x    	0   	CF*
A209140	v	1    	x+1  	0    	x+1  2	x    	0   	BF
A209141	u	1    	x+1  	0    	x+1  x	+1   	0   	BCF*
A209142	v	1    	x+1  	0    	x+1  x	+1   	0   	BFZ*
A209143	u	1    	x+1  	0    	1    1	     	1   	CCE*
A209144	v	1    	x+1  	0    	1    1	     	1   	COO*
A209145	u	1    	x+1  	0    	1    x	     	1   	CCFN*
A122075	v	1    	x+1  	0    	1    x	     	1   	CCFN*
A209146	u	1    	x+1  	0    	1    2	x    	1   	BCF*
A209147	v	1    	x+1  	0    	1    2	x    	1   	BF
A209148	u	1    	x+1  	0    	1    x	+1   	1   	CCO*
A209149	v	1    	x+1  	0    	1    x	+1   	1   	CDO*
A209150	u	1    	x+1  	0    	x    1	     	1   	CCNT*
A208335	v	1    	x+1  	0    	x    1	     	1   	CDNN*
A209151	u	1    	x+1  	0    	x    x	     	1   	CFN*
A208337	v	1    	x+1  	0    	x    x	     	1   	ACFN*
A209152	u	1    	x+1  	0    	x    x	     	1   	CN*
A208339	v	1    	x+1  	0    	x    x	     	1   	BCN
A209153	u	1    	x+1  	0    	x    x	     	1   	CFT*
A208340	v	1    	x+1  	0    	x    x	     	1   	FNZ*
A209154	u	1    	x+1  	0    	2x   1	     	1   	BCT*
A209157	v	1    	x+1  	0    	2x   1	     	1   	BNN
A209158	u	1    	x+1  	0    	2x   x	     	1   	CN*
A209159	v	1    	x+1  	0    	2x   x	     	1   	CO*
A209160	u	1    	x+1  	0    	2x   2	x    	1   	CN*
A209161	v	1    	x+1  	0    	2x   2	x    	1   	CE
A209162	u	1    	x+1  	0    	2x   x	+1   	1   	CT*
A209163	v	1    	x+1  	0    	2x   x	+1   	1   	CO*
A209164	u	1    	x+1  	0    	x+1  1	     	1   	CC*
A209165	v	1    	x+1  	0    	x+1  1	     	1   	CCN
A209166	u	1    	x+1  	0    	x+1  x	     	1   	CFF*
A209167	v	1    	x+1  	0    	x+1  x	     	1   	FF*
A209168	u	1    	x+1  	0    	x+1  2	x    	1   	CF*
A209169	v	1    	x+1  	0    	x+1  2	x    	1   	CF
A209170	u	1    	x+1  	0    	x+1  x	+1   	1   	CF*
A209171	v	1    	x+1  	0    	x+1  x	+1   	1   	CF*
A053538	u	x    	1    	0    	1    1	     	0   	BBCCFN
A076791	v	x    	1    	0    	1    1	     	0   	BBCDF
A209172	u	x    	1    	0    	1    2	x    	0   	BCCFF
A209413	v	x    	1    	0    	1    2	x    	0   	BCCFF
A094441	u	x    	1    	0    	1    x	+1   	0   	CFFFN
A094442	v	x    	1    	0    	1    x	+1   	0   	CEFFF
A054142	u	x    	1    	0    	x    x	+1   	0   	CCFOT*
A172431	v	x    	1    	0    	x    x	+1   	0   	CEFN*
A008288	u	x    	1    	0    	2x   1	     	0   	CCOO*
A035607	v	x    	1    	0    	2x   1	     	0   	ACDE*
A209414	u	x    	1    	0    	2x   x	+1   	0   	CCS
A112351	v	x    	1    	0    	2x   x	+1   	0   	CON
A209415	u	x    	1    	0    	x+1  x	     	0   	CCTN
A209416	v	x    	1    	0    	x+1  x	     	0   	ACN*
A209417	u	x    	1    	0    	x+1  2	x    	0   	CC
A209418	v	x    	1    	0    	x+1  2	x    	0   	BBC
A209419	u	x    	1    	0    	x+1  x	+1   	0   	CFTZ*
A209420	v	x    	1    	0    	x+1  x	+1   	0   	FNZ*
A209421	u	x    	1    	0    	1    1	     	1   	CCN
A209422	v	x    	1    	0    	1    1	     	1   	CD
A209555	u	x    	1    	0    	1    x	     	1   	CNN
A209556	v	x    	1    	0    	1    x	     	1   	CNN
A209557	u	x    	1    	0    	1    2	x    	1   	BCN
A209558	v	x    	1    	0    	1    2	x    	1   	BN
A209559	u	x    	1    	0    	1    2	x    	1   	CN
A209560	v	x    	1    	0    	1    2	x    	1   	CN
A209561	u	x    	1    	0    	x    1	     	1   	CCNNT*
A209562	v	x    	1    	0    	x    1	     	1   	CDNNT*
A209563	u	x    	1    	0    	x    x	     	1   	CCFT^
A209564	v	x    	1    	0    	x    x	     	1   	CFN^
A209565	u	x    	1    	0    	x    2	x    	1   	CC^
A209566	v	x    	1    	0    	x    2	x    	1   	BC^
A209567	u	x    	1    	0    	x    2	x    	1   	CNT*
A209568	v	x    	1    	0    	x    2	x    	1   	NNS*
A209569	u	x    	1    	0    	2x   1	     	1   	CNO*
A209570	v	x    	1    	0    	2x   1	     	1   	DNN*
A209571	u	x    	1    	0    	2x   x	     	1   	CCS^
A209572	v	x    	1    	0    	2x   x	     	1   	CN^
A209573	u	x    	1    	0    	2x   x	+1   	1   	CNS
A209574	v	x    	1    	0    	2x   x	+1   	1   	NO
A209575	u	x    	1    	0    	2x   2	x    	1   	CC
A209576	v	x    	1    	0    	2x   2	x    	1   	C
A209577	u	x    	1    	0    	2x   2	x    	1   	CNNT
A209578	v	x    	1    	0    	2x   2	x    	1   	CNN
A209579	u	x    	1    	0    	x+1  x	     	1   	CNNT
A209580	v	x    	1    	0    	x+1  x	     	1   	NN*
A209581	u	x    	1    	0    	x+1  2	x    	1   	CN
A209582	v	x    	1    	0    	x+1  2	x    	1   	BN
A209583	u	x    	1    	0    	x+1  x	+1   	1   	CT*
A209584	v	x    	1    	0    	x+1  x	+1   	1   	CN*
A121462	u	x    	x    	0    	x    x	+1   	0   	BCFFNZ
A208341	v	x    	x    	0    	x    x	+1   	0   	BCFFN
A209687	u	x    	x    	0    	2x   x	+1   	0   	BCNZ
A208339	v	x    	x    	0    	2x   x	+1   	0   	BCN
A115241	u	x    	x    	0    	1    1	     	1   	CDNZ*
A209668	v	x    	x    	0    	1    1	     	1   	DDN*
A209689	u	x    	x    	0    	1    x	     	1   	FNZ^
A209690	v	x    	x    	0    	1    x	     	1   	FN^
A209691	u	x    	x    	0    	1    2	x    	1   	BCZ^
A209692	v	x    	x    	0    	1    2	x    	1   	BCC^
A209693	u	x    	x    	0    	1    x	+1   	1   	NNZ*
A209694	v	x    	x    	0    	1    x	+1   	1   	CN*
A209697	u	x    	x    	0    	x    x	+1   	1   	BNZ
A209698	v	x    	x    	0    	x    x	+1   	1   	BNT
A209699	u	x    	x    	0    	x    x	+1   	1   	BNNZ
A209700	v	x    	x    	0    	x    x	+1   	1   	BDN
A209701	u	x    	x    	0    	2x   x	+1   	1   	NZ
A209702	v	x    	x    	0    	2x   x	+1   	1   	N
A209703	u	x    	x    	0    	x+1  1	     	1   	FNTZ
A209704	v	x    	x    	0    	x+1  1	     	1   	FNNT
A209705	u	x    	x    	0    	x+1  x	+1   	1   	BNZ*
A209706	v	x    	x    	0    	x+1  x	+1   	1   	BCN*
A209695	u	x    	x+1  	0    	2x   x	+1   	0   	ACN*
A209696	v	x    	x+1  	0    	2x   x	+1   	0   	CDN*
A209830	u	x    	x+1  	0    	x+1  2	x    	0   	ACF
A209831	v	x    	x+1  	0    	x+1  2	x    	0   	BCF*
A209745	u	x    	x+1  	0    	x+1  x	+1   	0   	ABF*
A209746	v	x    	x+1  	0    	x+1  x	+1   	0   	BFZ*
A209747	u	x    	x+1  	0    	1    1	     	1   	ADE*
A209748	v	x    	x+1  	0    	1    1	     	1   	DEO
A209749	u	x    	x+1  	0    	1    x	     	1   	ANN*
A209750	v	x    	x+1  	0    	1    x	     	1   	CNO
A209751	u	x    	x+1  	0    	1    2	x    	1   	ABN*
A209752	v	x    	x+1  	0    	1    2	x    	1   	BN
A209753	u	x    	x+1  	0    	1    x	+1   	1   	AN*
A209754	v	x    	x+1  	0    	1    x	+1   	1   	NT*
A209755	u	x    	x+1  	0    	x    1	     	1   	AFN
A209756	v	x    	x+1  	0    	x    1	     	1   	FNO*
A209759	u	x    	x+1  	0    	x    2	x    	1   	ACF^
A209760	v	x    	x+1  	0    	x    2	x    	1   	CF^*
A209761	u	x    	x+1  	0    	x     	x+1  	1   	ABNS*
A209762	v	x    	x+1  	0    	x     	x+1  	1   	BNS*
A209763	u	x    	x+1  	0    	2x    	1    	1   	ABN*
A209764	v	x    	x+1  	0    	2x    	1    	1   	BNN
A209765	u	x    	x+1  	0    	2x    	x    	1   	ACF^*
A209766	v	x    	x+1  	0    	2x    	x    	1   	CF^
A209767	u	x    	x+1  	0    	2x    	x+1  	1   	AN*
A209768	v	x    	x+1  	0    	2x    	x+1  	1   	N*
A209769	u	x    	x+1  	0    	x+1   	1    	1   	AF*
A209770	v	x    	x+1  	0    	x+1   	1    	1   	FN
A209771	u	x    	x+1  	0    	x+1   	x    	1   	ABN*
A209772	v	x    	x+1  	0    	x+1   	x    	1   	BN*
A209773	u	x    	x+1  	0    	x+1   	2x   	1   	AF
A209774	v	x    	x+1  	0    	x+1   	2x   	1   	FN*
A209775	u	x    	x+1  	0    	x+1   	x+1  	1   	AB*
A209776	v	x    	x+1  	0    	x+1   	x+1  	1   	BC*
A210033	u	1    	1    	1    	1     	x    	1   	BCN
A210034	v	1    	1    	1    	1     	x    	1   	BCDFN
A210035	u	1    	1    	1    	1     	2x   	1   	BBF
A210036	v	1    	1    	1    	1     	2x   	1   	BBFF
A210037	u	1    	1    	1    	1     	2x   	1   	BCFFN
A210038	v	1    	1    	1    	1     	x+1  	1   	BCFFN
A210039	u	1    	1    	1    	x     	1    	1   	BCOT
A210040	v	1    	1    	1    	x     	1    	1   	BCEN
A210042	u	1    	1    	1    	x     	x    	1   	BCDEOT*
A124927	v	1    	1    	1    	x     	x    	1   	BCDET*
A210041	u	1    	1    	1    	x     	2x   	1   	BFO
A209758	v	1    	1    	1    	x     	2x   	1   	BCFO
A210187	u	1    	1    	1    	x     	x+1  	1   	DTF*
A210188	v	1    	1    	1    	x     	x+1  	1   	DNF*
A210189	u	1    	1    	1    	2x    	1    	1   	BT
A210190	v	1    	1    	1    	2x    	1    	1   	BN
A210191	u	1    	1    	1    	2x    	x    	1   	CO*
A210192	v	1    	1    	1    	2x    	x    	1   	CCO*
A210193	u	1    	1    	1    	2x    	x+1  	1   	CPT
A210194	v	1    	1    	1    	2x    	x+1  	1   	CN
A210195	u	1    	1    	1    	2x    	2x   	1   	BOPT*
A210196	v	1    	1    	1    	2x    	2x   	1   	BCC*
A210197	u	1    	1    	1    	x+1   	1    	1   	BCOT
A210198	v	1    	1    	1    	x+1   	1    	1   	BCEN
A210199	u	1    	1    	1    	x+1   	x    	1   	DFT
A210200	v	1    	1    	1    	x+1   	x    	1   	DFO*
A210201	u	1    	1    	1    	x+1   	2x   	1   	BFP
A210202	v	1    	1    	1    	x+1   	2x   	1   	BF
A210203	u	1    	1    	1    	x+1   	x+1  	1   	BDOP
A210204	v	1    	1    	1    	x+1   	x+1  	1   	BCDN*
A210211	u	x    	1    	1    	1     	2x   	1   	BCFN
A210212	v	x    	1    	1    	1     	2x   	1   	BFN
A210213	u	x    	1    	1    	1     	x+1  	1   	CFFN
A210214	v	x    	1    	1    	1     	x+1  	1   	CFFO
A210215	u	x    	1    	1    	x     	x    	1   	BCDFT^
A210216	v	x    	1    	1    	x     	x    	1   	BCFO^
A210217	u	x    	1    	1    	x     	2x   	1   	CDF^
A210218	v	x    	1    	1    	x     	2x   	1   	BCF^
A210219	u	x    	1    	1    	x     	x+1  	1   	CNSTF*
A210220	v	x    	1    	1    	x     	x+1  	1   	FNNT*
A104698	u	x    	1    	1    	2x    	x+1  	1   	CENS*
A210220	v	x    	1    	1    	2x    	x+1  	1   	DNNT*
A210223	u	x    	1    	1    	2x    	x    	1   	CD^
A210224	v	x    	1    	1    	2x    	x    	1   	CO^
A210225	u	x    	1    	1    	2x    	x+1  	1   	CNP
A210226	v	x    	1    	1    	2x    	x+1  	1   	NOT
A210227	u	x    	1    	1    	2x    	2x   	1   	CDP^
A210228	v	x    	1    	1    	2x    	2x   	1   	C^
A210229	u	x    	1    	1    	x+1   	1    	1   	CFNN
A210230	v	x    	1    	1    	x+1   	1    	1   	CCN
A210231	u	x    	1    	1    	x+1   	x    	1   	CNT
A210232	v	x    	1    	1    	x+1   	x    	1   	NN*
A210233	u	x    	1    	1    	x+1   	2x   	1   	CNP
A210234	v	x    	1    	1    	x+1   	2x   	1   	BN
A210235	u	x    	1    	1    	x+1   	x+1  	1   	CCFPT*
A210236	v	x    	1    	1    	x+1   	x+1  	1   	CFN*
A124927	u	x    	x    	1    	1     	1    	1   	BCDEET*
A210042	v	x    	1    	1    	x+1   	x+1  	1   	BDEOT*
A210216	u	x    	x    	1    	1     	x    	1   	BCFO^
A210215	v	x    	x    	1    	1     	x    	1   	BCDFT^
A210549	u	x    	x    	1    	1     	2x   	1   	BCF^
A210550	v	x    	x    	1    	1     	2x   	1   	BDF^
A172431	u	x    	x    	1    	1     	x+1  	1   	CEFN*
A210551	v	x    	x    	1    	1     	x+1  	1   	CFOT*
A210552	u	x    	x    	1    	x     	1    	1   	BBCFNO
A210553	v	x    	x    	1    	x     	1    	1   	BNNFB
A208341	u	x    	x    	1    	x     	x+1  	1   	BCFFN
A210554	v	x    	x    	1    	x     	x+1  	1   	BNFFT
A210555	u	x    	x    	1    	2x    	1    	1   	BCNN
A210556	v	x    	x    	1    	2x    	1    	1   	BENP
A210557	u	x    	x    	1    	2x    	x+1  	1   	CNP
A210558	v	x    	x    	1    	2x    	x+1  	1   	N
A210559	u	x    	x    	1    	x+1   	1    	1   	CEF
A210560	v	x    	x    	1    	x+1   	1    	1   	OFNS
A210561	u	x    	x    	1    	x+1   	x    	1   	BCNP^
A210562	v	x    	x    	1    	x+1   	x    	1   	BDP*^
A210563	u	x    	x    	1    	x+1   	2x   	1   	CFP^
A210564	v	x    	x    	1    	x+1   	2x   	1   	DF^
A013609	u	x    	x    	1    	x+1   	x+1  	1   	BCEPT*
A209757	v	x    	x    	1    	x+1   	x+1  	1   	BCOS*
A209819	u	x    	2x   	1    	x+1   	x    	1   	CFN^
A209820	v	x    	2x   	1    	x+1   	x    	1   	DF^
A209996	u	x    	2x   	1    	x+1   	2x   	1   	CP^
A209998	v	x    	2x   	1    	x+1   	2x   	1   	DP^
A209999	u	x    	x+1  	1    	1     	x+1  	1   	FN*
A210287	v	x    	x+1  	1    	1     	x+1  	1   	CFT*
A210565	u	x    	x+1  	1    	x     	1    	1   	FNT*
A210595	v	x    	x+1  	1    	x     	1    	1   	FNNT
A210598	u	x    	x+1  	1    	x+1   	2x   	1   	FN*
A210599	v	x    	x+1  	1    	x+1   	2x   	1   	FN
A210600	u	x    	x+1  	1    	x+1   	x+1  	1   	BF*
A210601	v	x    	x+1  	1    	x+1   	x+1  	1   	BF*
A210597	u	2x   	1    	1    	x+1   	1    	1   	BF
A210601	v	2x   	1    	1    	x+1   	1    	1   	BFN*
A210603	u	2x   	1    	1    	x+1   	x+1  	1   	BF
A210738	v	2x   	1    	1    	x+1   	x+1  	1   	CBF*
A210739	u	2x   	x    	1    	x+1   	x    	1   	CF^
A210740	v	2x   	x    	1    	x+1   	x    	1   	DF*^
A210741	u	2x   	x    	1    	x+1   	x+1  	1   	BCFO
A210742	v	2x   	x    	1    	x+1   	x+1  	1   	CFO*
A210743	u	2x   	x+1  	1    	x+1   	1    	1   	F
A210744	v	2x   	x+1  	1    	x+1   	1    	1   	FN
A210747	u	2x   	x+1  	1    	x+1   	x+1  	1   	FF
A210748	v	2x   	x+1  	1    	x+1   	x+1  	1   	CFF*
A210749	u	x+1  	1    	1    	x+1   	2x   	1   	BCF
A210750	v	x+1  	1    	1    	x+1   	2x   	1   	BF
A210751	u	x+1  	x    	1    	x+1   	2x   	1   	FNT
A210752	v	x+1  	x    	1    	x+1   	2x   	1   	FN
A210753	u	x+1  	x    	1    	x+1   	x+1  	1   	BNZ*
A210754	v	x+1  	x    	1    	x+1   	x+1  	1   	BCT*
A210755	u	x+1  	2x   	1    	x+1   	x+1  	1   	N*
A210756	v	x+1  	2x   	1    	x+1   	x+1  	1   	CT*
A210789	u	1    	x    	0    	x+2   	x-1  	0   	CFFN
A210790	v	1    	x    	0    	x+2   	x-1  	0   	CEFF
A210791	u	1    	x    	0    	x+2   	x-1  	0   	CFNP
A210792	v	1    	x    	0    	x-1   	x+2  	0   	CF
A210793	u	1    	x+1  	0    	x+2   	x-1  	0   	CFNP
A210794	v	1    	x+1  	0    	x+2   	x-1  	0   	FPP
A210795	u	1    	x    	1    	x+2   	x-1  	0   	FN
A210796	v	1    	x    	1    	x+2   	x-1  	0   	FO
A210797	u	1    	x    	1    	x+2   	x-1  	1   	CF
A210798	v	1    	x    	1    	x+2   	x-1  	1   	F
A210799	u	1    	x+1  	1    	x+2   	x-1  	0   	FN
A210800	v	1    	x+1  	1    	x+2   	x-1  	0   	F
A210801	u	1    	x+1  	1    	x+2   	x-1  	1   	FN
A210802	v	1    	x+1  	1    	x+2   	x-1  	1   	F
A210803	u	1    	x    	1    	x-1   	x+3  	0   	F*
A210804	v	1    	x    	1    	x-1   	x+3  	0   	F*
A210805	u	1    	x    	0    	x+2   	x-1  	1   	CFFN
A210806	v	1    	x    	0    	x+2   	x-1  	1   	FF
A210858	u	1    	x    	0    	x+n   	x    	0   	CFT*
A210859	v	1    	x    	0    	x+n   	x    	0   	FN*
A210860	u	1    	x+1  	0    	x+n   	x    	0   	F
A210861	v	1    	x+1  	0    	x+n   	x    	0   	F*
A210862	u	1    	x    	1    	x+n-1 	x    	0   	FN
A210863	v	1    	x    	1    	x+n-1 	x    	0   	FS
A210864	u	1    	x    	1    	x+n   	x    	0   	FN
A210865	v	1    	x    	1    	x+n   	x    	0   	FT
A210866	u	1    	x    	0    	x+n   	x   -	x   	CFT
A210867	v	1    	x    	0    	x+n   	x   -	x   	FN
A210868	u	1    	x    	0    	x+1   	x-1  	0   	BCFN
A210869	v	1    	x    	0    	x+1   	x-1  	0   	BBCFNZ
A210870	u	1    	x    	0    	x+1   	x-1  	1   	CFFN
A210871	v	1    	x    	0    	x     	x    	1   	CFF
A210872	u	x    	1   -	1    	x     	x    	1   	BDFZ^
A210873	v	x    	1   -	1    	x+1   	x-1  	1   	BCFN^
A210876	u	x    	1    	1    	x     	x    	x   	BCCF^
A210877	v	x    	1    	1    	x     	x    	x   	BDFNZ^
A210878	u	x    	2x   	0    	x+1   	x    	1   	DFZ^
A210879	v	x    	2x   	0    	x+1   	x    	1   	FC*^