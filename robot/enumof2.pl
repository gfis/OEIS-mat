#!perl

# Extract parameters enumof2.jpat: Numbers of the form (i,j) -> f(i,j)
# @(#) $Id$
# 2023-07-26, Georg Fischer: copied from convol.pl
#
#:# Usage:
#:#     perl enumof2.pl [-d mode] jcat25.ext > output.seq4
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options

my $line;
my $name;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if ($line !~ m{\AA\d+}) {
        print STDERR "$line\tno aseqno\n";
        next;
    }
    my ($aseqno, $callcode, $offset, $start1, $start2, $expr, $cond, @rest) = split(/\t/, $line);
    $expr =~ s{\s+\Z}{}; # chomp
    if ($expr =~ s{\A\([a-z]\, *[a-z]\) *\-\> *ZV\(}{}) { # was already a lambda
        $expr =~ s{\)\Z}{};
    }
    my $src_expr = $expr;
    $expr =~ s{\b([a-z])\^2}{$1\*$2}g; # x^2 -> x*x  
    $cond =~ s{\s+\Z}{};
    my %hash = (); # gather the variables here
    map {
        $hash{$_} = 1;
        } $expr =~ m{\b([a-z])\b}g;
    my @lambda = ("i", "j");
    if (scalar(keys(%hash)) == 2) {
        @lambda = sort(keys(%hash));
    } else {
        print STDERR "$line\tno2vars\n";
        next;
    }
    if ($cond =~ m{positive}) {
        $start1 = 1;
        $start2 = 1;
    }
    #          1  12     23  3
    $cond =~ s{(\S)(\<\=?)(\S)}{$1 $2 $3}g;
    #            1     1    2  2
    $cond =~ s{\b([a-z]) \< (\d)}{$1 . "<=" . ($2+1)}eg;
    $cond =~ s{\, +}{\,}g;
    #            1     1     2     2
    $cond =~ s{\b([a-z]) and ([a-z])\b}{$1\,$2}g;
    if (0) {
    } elsif ($cond =~ m{\b[a-z]\,[a-z] \>\= ([1-9])}) {
        $start1 = $1;
        $start2 = $1;
    } else {
        while ($cond =~ s{\b([a-z]) \>\= ([1-9])}{}) {
            my ($var, $val) = ($1, $2); 
            if (0) {
            } elsif ($var eq $lambda[0]) {
                $start1 = $val;
            } elsif ($var eq $lambda[1]) {
                $start2 = $val;
            }
        } # while 
    }

    my $record;
    if ($expr =~ m{\A[a-z0-9\+\-\*\(\) ]+\Z}) { # no "^", no "/"
        $expr = "ZV($expr)";
        $record = join("\t", $aseqno, $callcode, $offset, $start1, $start2, "(" . join(", ", @lambda) .") -> $expr", $cond, $src_expr, @rest);
        print "$record\n";
    } else {
        $expr =~ s{ }{}g;
        $expr =~ s{(\w+)\^(\w+)}{ZV\($1\)\.\^\($2\)}g;
        if ($expr =~ s{([\+\-\*])}{\)\.$1\(}g) {
            $expr .= ")";
        } 
        if ($expr !~m {\AZV\(}) {
        	  $expr = "ZV($expr";
        } 
        $expr =~ s{\)\)}{\)}; # only first orccurence
        $record = join("\t", $aseqno, $callcode, $offset, $start1, $start2, "(" . join(", ", @lambda) .") -> $expr", $cond, $src_expr, @rest);
        print "$record\n";
    }
} # while <>
#----------------
__DATA__
A177763	enumof2	0	0	0	m^5-s*s	, m>=1, s >= 0                                                                                          	Numbers of the form
A253913	enumof2	0	0	0	m^k + m	, with m >= 0 and k > 1                                                                                 	Numbers of the form
A247336	enumof2	0	0	0	m^k - k - 1	 with k > 0 and m > 1                                                                               	Numbers of the form
A099225	enumof2	0	0	0	m^k+k	, with m and k > 1                                                                                        	Numbers of the form
A146748	enumof2	0	0	0	n^k * k^n	, where n,k > 1                                                                                       	Numbers of the form
A303434	enumof2	0	0	0	x*(3*x-1)/2 + 3^y	 with x and y nonnegative integers                                                            	Numbers of the form
