#!perl

# Prepare holonomic matrix parameters from recurrence table expressions
# @(#) $Id$
# 2022-08-12: copied from rectoproc.pl; superceedes the latter
# 2022-07-14, Georg Fischer; CKZ=70
#
#:# Usage:
#:#   cat rectopost.man \
#:#   | perl rectopost.pl [-P] > output.seq4
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
my ($aseqno, $callcode, $offset1, $rec, $init, $dist, $gftype, $remark);
my ($parm1, $parm2);
$remark = "";
$dist = "0";
$gftype = "0";
while (<>) {
    s/\s+\Z//;
    my $line = $_;
    if (0) {
    } elsif ($line =~ m{\A\s*(sumrec.*)}) {
        $remark = $1;
        # print "remark=$remark\n";
    } elsif ($line =~ m{\AA\d+}) {
        ($aseqno, $callcode, $offset1, $rec) = split(/\t/, $line);
        if ($remark eq "") {
            if (length($rec) <= 128) {
               $remark = $rec;
            }
        } 
        $callcode = length($remark) > 0 ? "holos5" : "holos";
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
        print "# $rec\n";
        my $tempname = "ope2matrix.tmp";
        open(GP, ">", $tempname) || die "cannot write \"$tempname\"\n";
        my $order = 0;
        map {
            if ($_ > $order) { $order = $_; }
            } ($rec =~ m{A\^(\d+)}g);
        print GP <<"GFis";
read("ope2matrix.gpi");
ope2matrix($rec);
quit;
GFis
        close(GP);
        $matrix = `gp -fq $tempname 2>\&1`;
        $matrix =~ s{\s+\Z}{};
        $matrix =~ s{\, }{\,}g; # not s{\s}{}g !
        $init = $order + 1;
        print join("\t", $aseqno, $callcode, $offset1, $matrix, $init, $dist, $gftype, $remark) . "\n";
        print "make runholo MATRIX=\"$matrix\" INIT=\"1\"\n";
        $remark = "";
    } # with aseqno
} # while <>
__DATA__
	sumrecursion((-1)^(n-k)*binomial(n,k)*C(2*(n+k),n+k),k,a(n));
A168595	rectoproc	0	-6*(n-1)*(7*n-2)*(-3+2*n)*a(n-2)-(329*n^3-752*n^2+491*n-84)*a(n-1)+2*a(n)*n*(2*n-1)*(7*n-9)

A091526	rectoproc	0	2*n*(3*n-7)*a(n)=(21*n^2-61*n+48)*a(n-1)+2*(2*n-3)*(3*n-4)*a(n-2)
A072547	rectoproc	0	2*(-n+1)*a(n)+(9*n-17)*a(n-1)+(-3*n+19)*a(n-2)+2*(-2*n+7)*a(n-3)
