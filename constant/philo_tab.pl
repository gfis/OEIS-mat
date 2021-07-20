#!perl

# Extract parameters from the table https://oeis.org/A195284 and A195304
# @(#) $Id$
# 2021-07-17, Georg Fischer
#
#:# Usage:
#:#   perl philo_tab.pl [-d debug] > philo_tab.tmp
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $ignore = 1;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{i}) {
        $ignore    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $offset = 0;
while (<DATA>) {
    my $line = $_;
    next if $line !~ m{\A\=};
    $line =~ s/\s+\Z//; # chompr
    $line =~ s{ }{}g; # remove spaces
    $line =~ s{r\'(\w+)}{sqrt\($1\)}g; # replace r' -> sqrt()
    my ($opt, $a, $b, $c, @ans) = split(/\t/, $line);
    my ($f, $A, $B, $C, $P);
    if (0) {
    } elsif ($opt eq "=1=") {
        # %C More generally, for arbitrary right triangle (a,b,c) with a<=b<c, 
        #let f=2*a*b/(a+b+c). Then, for P=I,
        # %C (A)=f*sqrt((a^2+(b+c)^2)/(b+c))
        # %C (B)=f*sqrt((b^2+(c+a)^2)/(c+a))
        # %C (C)=f*sqrt(2)
        # Philo(ABC,P)=((A)+(B)+(C))/(a+b+c)
        $f = "2*$a*$b/($a+$b+$c)";
        $A = ("$f*sqrt($a^2+($b+$c)^2)/($b+$c)");
        $B = ("$f*sqrt($b^2+($c+$a)^2)/($c+$a)");
        $C = ("$f*sqrt(2)");
        $P = ("($A+$B+$C)/($a+$b+$c)");
        &output($ans[0], $A);
        &output($ans[1], $B);
        &output($ans[2], $C);
        &output($ans[3], $P);
    } elsif ($opt eq "=2=") {
    	# derivative, Nsolve -> nyi
    }
} # while <DATA>
#----
sub output {
    my ($aseqno, $expr) = @_;
    if ($aseqno =~ m{\AA[0-9]}) {
        print join("\t", $aseqno, "post", 0, "$expr") . "\n";
    }
} # output
__DATA__
A195284		Decimal expansion of shortest length of segment from side AB through incenter to side AC in right triangle ABC with sidelengths (a,b,c)=(3,4,5); i.e., decimal expansion of 2*sqrt(10)/3.		94
%I
%S 2,1,0,8,1,8,5,1,0,6,7,7,8,9,1,9,5,5,4,6,6,5,9,2,9,0,2,9,6,2,1,8,1,2,
%T 3,5,5,8,1,3,0,3,6,7,5,9,5,5,0,1,4,4,5,5,1,2,3,8,3,3,6,5,6,8,5,2,8,3,
%U 9,6,2,9,2,4,2,6,1,5,8,8,1,4,2,2,9,4,9,8,7,3,8,9,1,9,5,3,3,5,3,0
%N Decimal expansion of shortest length of segment from side AB through incenter to side AC in right triangle ABC with sidelengths (a,b,c)=(3,4,5); i.e., decimal expansion of 2*sqrt(10)/3.
%C Apart from the first digit, the same as A176219 (decimal expansion of 2+2*sqrt(10)/3).
%C The Philo line of a point P inside an angle T is the shortest segment that crosses T and passes through P. Philo lines are not generally Euclidean-constructible.
%C ...
%C Suppose that P lies inside a triangle ABC. Let (A) denote the shortest length of segment from AB through P to AC, and likewise for (B) and (C). The Philo number for ABC and P is here introduced as the normalized sum ((A)+(B)+(C))/(a+b+c), denoted by Philo(ABC,P).
%C ...
%C Listed below are examples for which P=incenter (the center, I, of the circle inscribed in ABC, 
%C the intersection of the angle bisectors of ABC); in this list, r'x means sqrt(x), and t=(1+sqrt(5))/2 (the golden ratio).
%C 	a    	b    	c     	(A)     	(B)      	(C)       	Philo(ABC,I)
=1=	3    	4    	5     	A195284   	A002163   	A010466   	A195285
=1=	5    	12   	13    	A195286   	A195288   	A010487   	A195289
=1=	7    	24   	25    	A195290   	A010524   	15/2    	A195292
=1=	8    	15   	17    	A195293   	A195296   	A010524   	A195297
=1=	28   	45   	53    	A195298   	A195299  	A010466   	A195300
=1=	1    	1    	r'2   	A195301   	A195301   	A163960   	A195303
=1=	1    	2    	r'5   	A195340   	A195341   	A195342   	A195343
=1=	1    	3    	r'10  	A195344   	A195345   	A195346   	A195347
=1=	2    	3    	r'13  	A195355   	A195356   	A195357   	A195358
=1=	2    	5    	r'29  	A195359   	A195360   	A195361   	A195362
=1=	r'2  	r'3  	r'5   	A195365   	A195366   	A195367   	A195368
=1=	1    	r'2  	r'3   	A195369   	A195370   	A195371   	A195372
=1=	1    	r'3  	2     	A195348   	A093821   	A120683   	A195380
=1=	2    	r'5  	3     	A195381   	A195383   	A195384   	A195385
=1=	r'2  	r'5  	r'7   	A195386   	A195387   	A195388   	A195389
=1=	r'3  	r'5  	r'8   	A195395   	A195396   	A195397   	A195398
=1=	r'7  	3    	4     	A195399   	A195400   	A195401   	A195402
=1=	1    	r'phi	phi   	A195403   	A195404   	A195405   	A195406
=1=	(phi-1)	phi  	r'3   	A195407   	A195408   	A195409   	A195410

=2=	3....	4....	5......	A195304...	A195305....	A105306...	A195411
=2=	5....	12...	13.....	A195412...	A195413....	A195414...	A195424
=2=	7....	24...	25.....	A195425...	A195426....	A195427...	A195428
=2=	8....	15...	17.....	A195429...	A195430....	A195431...	A195432
=2=	1....	1....	r'2....	A195433.. 	1+A179587..	A195433...	A195436
=2=	1....	2....	r'5....	A195434...	A195435....	A195444...	A195445
=2=	1....	3....	r'10...	A195446...	A195447....	A195448...	A195449
=2=	2....	3....	r'13...	A195450...	A195451....	A195452...	A195453
=2=	r'2..	r'3..	r'5....	A195454...	A195455....	A195456...	A195457
=2=	1....	r'2..	r'3....	A195471...	A195472....	A195473...	A195474
=2=	1....	r'3..	2......	A195475...	A195476....	A195477...	A195478
=2=	2....	r'5..	3......	A195479...	A195480....	A195481...	A195482
=2=	r'2..	r'5..	r'7....	A195483...	A195484....	A195485...	A195486
=2=	r'7..	3....	4......	A195487...	A195488....	A195489...	A195490
=2=	1....	r'phi..	phi....	A195491...	A195492....	A195493...	A195494
=2=	(phi-1)	phi....	r'3....	A195495...	A195496....	A195497...	A195498
