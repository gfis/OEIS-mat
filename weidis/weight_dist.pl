#!perl

# Read a b-file for a weight distribution sequence and print the prime factorizations
# @(#) $Id$
# 2020-04-14, Georg Fischer: copied from $(HOLREC)/holnaple.pl
#
#:# Usage:
#:#   perl weight_dist.pl [-s aseqno] b-file [-o outfile]
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
my $aseqno  = "A000000";
my $timeout = 4;
my $outfile = "";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{s}) {
        $aseqno  = shift(@ARGV);
    } elsif ($opt  =~ m{o}) {
        $outfile  = shift(@ARGV);
        open(OUT, ">", $outfile) or die "cannot write \"$outfile\"\n";
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

printf("%s\t\+%d\t%a\n", "$(ASEQNO)", $(INDEX), ifactor($(NUM),easyfunc));
Gfis
my ($pat1, $pat5) = split(/\n\n/, $pattern);
#----
my $buffer = ""; # for $mapnum input lines
my $count = 0;
while (<>) {
    next if $_ !~ m{\A\d};
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    my ($index, $num) = split(/\s+/, $line);
    my $copy = $pat5;
    $copy =~ s{\$\(ASEQNO\)}  {$aseqno}g;
    $copy =~ s{\$\(INDEX\)}   {$index}g;
    $copy =~ s{\$\(NUM\)}     {$num}g;
    $copy =~ s{\$\(TIMEOUT\)} {$timeout}g;
    $buffer .= "$copy";
    $count ++;
} # while <>
if (length($buffer) > 0) {
    &execute($aseqno);
}
if (length($outfile) > 0) {
    close(OUT);
}
print STDERR "\n";
#----
sub execute {
    my ($aseqno) = @_;
    my $filename = sprintf("weight_dist.tmp"); # $count
    open(MPL, ">", $filename) || die "cannot write to \"$filename\"";
    print MPL "$pat1\n";
    print MPL "$buffer\n";
    $buffer = "";
    close(MPL);
    my $maple = "\"C:/Program Files/Maple 2019/bin.X86_64_WINDOWS/cmaple.exe\"";
    my $cmd = "$maple -q $filename";
    # print STDERR "starting with $aseqno\n";
    my $result = `$cmd`;
    $result =~ s{_c\d*\(}{}g;
    $result =~ s{[\(\)\`]}{}g;
    $result =~ s{\*}{ \* }g;
    $result =~ s{\t3([\^ ])}{\t      3$1}g;
    if (length($outfile) > 0) {
        print OUT "$result\n";
    } else {
        print "$result\n";
    }
    print STDERR "$aseqno ";
} # execute
__DATA__
# A151939
0 1
1 0
2 0
3 0
4 0
5 0
6 0
7 856035
8 26537085
9 645102400
10 15869519040
11 355776960840
12 7234131537080
13 135192235752000
14 2336894360856000
15 37546273785247407
16 563194106778711105
17 7917846995071200960
18 104691532490385879360
19 1305889106439211152600
20 15409491455982691600680
21 172439547140774248589760

A000000 0       1
A000000 1       0
A000000 2       0
A000000 3       0
A000000 4       0
A000000 5       0
A000000 6       0
A000000 7       ``(3)^3*``(5)*``(17)*``(373)
A000000 8       ``(3)^3*``(5)*``(17)*``(31)*``(373)
A000000 9       ``(2)^6*``(5)^2*``(17)*``(37)*``(641)
A000000 10      ``(2)^6*``(3)*``(5)*``(17)*``(37)*``(41)*``(641)
A000000 11      ``(2)^3*``(3)*``(5)*``(7)*``(17)*``(97)*``(113)*``(2273)
A000000 12      ``(2)^3*``(5)*``(7)*``(17)*``(61)*``(97)*``(113)*``(2273)
A000000 13      ``(2)^6*``(3)^2*``(5)^3*``(7)*``(17)*``(479)*``(32941)
A000000 14      ``(2)^6*``(3)^2*``(5)^3*``(11)^2*``(17)*``(479)*``(32941)
A000000 15      ``(3)^3*``(17)*``(419)*``(195227113967)
A000000 16      ``(3)^4*``(5)*``(17)*``(419)*``(195227113967)
A000000 17      ``(2)^6*``(3)^3*``(5)*``(37)*``(24768039899497)
A000000 18      ``(2)^6*``(3)*``(5)*``(7)*``(17)*``(37)*``(24768039899497)
A000000 19      ``(2)^3*``(3)*``(5)^2*``(7)*``(17)*``(211)*``(5642949229)*``(15361)
A000000 20      ``(2)^3*``(3)*``(5)*``(7)*``(17)*``(59)*``(211)*``(5642949229)*``(15361)
A000000 21      ``(2)^6*``(3)*``(5)*``(11)*``(17)*``(524945240569)*``(1829827)