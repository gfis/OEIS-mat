#!perl

# Extract parameters for CC=filnum ("Numbers k such that... is(semi)prime"
# @(#) $Id$
# 2025-11-19, Georg Fischer: filtpos.pl
#
#:# Usage:
#:#     grep -P "..." $(CAT) \
#:#     | perl isprime.pl [-d debug] > $@.tmp 2> $@.rest.tmp
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
my $COMMON = "../common";
my $ofter_file = "$COMMON/joeis_ofter.txt";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options
#----------------
my $aseqno;
my $offset = 1;
my $line;
my ($callcode, $k, $name, $start, $predicate, $form);
while (<>) {
    s/\s+\Z//; # chompr
    $line = $_;
    my $nok = "";  
    if ($line =~ s{ *Numbers (\w) such that *}{\tfilnum\t0\t0\t}) {
        $k = $1;  
        #               1  1 23      3      2
        $line =~ s{ *is (a )?((semi\-?)?prime)\.?}{};
        $predicate = uc($2);
        ($aseqno, $callcode, $offset, $start, $name) = split(/\t/, $line);
        if ($debug > 0) {
            print join("\t#", $aseqno, $callcode, $offset, $start, $name) . "#\n";
        }
        $form = $name;
        $form =~ s{ }{}g;
        $form =~ s{$k}{k}g;
        $form =~ s{\=A(\d+)}{\tnew A$1()};
        $nok = "";
        if (0) {
        } elsif ($form =~ m{[a-jl-z]}) {
            $nok = "wording";
#            9 (a^a+a)^a+a
#            8 a^a+a+a
#            7 a^a*(a+a*a^a)+a
#            6 (a^a+a)/a
#            5 a^a+a*a
#            5 a+a*a^a+a^a
#            5 (a+a)*a^a+a
#            4 a^a+a^((a+a)/a)+a
#            4 a!+a^a+a

        #                      (1     1 ^2     23  +-  34     4 ^5     5 ) /6     6
        } elsif ($form =~ m{\A\((\d+|k)\^(\d+|k)([\+\-])(\d+|k)\^(\d+|k)\)\/(\d+|k)\Z}) {
#           55 (a^a+a^a)/a
            $form = "k -> { final Q kq = new Q(ZV($1).^($2).$3(ZV($4).^($5)), ZV($6)); return kq.isInteger() && PP(kq.num()); }";

        #                     1     1  2     23      34     4
        } elsif ($form =~ m{\A(\d+|k)\^(\d+|k)([\+\-])(\d+|k)\Z}) {
#           43 a^a+a
            $form = "ZV($1).^($2).$3(ZV($4))";
            &lambda();

        #                     1     1  2     2  3     34     4 5     5
        } elsif ($form =~ m{\A(\d+|k)\*(\d+|k)\^(\d+|k)([\+\-])(\d+|k)\Z}) {
#           21 a*a^a+a
            $form = "ZV($1).*(ZV($2).^($3)).$4(ZV($5))";
            &lambda();

        #                     1     1 ^2     23 +-   3 (4     45 +-   56     6 ) ^7     7
        } elsif ($form =~ m{\A(\d+|k)\^(\d+|k)([\+\-])\((\d+|k)([\+\-])(\d+|k)\)\^(\d+|k)\Z}) {
#           19 a^a+(a+a)^a
            $form = "ZV($1).^($2).$3(ZV($4).$5($6).^($7))";
            &lambda();

        #                     1     1  2     23        34     4  5     56  +-  67    7
        } elsif ($form =~ m{\A(\d+|k)\^(\d+|k)([\+\-\*])(\d+|k)\^(\d+|k)([\+\-])(\d|k)\Z}) {
#           18 a^a*a^a+a
#           15 a^a+a^a+a
            $form = "ZV($1).^($2).$3(ZV($4).^($5)).$6($7)";
            &lambda();

        #                     1     1  2     23      34     4  5     5
        } elsif ($form =~ m{\A(\d+|k)\^(\d+|k)([\+\-])(\d+|k)\^(\d+|k)\Z}) {
#           10 a^a+a^a
            $form = "ZV($1).^($2).$3(ZV($4).^($5))";
            &lambda();

        } else {
            $nok = "unknown";
        }
        if ($nok eq "") {
            print        join("\t", $aseqno, $callcode, $offset, $start, $form, $name) . "\n"; 
        } else {
            my $pattern = $form;
            $pattern =~ s{\d+|k}{a}g;
            $pattern =~ s{[\-]}{\+}g;
            print STDERR join("\t", $aseqno, $callcode, $offset, $start, $pattern, $form, $name) . "\n";
        }
    }
} # while <>  
sub lambda { # put thelambda envelope
            if ($predicate =~ m{semi}i) {
                $form = "k -> Predicates.SEMIPRIME.is($form)";
            } else {
                $form = "k -> PP($form)";
            }
} # lambda
	
#----------------
__DATA__
A087832 Numbers k such that k*primorial(2473)-1 is prime.
A088790 Numbers k such that (k^k-1)/(k-1) is prime.
A089063 Numbers k such that 840*k + 175177943 is a prime.
A089238 Numbers k such that 3*k^2/2 - 1 is a prime.
A089379 Numbers k such that 10^k + k is prime.
A089485 Numbers k such that k^4 + 4^k = A001589(k) is a semiprime.
A089678 Numbers n such that n^n + n! + n^2 + 1 is prime.
A089919 Numbers k such that 3^prime(k) - 2 is prime.
A091907 Numbers k such that (2*k)!/(2*k!)-1 is prime.
A091909 Numbers n such that (2*n)!/(2*n!)+1 is prime.
A091996 Numbers n such that 9*2^(2*n-1) - 1 is prime.
     55 (a^a+a^a)/a
     43 a^a+a
     21 a*a^a+a
     19 a^a+(a+a)^a
     18 a^a*a^a+a
     15 a^a+a^a+a
      9 (a^a+a)^a+a