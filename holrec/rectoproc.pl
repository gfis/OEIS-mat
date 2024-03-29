#!perl

# Prepare holonomic recurrences from Maple's rectoproc
# @(#) $Id$
# 2022-07-14, Georg Fischer; CKZ=70
#
#:# Usage:
#:#   cat rectoproc.man \
#:#   | perl rectoproc.pl [-P] > output.seq4
#:#       -p powers a(n-k) -> A^k are already substituted, and normalized
#---------------------------------
use strict;
use integer;
use warnings;

my $debug  = 0;
my $powers = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt  =~ m{p}i) {
        $powers = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my ($max, $min);
my $matrix;
while (<>) {
    s/\s+\Z//;
    next if !m{\AA\d\d+\t};
    my ($aseqno, $callcode, $offset1, $rec, $init) = split(/\t/);
    $rec =~ s{ }{}g;
    $rec =~ s{\,a\(n\)\,remember\)?\:?}{};
    $rec =~ s{\A\(\{}{};
    $rec =~ s{\}}{};
    $rec =~ s{\.}{}g;
    if ($powers == 0) {
        if ($rec =~ s{\,seq\(a\(\w\)\=\[([^\]]+)\]\[\w\]\,\w\=\d\.\.\d+\)}{}) {
            $init = $1;
        } else {
            my @inits = ();
            # print "# \"$rec\"\n";
            #                     1   1    2      2
            while ($rec =~ s{\Aa\((\-?\d+)\)\=(\-?\d+)\,}{}) { # remove leading init assignments
                $inits[$1] = $2;
            }
            #                     1   1    2      2
            while ($rec =~ s{\,a\((\-?\d+)\)\=(\-?\d+)}{})   { # remove trailing init assignments
                $inits[$1] = $2;
            }
            if (! defined($inits[0])) {
                shift(@inits);
                $offset1 = 1;
            }
            $init = join(",", @inits);
        }
        $rec =~ s{\=0}{}g;
        if ($rec =~ s{\=}{\)\+}) {  # aaa=bbb -> -(aaa)+bbb
            $rec = "-($rec";
        } # not "=0"
        if ($rec =~ m{a\(n\+}) { # shift a(n+$max) down
            $max = 0;
            map {
                if ($_ > $max) { $max = $_; }
                } ($rec =~ m{a\(n\+(\d+)\)}g);
            $rec =~ s{n}{\(n\-$max\)}g;
            $rec =~ s{a\(\(n\-$max\)\)}{a\(n-$max\)}g;
            #                       1      12   2
            $rec =~ s{a\(\(n\-$max\)([\+\-])(\d+)\)}{"a\(n" . eval(-$max . "$1$2") . ")"}eg;
        }
        $rec =~ s{a\(n[\+\-]?0?\)}{A\^0}g;
        $rec =~ s{a\(n\-(\d+)\)}{A\^$1}g;
    } # $powers = 0
    $matrix = $rec;
    print "# " . join("\t", $aseqno, "opehol", $offset1, $matrix, $init) . "\n";
    my $tempname = "opehol.tmp";
    open(GP, ">", $tempname) || die "cannot write \"$tempname\"\n";
    my $order = 0;
    map {
        if ($_ > $order) { $order = $_; }
        } ($rec =~ m{A\^(\d+)}g);
    print GP <<"GFis";
read("opehol.gpi");
opehol($aseqno, $offset1, $matrix, $order);
quit;
GFis
    close(GP);
    my $result = `gp -fq $tempname 2>\&1`;
    $result =~ s{\, }{\,}g; # not s{\s}{}g !
    $result =~ s{opehol}{holos};
    print $result;
} # while <>
__DATA__
A221569	rectoproc	0	({a(n)=5*a(n-1)-3*a(n-2)+a(n-3)+15*a(n-4)+3*a(n-5),seq(a(i)=[0,17,59,289,1293,5913][i],i=1..6)},a(n), remember):
A261141	rectoproc	0	({a(n)=a(n-1)+2*a(n-2),a(0)=0,a(1)=1},a(n),remember):
A289684	rectoproc	0	({n*a(n)+2*(-4*n+3)*a(n-1)+12*(n-2)*a(n-2)+8*(2*n-3)*a(n-3),a(0)=1,a(1)=2,a(2)=9,a(3)=42},a(n),remember):

A336182	rectoproc	0	({(24*n^3+176*n^2+416*n+320)*a(n+1)+(279*n^3+2325*n^2+6382*n+5776)*a(n+2)+(18*n^3+168*n^2+514*n+512)*a(n+3)+(3*n^3+31*n^2+104*n+112)*a(n+4),a(0)=1,a(1)=-2,a(2)=-14,a(3)=136},a(n),remember):
