#!perl

# @(#) $Id$
# 2024-06-28, Georg Fischer
#
#:# Filter seq4 records and determine callcodes lambdin/sintrif/multraf
#:# Usage:
#:#   perl lsmtraf.pl infile.seq4 > outfile.seq4
#
# Any codes J are extracted into $(PARM3), other codes (D|E|F|K|M) remain.
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my ($aseqno, $callcode, $offset, $form, $inits, $seqlist, @rest, $lambda);
my %jhash;
my @jseqs;
#while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_;
    my $nok = 0;
    #                1    1  2      2  3      34  4
    if ($line =~ m{\A(A\d+)}) {
        ($aseqno, $callcode, $offset, $form, $inits, $seqlist, @rest) = split(/\t/, $line . "\t_\t_\t_");
        if ($inits eq "_") {
            $inits = "\"\"";
        }
        %jhash = ();
        @jseqs = ();
        my $jx = 0;
        #                 1 2     21 (  )
        while ($form =~ s{(J(\d{6}))\(n\)}{I$2\(n\)}) {
            $jhash{$1} = $jx ++;
            push(@jseqs, "new A$2()");
        }
        if (0) {
        } elsif (scalar(keys(%jhash)) == 0) {
            $callcode = "lambd" . (($inits =~ m{\A(|\"\")\Z}) ? "a" : "i") . "n"; # "lambdan" or "lambdin"
            $lambda = "n -> ";
        } elsif (scalar(keys(%jhash)) == 1) {
            $callcode = "sintrif";
            $lambda = "(term, n) -> ";
            foreach my $jseq (keys(%jhash)) {
                my $iseq = "I" . substr($jseq, 1);
                $form =~ s{$iseq\(n\)}{term}g;
            }
        } elsif (scalar(keys(%jhash)) >= 2) {
            $callcode = "multraf";
            $lambda = "(self, n) -> ";
            foreach my $jseq (sort(keys(%jhash))) {
                my $iseq = "I" . substr($jseq, 1);
                $form =~ s{$iseq\(n\)}{self\.s\($jhash{$jseq}\)}g;
            }
        }
        # checks
        if (1) {
        } elsif ($form =~ m{J\d+\(}) {
            $nok ="J(x)";
        } elsif ($form =~ m{[\+\-\*\/\^\!\.\,]}) {
            $nok ="arit";
        }
        $seqlist = join(", ", @jseqs);
        if ($nok eq "0") {
            print        join("\t", $aseqno, $callcode,         $offset, "$lambda$form", $inits, $seqlist, @rest) . "\n";
        } else {
            print STDERR join("\t", $aseqno, "#$callcode $nok", $offset, "$lambda$form", $inits, $seqlist, @rest) . "\n";
        }
    } else {
        print STDERR "$line\n";
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
