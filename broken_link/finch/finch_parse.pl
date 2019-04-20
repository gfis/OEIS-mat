#!perl

# Parses the HTML version of Steven R. Finch's book "Mathematical Constants" for OEIS A-numbers
# @(#) $Id$
# 2019-04-19, Georg Fischer: copied from ../broken_link/html_change.pl
#
#:# usage:
#:#   perl finch_parse.pl html-version > extract.tsv
#:#       output lines are: aseqno pageno title
#:#---------------------------------
use strict;
use integer;
use warnings;
use utf8;

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d"     # :%02d\+01:00"
        , $year + 1900, $mon + 1, $mday, $hour, $min);  # , $min, $sec, $isdst);
if (scalar(@ARGV) == 0) { # print help and exit
  print `grep -E "^#:#" $0 | cut -b3-`;
  exit;
} # print help
my $debug  = 0;
my $mode   = "list";

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{d}) {
        $debug    =  shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $pageno  = 0;
my $aseqno  = "";
my @aseqnos = "";
my $section = "";
my $count   = 0;
while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if (0) { 
    } elsif ($line =~ m{^\<b\>\d+\.\d+}) { # new section
        $line =~ s{\<\/?b\>}{}g; 
        $line =~ s{\<\/?i\>}{\'\'}g; # <i> to wiki '' italics 
        $line =~ s{\<br\s*\/>}{}g; 
        $line =~ s{\&\#160\;}{ }g;
        $line =~ s{(\.\d) }{$1  };
        $section = &make_utf8($line); 
        print "$section\n" if $debug >= 1;
    } elsif ($line =~ m{^\<a\s+name\=\"?(\d+)}) { # new page
        $pageno = $1;
        print "---------------- page $pageno ----------------\n" if $debug >= 1;
    } elsif ($line =~ m{\W(A\d{6})\W}) { # 
        @aseqnos = ($line =~ m{\W(A\d{6})\W}g);
        print join(", ", @aseqnos) . "\n" if $debug >= 1;
        foreach $aseqno (sort(@aseqnos)) {
        		print join("\t", $aseqno, $pageno, $section) . "\n";
        } # foreach
    }
} # while <INF>
#----
sub make_utf8 {
		my ($line) = @_;
	#	$line =~ s{´a}{\&aacute\;}g;
	#	$line =~ s{´o}{\&oacute\;}g;
	#	$line =~ s{¨o}{\&\#337\;}g;  # ő}g;
#		$line =~ s{\xc2b461}{\xc3a1}g;
#		$line =~ s{\xc2b46f}{\xc2b3}g;
#		$line =~ s{\xc2a86f}{\xc591}g;
		return $line;
} # make_utf8
__DATA__
<b>2.4&#160;Artin’s&#160;Constant</b><br/>
Fermat’s&#160;Little&#160;Theorem&#160;says&#160;that&#160;if&#160;<i>p&#160;</i>is&#160;a&#160;prime&#160;and&#160;<i>n&#160;</i>is&#160;an&#160;integer&#160;not&#160;divisible&#160;by&#160;<i>p</i>,<br/>then&#160;<i>n&#160;p</i>−1&#160;−&#160;1&#160;is&#160;divisible&#160;by&#160;<i>p</i>.<br/>
Consider&#160;now&#160;the&#160;set&#160;of&#160;all&#160;positive&#160;integers&#160;<i>e&#160;</i>such&#160;that&#160;<i>ne&#160;</i>−&#160;1&#160;is&#160;divisible&#160;by&#160;<i>p</i>.<br/>
If&#160;<i>e&#160;</i>=&#160;<i>p&#160;</i>−&#160;1&#160;is&#160;the&#160;smallest&#160;such&#160;positive&#160;integer,&#160;then&#160;<i>n&#160;</i>is&#160;called&#160;a&#160;<b>primitive&#160;root<br/>modulo&#160;</b><i>p</i>.<br/>
For&#160;example,&#160;6&#160;is&#160;a&#160;primitive&#160;root&#160;mod&#160;11&#160;since&#160;none&#160;of&#160;the&#160;remainders&#160;of<br/>
61<i>,&#160;</i>62<i>,&#160;</i>63<i>,&#160;.&#160;.&#160;.&#160;,&#160;</i>69&#160;upon&#160;division&#160;by&#160;11&#160;are&#160;equal&#160;to&#160;1;&#160;thus&#160;<i>e&#160;</i>=&#160;10&#160;=&#160;11&#160;−&#160;1.&#160;However,<br/>6&#160;is&#160;not&#160;a&#160;primitive&#160;root&#160;mod&#160;19&#160;since&#160;69&#160;−&#160;1&#160;is&#160;divisible&#160;by&#160;19&#160;and&#160;<i>e&#160;</i>=&#160;9&#160;<i>&lt;&#160;</i>19&#160;−&#160;1.<br/>
Here&#160;is&#160;an&#160;alternative,&#160;more&#160;algebraic&#160;phrasing.&#160;The&#160;set&#160;<i>Z&#160;p&#160;</i>=&#160;{0<i>,&#160;</i>1<i>,&#160;</i>2<i>,&#160;.&#160;.&#160;.&#160;,&#160;p&#160;</i>−<br/>
1}&#160;with&#160;addition&#160;and&#160;multiplication&#160;mod&#160;<i>p&#160;</i>forms&#160;a&#160;field.&#160;Further,&#160;the&#160;subset&#160;<i>Up&#160;</i>=<br/>
{1<i>,&#160;</i>2<i>,&#160;.&#160;.&#160;.&#160;,&#160;p&#160;</i>−&#160;1}&#160;with&#160;multiplication&#160;mod&#160;<i>p&#160;</i>forms&#160;a&#160;cyclic&#160;group.&#160;Hence&#160;we&#160;see&#160;that<br/>the&#160;integer&#160;<i>n&#160;</i>(more&#160;precisely,&#160;its&#160;residue&#160;class&#160;mod&#160;<i>p</i>)&#160;is&#160;a&#160;primitive&#160;root&#160;mod&#160;<i>p&#160;</i>if&#160;and<br/>only&#160;if&#160;<i>n&#160;</i>is&#160;a&#160;generator&#160;of&#160;the&#160;group&#160;<i>Up</i>.<br/>
Here&#160;is&#160;another&#160;interpretation.&#160;Let&#160;<i>p&#160;&gt;&#160;</i>5&#160;be&#160;a&#160;prime.&#160;The&#160;decimal&#160;expansion&#160;of&#160;the<br/>
fraction&#160;1<i>/&#160;p&#160;</i>has&#160;maximal&#160;period&#160;(=&#160;<i>p&#160;</i>−&#160;1)&#160;if&#160;and&#160;only&#160;if&#160;10&#160;is&#160;a&#160;primitive&#160;root&#160;modulo<br/>
<i>p</i>.&#160;Primes&#160;satisfying&#160;this&#160;condition&#160;are&#160;also&#160;known&#160;as&#160;<b>long&#160;primes&#160;</b>[1–4].<br/>
Artin&#160;[5]&#160;conjectured&#160;in&#160;1927&#160;that&#160;if&#160;<i>n&#160;</i>=&#160;−1<i>,&#160;</i>0<i>,&#160;</i>1&#160;is&#160;not&#160;an&#160;integer&#160;square,&#160;then&#160;the<br/>
set&#160;<i>S</i>(<i>n</i>)&#160;of&#160;all&#160;primes&#160;for&#160;which&#160;<i>n&#160;</i>is&#160;a&#160;primitive&#160;root&#160;must&#160;be&#160;infinite.&#160;Some&#160;remarkable<br/>progress&#160;toward&#160;proving&#160;this&#160;conjecture&#160;is&#160;indicated&#160;in&#160;[6–9].&#160;For&#160;example,&#160;it&#160;is&#160;known<br/>that&#160;at&#160;least&#160;one&#160;of&#160;the&#160;sets&#160;<i>S</i>(2),&#160;<i>S</i>(3),&#160;or&#160;<i>S</i>(5)&#160;is&#160;infinite.<br/>
Suppose&#160;additionally&#160;that&#160;<i>n&#160;</i>is&#160;not&#160;an&#160;<i>r&#160;</i>th&#160;integer&#160;power&#160;for&#160;any&#160;<i>r&#160;&gt;&#160;</i>1.&#160;Let&#160;<i>n</i>&#160;denote<br/>
the&#160;square-free&#160;part&#160;of&#160;<i>n</i>,&#160;equivalently,&#160;the&#160;divisor&#160;of&#160;<i>n&#160;</i>that&#160;is&#160;the&#160;outcome&#160;after&#160;all<br/>factors&#160;of&#160;the&#160;form&#160;<i>d</i>2&#160;have&#160;been&#160;eliminated.&#160;Artin&#160;further&#160;conjectured&#160;that&#160;the&#160;density<br/>of&#160;the&#160;set&#160;<i>S</i>(<i>n</i>),&#160;relative&#160;to&#160;the&#160;primes,&#160;exists&#160;and&#160;equals<br/>
&#160;<br/>
<br/>
<i>C</i>Artin&#160;=<br/>
1&#160;−<br/>
1<br/>
=&#160;0<i>.</i>3739558136&#160;<i>.&#160;.&#160;.</i><br/>
<i>p</i>(&#160;<i>p&#160;</i>−&#160;1)<br/>
<i>p</i><br/>
<i>independently&#160;</i>of&#160;the&#160;choice&#160;of&#160;<i>n</i>,&#160;if&#160;<i>n</i>&#160;≡&#160;1&#160;mod&#160;4.&#160;A&#160;proof&#160;of&#160;this&#160;incredible&#160;conjecture<br/>is&#160;still&#160;unknown.&#160;For&#160;other&#160;cases,&#160;a&#160;rational&#160;correction&#160;factor&#160;is&#160;needed&#160;–&#160;see&#160;[2.4.2]&#160;–&#160;but<br/>
<hr/>
<a name=126></a>P1:&#160;FHB/SPH<br/>
P2:&#160;FHB/SPH<br/>
QC:&#160;FHB/SPH<br/>
T1:&#160;FHB<br/>
CB503-02<br/>
CB503/Finch-v2.cls<br/>
December&#160;9,&#160;2004<br/>
13:46<br/>
Char&#160;Count=<br/>
2.4&#160;Artin’s&#160;Constant<br/>
105<br/>
Artin’s&#160;constant&#160;remains&#160;the&#160;central&#160;feature&#160;of&#160;such&#160;formulas.&#160;Hooley&#160;[10,&#160;11]&#160;proved<br/>that&#160;such&#160;formulas&#160;are&#160;valid,&#160;subject&#160;to&#160;the&#160;truth&#160;of&#160;a&#160;generalized&#160;Riemann&#160;hypothesis.<br/>
A&#160;rapidly&#160;convergent&#160;expression&#160;for&#160;Artin’s&#160;constant&#160;is&#160;as&#160;follows&#160;[12–18].&#160;Define<br/>
<b>Lucas’&#160;sequence&#160;</b>as<br/>
<i>l</i>0&#160;=&#160;2<i>,</i><br/>
<i>l</i>1&#160;=&#160;1<i>,</i><br/>
<i>ln&#160;</i>=&#160;<i>ln</i>−1&#160;+&#160;<i>ln</i>−2<br/>
for&#160;<i>n&#160;</i>≥&#160;2<br/>
and&#160;observe&#160;that&#160;<i>ln&#160;</i>=&#160;<i>ϕn&#160;</i>+&#160;(1&#160;−&#160;<i>ϕ</i>)<i>n</i>,&#160;where&#160;<i>ϕ&#160;</i>is&#160;the&#160;Golden&#160;mean&#160;[1.2].&#160;Then<br/>
<br/>
<br/>
&#160;<br/>
−&#160;1<br/>
<i>n