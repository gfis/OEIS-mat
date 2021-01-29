#!perl

# Read generating functions and call FPS to derive a holonomic recurrence
# @(#) $Id$
# 2020-04-15: catalan(x)
# 2020-04-11: -t timeout
# 2020-04-08, Georg Fischer: copied from $(COMMON)/maple.pl
# 
# uses FPS.mpl of Wolfram Koepf, Kassel
#
#:# Usage:
#:#   perl holmaple.pl [-n num] [-t timeout] infile ... > outfile
#:#       -n    number of lines to be processed by one Maple activation (default 64)
#:#       -t    timeout for Maple in s, default 4
#---------------------------------
use strict;
use integer;
use warnings;
use POSIX;

my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my @parts = split(/\s+/, asctime(localtime(time)));  #  "Fri Jun  2 18:22:13 2000\n\0"
#                                             0   1    2 3        4
my $sigtime = sprintf("%s %02d %04d", $parts[1], $parts[2], $parts[4]);
#----
my $mapnum  = 64;
my $timeout = 4;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{n}) {
        $mapnum  = shift(@ARGV);
    } elsif ($opt  =~ m{t}) {
        $timeout = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my $pattern = <<'Gfis';
read "C:\\Program Files\\Maple 2019\\FPS.mpl":
interface(prettyprint=0):
with(gfun):
catalan:= x -> (1/2)*(1-sqrt(1-4*x))/x:
c      := x -> (1/2)*(1-sqrt(1-4*x))/x:
basseli:= (x,y) -> BesselI(x,y):
basselj:= (x,y) -> BesselJ(x,y):

printf("%s\t%s\t%d\t%a\t%s\t%s\n", $(ASEQNO), $(CALLCODE), $(OFFSET), timelimit($(TIMEOUT), diffeqtorec(HolonomicDE($(GF),F(x)),F(x),a(k))), $(GFTYPE), "$(GF)");
Gfis
my ($pat1, $pat5) = split(/\n\n/, $pattern);
#----
my $buffer = ""; # for $mapnum input lines
my $count = 0;
while (<>) {
    next if $_ !~ m{\AA\d\d+\t};
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    my ($aseqno, $callcode, $offset, $gf, $gftype, @rest) = split(/\t/, $line);
    my $copy = $pat5;
    $copy =~ s{\$\(ASEQNO\)}  {$aseqno}g;
    $copy =~ s{\$\(CALLCODE\)}{$callcode}g;
    $copy =~ s{\$\(OFFSET\)}  {$offset}g;
    $copy =~ s{\$\(GF\)}      {$gf}g;
    $copy =~ s{\$\(GFTYPE\)}  {$gftype}g;
    $copy =~ s{\$\(TIMEOUT\)} {$timeout}g;
    $buffer .= "$copy";
    $count ++;
    if ($count % $mapnum == 0) {
        &execute($aseqno);
    }
} # while <>
if (length($buffer) > 0) {
    &execute();
}

sub execute {
	my ($aseqno) = @_;
    my $filename = sprintf("holmaple.tmp"); # $count
    open(MPL, ">", $filename) || die "cannot write to \"$filename\"";
    print MPL "$pat1\n";
    print MPL "$buffer\n";
    $buffer = "";
    close(MPL);
    my $maple = "\"C:/Program Files/Maple 2019/bin.X86_64_WINDOWS/cmaple.exe\"";
    my $cmd = "$maple -q $filename";
    # print STDERR "starting with $aseqno\n";
    my $result = `$cmd`;
    print        "$result\n";
    print STDERR "$result\n";
} # execute
__DATA__
A033297	hosqrt	2	(1-2*x-sqrt(1-4*x))/(2*(1+x))	o
A033321	hosqrt	0	2/(1+x+sqrt(1-6*x+5*x^2))	o
A034256	hosqrt	0	2-(1-16*x)^(1/4)	o
A034687	hosqrt	1	(-1+(1-25*x)^(-1/5))/5	o
A000108	homgf	0	(1-sqrt(1-4*x))/(2*x)	o
A000150	homgf	0	(sqrt(1-4*x^2)-sqrt(1-4*x)-2*x)/(4*x)	o
A000168	homgf	0	1/54*(-1+18*x+(-(12*x-1)^3)^(1/2))/x^2	o
A000207	homgf	0	(12(1+x-2*x^2)+(1-4*x)^(3/2)-3(3+2*x)(1-4*x^2)^(1/2)-4(1-4*x^3)^(1/2))/(24*x^2)	o
A000246	homgf	0	sqrt(1-x^2)/(1-x)	e
A000257	homgf	0	((1-8*x)^(3/2)+8*x^2+12*x-1)/(32*x^2)	o
A000287	homgf	0	x^2-2*x^3/(1+x)+x*(2*x^2-10*x-1+(1-4*x)^(3/2))/(2*(x+2)^3)	o
A000365	homgf	0	x^2*(1-sqrt(1-4*x))*(7+4*x-2*sqrt(1-4*x))/(2(4*x-1)^4)	o
A000407	homgf	0	(1-4*x)^(-3/2)	e
A000473	homgf	0	x*(1-sqrt(1-4*x))*(17+16*x-(10+4*x)*sqrt(1-4*x))/(1-4*x)^(11/2)	o
A000502	homgf	0	x*(1-sqrt(1-4*x))*(105+92*x-(84+76*x)*sqrt(1-4*x))/(1-4*x)^7	o
A000777	homgf	0	(1/x)*(1/2+(6*x-1)/(2*sqrt(1-4*x))-x/(1-x))	o
A000781	homgf	0	1/2*(((sqrt(1-4*x)-7)*x-3*sqrt(1-4*x)+3)/x^2+2/(x-1))	o
A000911	homgf	0	6/(1-4*x)^(5/2)	o
A000913	homgf	0	(-4*x+8*x^2-sqrt(1-4*x)+2*x*sqrt(1-4*x)+3*sqrt(1-4*x^2)-2*sqrt(1-4*x^4))/(8*x^3)	o
A000958	homgf	0	(1-x-(1+x)*sqrt(1-4*x))/(2*x*(x+2))	o
A000984	homgf	0	(1-4*x)^(-1/2)	o

A063886 homgf   0       4*k*a(k)+2*a(k+1)+(-k-2)*a(k+2) o       sqrt((1+2*x)/(1-2*x))
make runholo MATRIX="[[0],[0,4],[2],[-2,-1]]" INIT="	1,2,2,4,6,12,20" DIST=2

read "C:\\Program Files\\Maple 2019\\FPS.mpl":
interface(ansi=false,prettyprint=0):
with(gfun):

c:= x -> (1/2)*(1-sqrt(1-4*x))/x:
timelimit(16, diffeqtorec(HolonomicDE(c(x),F(x)),F(x),a(k)));
