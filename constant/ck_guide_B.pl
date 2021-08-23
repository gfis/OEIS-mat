#!perl
# Extract parameters from Clark Kimberling's guides
# @(#) $Id$
# 2021-08-22, Georg Fischer
#
#:# Usage:
#:#   perl ck_guide_B.pl [-d debug] > output
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
    next if $line !~ m{\A\=};
    $line =~ s/\s+\Z//; # chompr
    $line =~ s{[ \.]}{}g; # remove spaces and dots
    $line =~ s{pi}{Pi}g;
    $line =~ s{r\'(\d+)}{sqrt\($1\)}g;
    my ($opt, $cc, $name, $a0, $r, $h);
    ($opt, $a0, $cc, $name) = split(/\t/, $line);
    if ($opt =~ m{\=B\=}) {
        # r=2^(3/2)-1; h=-1/2; s=r/(r-1);
        # Table[Floor[n*r+h], {n, 1, 120}]  (* A184736 *)
        # Table[Floor[n*s+h-h*s], {n, 1, 120}] (* A184737 *)
        $name =~ s{ and }{,}g;
        $name =~ s{ }{}g;
        if (0) {
        } elsif ($name =~ m{r\=([^\,\;]+)}) {
            $rsave = $1;
            $asave = $a0;
            if ($name =~ m{h\=([^\,\;]+)}) {
                $hsave = $1;
            }
        } elsif ($name =~ m{s\=([^\,\;]+)}) {
            print join("\t", $opt, sprintf("%-6s\t%-12s",$hsave, $rsave), $asave, $a0) . "\n";
        }
    }
} # while <DATA>
__DATA__
#--------------------------------
=B=	A184618	null	floor(n*r + h), where r=sqrt(2), h=1/3; complement of A184619.	nonn,	1..10000	nyi
=B=	A184619	null	floor((n-h)*s+h), where s=2+sqrt(2), h=1/3; complement of A184618.	nonn,	1..10000	nyi

=B=	A184620	null	floor(n*r+h), where r=sqrt(2), h=1/4; complement of A184621.	nonn,	1..10000	nyi
=B=	A184621	null	floor((n-h)*s+h), where s=2+sqrt(2), h=1/4; complement of A184620.	nonn,	1..10000	nyi

=B=	A184622	null	floor(n*r+h), where r=sqrt(2), h=-1/3; complement of A184623.	nonn,	1..10000	nyi
=B=	A184623	null	floor((n-h)*s+h), where s=2+sqrt(2), h=-1/3; complement of A184622.	nonn,	1..10000	nyi

=B=	A184624	null	floor(n*r +h), where r=sqrt(2), h=-1/4; complement of A184619.	nonn,	1..10000	nyi
=B=	A184625	null	floor((n-h)*s +h), where s=2+sqrt(2), h=-1/4; complement of A184624.	nonn,	1..10000	nyi

=B=	A184626	null	floor(n*r+h), where r=sqrt(3), h=1/4; complement of A184627.	nonn,synth	1..120	nyi
=B=	A184627	null	floor((n-h)*s+h), where s=(3+sqrt(3))/2, h=1/4; complement of A184626.	nonn,synth	1..120	nyi

=B=	A184638	null	floor(n*r+h), where r=sqrt(3), h=-1/2; complement of A184653.	nonn,synth	1..116	nyi
=B=	A184653	null	floor(n*s+h-h*s), where s=(3+sqrt(3))/2, h=-1/2; complement of A184638.	nonn,synth	1..97	nyi

=B=	A184654	null	floor(n*r+h), where r=sqrt(3), h=-2/3; complement of A184655.	nonn,synth	1..120	nyi
=B=	A184655	null	floor(n*s+h-h*s), where s=(3+sqrt(3))/2, h=-2/3; complement of A184654.	nonn,synth	1..97	nyi

=B=	A184656	null	floor(n*r+h), where r=(1+sqrt(5))/2, h=-1/2; complement of A184657.	nonn,synth	1..120	nyi
=B=	A184657	null	floor(n*s+h-h*s), where s=(3+sqrt(5))/2, h=-1/2; complement of A184656.	nonn,synth	1..120	nyi

=B=	A184658	null	floor(n*r+h), where r=(1+sqrt(5))/2, h=-1/3; complement of A184659.	nonn,synth	1..120	nyi
=B=	A184659	null	floor(n*s+h-h*s), where s=(3+sqrt(5))/2, h=-1/3; complement of A184658.	nonn,synth	1..115	nyi

=B=	A184732	null	floor(n*r+h), where r=(1+sqrt(5))/2, h=-1/4; complement of A184733.	nonn,synth	1..120	nyi
=B=	A184733	null	floor(n*s+h-h*s), where s=(3+sqrt(5))/2, h=-1/4; complement of A184732.	nonn,synth	1..120	nyi

=B=	A184734	null	floor(n*r+h), where r=(1+sqrt(5))/2, h=1/3; complement of A184735.	nonn,synth	1..120	nyi
=B=	A184735	null	floor(n*s+h-h*s), where s=(3+sqrt(5))/2, h=1/3; complement of A184734.	nonn,synth	1..120	nyi

=B=	A184736	null	floor(n*r+h), where r=-1+2^(3/2), h=-1/2; complement of A184735.	nonn,synth	1..120	nyi
=B=	A184737	null	floor(n*s+h-h*s), where s=-1+2^(3/2), h=-1/2; complement of A184736.	nonn,synth	1..120	nyi

=B=	A184738	null	floor(n*r+h), where r=-1+sqrt(5), h=1/2; complement of A184735.	nonn,synth	1..120	nyi
=B=	A184739	null	floor(n*s+h-h*s), where s=3+sqrt(5), h=1/2; complement of A184738.	nonn,synth	1..120	nyi

=B=	A184740	null	floor(n*r+h), where r=(e-1), h=-1/2; complement of A184741.	nonn,synth	1..120	nyi
=B=	A184741	null	floor(n*s+h-h*s), where s=(e-1)/(e-2), h=-1/2; complement of A184740.	nonn,synth	1..120	nyi

=B=	A184742	Sequ	floor(n*r + h), where r = sqrt(Pi), h = -1/2;	nonn,	1..5000	floor3
=B=	A184743	Comp	floor(n*s + h - h*s), where s = sqrt(Pi)/(sqrt(Pi)-1), h = -1/2; complement of A184742.	nonn,	1..5000	compseq

=B=	A184744	null	floor(n*r+h), where r=1+1/e, h=1/2; complement of A184745.	nonn,synth	1..120	nyi
=B=	A184745	null	floor(n*(e-1/2)+1/2), where s = sqrt(Pi)/(sqrt(Pi)-1), h = -1/2; complement of A184744.	nonn,synth	1..120	nyi

=B=	A184746	null	floor(n*r+h), where r=1+1/sqrt(5), h=1/2; complement of A184747.	nonn,synth	1..120	nyi
=B=	A184747	null	floor(n*s+h-h*s), where s=1+sqrt(5), h=1/2; complement of A184746.	nonn,synth	1..120	nyi

=B=	A184748	null	floor(n*r+h), where r=4-5^(1/2), h=-1/2; complement of A184749.	nonn,synth	1..120	nyi
=B=	A184749	null	floor(n*s+h-h*s), where s=(7+sqrt(5))/4, h=-1/2; complement of A184748.	nonn,synth	1..120	nyi
