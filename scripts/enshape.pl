#!perl

# @(#) $Id$
# 2024-06-30, Georg Fischer
#
#:# Filter seq4 records and build a list of words behind the formula, condense the latter
#:# Usage:
#:#   perl enshape.pl [-d debug] {-en|-de} infile.seq4 > outfile.seq4
#:#       -d debugging mode: 0=none, 1=some, 2=more
#:#       -en enshape
#:#       -de deshape
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
my $direction = "en";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  eq "-d") {
        $debug     =  shift(@ARGV);
    } elsif ($opt  =~ m{\A\-(de|en)\Z}) {
        $direction =  $1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($aseqno, $callcode, $offset, $form, $inits, $seqlist, @rest, $lambda);
my $iparm = 0; # $(PARM1)
my @parms;
#while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_;
    if ($line =~ m{\AA\d+\s\w+\t\-?\d+\t\S}) {
        ($aseqno, $callcode, $offset, @parms) = split(/\t/, $line);
        if ($direction eq "en") {
            my $form = $parms[$iparm];
            $form =~ s{ }{}g;
            my @list = split(/(\w+)/, $form);
            my $shape = "";
            my $extra = "";
            for (my $ix = 0; $ix < scalar(@list); $ix ++) {
                my $elem = $list[$ix];
                if (0) {
                } elsif ($elem =~ m{\A\d+\Z}) { # digits
                    $shape .= "d";
                    $extra .= ",$elem";
                } elsif ($elem =~ m{\A[i-n]\Z}) { # index variable n, k ...
                    $shape .= "n";
                    $extra .= ",$elem";
                } elsif ($elem =~ m{\A[A-Z]\d{6}\Z}) { # A/J/...-number 
                    $shape .= "a";
                    $extra .= ",$elem";
                } elsif ($elem =~ m{\A[A-Za-z]+[0-9]*\Z}) { # function
                    $shape .= "f";
                    $extra .= ",$elem";
                } elsif ($elem =~ m{\A[^A-Za-z0-9]+\Z}) { # punctuation
                    $shape .= "$elem";
                } elsif ($elem eq "") { # empty - ignore
                } else {
                    print "# invalid: shape=\"$shape\", elem=\"$elem\"\n";
                }
            } # for $ix
            $extra =~ s{\A\,}{};
            $parms[$iparm] = "$shape;    $extra";
            print join("\t", $aseqno, $callcode, $offset, @parms, $form) . "\n";
            # -en
        } else { # direction "de"
            my $form = "";
            my ($shape, $extra) = split(/\; */, $parms[$iparm]);
            my @elist = split(/\,/,    $extra);
            my $ie = 0;
            foreach my $elem(split(/(\w+)/, $shape)) {
                if (0) {
                } elsif ($elem =~ m{\A[a-z]\Z}) { # single lower case letter
                    $form .= $elist[$ie ++];
                } else { # punctuation + uppercase letters
                    $form .= $elem;
                }
            } # for $ix
            
            $parms[$iparm] = $form;
            print join("\t", $aseqno, $callcode, $offset, @parms) . "\n";
            # -de
        } 
    } else {
        print "$line\n";
    }
} # while
__DATA__
A243035	lsmtraf	0	9*10^(F000120(n)-1)	"1,2,3"
A229361	lsmtraf	0	97+41*Z2(n)+21*3^n+13*4^n+8*5^n+5*6^n+3*7^n+2*8^n+9^n+10^n
A163545	lsmtraf	0	D000290(J059252(n))+D000290(J059253(n))
A163547	lsmtraf	0	D000290(J059253(n))+D000290(J059252(n))	"1,2,3"
A365161	lsmtraf	0	D001223(J059305(n)-1)	"1,6,1"
A120355	lsmtraf	0	D002034(J007677(n))	""
A162455	lsmtraf	0	D002061(F000142(J051856(n+1))+1)
A324115	lsmtraf	0	D002487(E323244(n))
A131822	lsmtraf	0	D003961(J036035(n-1))

<->

 A243035	lsmtraf	0	d*d^(A(n)-d);9,10,F000120,n,1	"1,2,3"	9*10^(F000120(n)-1)
 A229361	lsmtraf	0	d+d*f(n)+d*d^n+d*d^n+d*d^n+d*d^n+d*d^n+d*d^n+d^n+d^n;97,41,Z2,n,21,3,n,13,4,n,8,5,n,5,6,n,3,7,n,2,8,n,9,n,10,n	97+41*Z2(n)+21*3^n+13*4^n+8*5^n+5*6^n+3*7^n+2*8^n+9^n+10^n
 A163545	lsmtraf	0	A(A(n))+A(A(n));D000290,J059252,n,D000290,J059253,n	D000290(J059252(n))+D000290(J059253(n))
 A163547	lsmtraf	0	A(A(n))+A(A(n));D000290,J059253,n,D000290,J059252,n	"1,2,3"	D000290(J059253(n))+D000290(J059252(n))
 A365161	lsmtraf	0	A(A(n)-d);D001223,J059305,n,1	"1,6,1"	D001223(J059305(n)-1)
 A120355	lsmtraf	0	A(A(n));D002034,J007677,n	""	D002034(J007677(n))
 A162455	lsmtraf	0	A(A(A(n+d))+d);D002061,F000142,J051856,n,1,1	D002061(F000142(J051856(n+1))+1)
 A324115	lsmtraf	0	A(A(n));D002487,E323244,n	D002487(E323244(n))
 A131822	lsmtraf	0	A(A(n-d));D003961,J036035,n,1	D003961(J036035(n-1))
