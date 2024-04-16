#!perl

# Extract simple formulas for MUltiTransformationSequence
# @(#) $Id$
# 2024-04-15, Georg Fischer
#
#:# Usage:
#:#   perl multraf_simple.pl [-d debug] input.seq4 > output.seq4
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
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
#----------------
my $line;
my ($aseqno, $callcode, $offset, $name, $rest, @rseqnos, @naturals, $cond);

while (<>) { # read infile(s)
    $line = $_;
    next if $line !~ m{\AA\d}; # does not start with A-number
    $line =~ s/\s+\Z//; # chompr
    my ($form, $natlist, $rnolist);
    ($aseqno, $callcode, $offset, $form, $cond, $natlist, $rnolist, $name) = split(/\t/, $line);
    next if $callcode !~ m{\Amultra}; # select CC "multraf"
    my $puren = 1;
    @rseqnos  = map {
        my $anon = $_;
        if ($anon =~ m{(A\d+)\(n\)}) {
          $anon = "new $1()";
        } else {
          $puren = 0;
        }
        $anon; # return for map
        } split(/\,/, $rnolist);
    @naturals = split(/\;/, $natlist);
    if (0) {
    } elsif ($form =~ m{\A[nAI\d\+\-]+\Z}) {
    	
    
    if (scalar(@rseqnos) > 0) {
        print        join("\t", $aseqno, $callcode, $offset, $name, $cond, join(",", @naturals), join(",", @rseqnos), $old_name) . "\n";
    } else {                                                                                                        
        print        join("\t", $aseqno, "lambdan", $offset, $name, $cond, join(",", @naturals)                     , $old_name) . "\n";
    }
    
} # while <>
__DATA__
A097684	multraf	0	A0+I0	for	1	A056655(n)	A056655(n) + 1 for all n >
A277830	multraf	0	A0+I0	for	1	A083449(n)	A083449(n) + 1 for n <
A293407	multraf	0	A0+I0	for	1	A152738(n)	A152738(n) + 1 for n > 0
A270383	multraf	0	A0+I0	for	2	A067274(n)	A067274(n) + 2 for n >
A347102	multraf	0	A0+I0*A056239(A064989(A1))		2	A007814(n),A347123(n)	A007814(n) + 2*A056239(A064989(A347123(n)))
A086275	multraf	0	A0+I0*A1+A2		2	A059841(n),A005089(n),A005091(n)	A059841(n) + 2*A005089(n) + A005091(n)
A369359	multraf	0	A0+I0*A1-I1*A2	for	2,2	A002426(n),A002426(n-1),A001006(n-1)	A002426(n) + 2*A002426(n-1) - 2*A001006(n-1) for n > 0
A103745	multraf	0	A0+I0^(n-I1)		2,1	A103528(n)	A103528(n) + 2^(n-1)
A369001	multraf	0	A0+[A1			A353557(n),A007814(n)	A353557(n) + [A007814(n)
A225825	multraf	0	A0+c(n)			A157779(n)	A157779(n) + c(n)
A361003	multraf	0	A0+floor((n-I0)/I1)		1,2	A000005(n)	A000005(n) + floor((n-1)/2)
A176629	multraf	0	A0-(-I0)^A1		1	A001358(n),A001358(n)	A001358(n) - (-1)^A001358(n)
A163975	multraf	0	A0-(-I0)^A1		1	A141468(n),A141468(n)	A141468(n) - (-1)^A141468(n)
A293436	multraf	0	A0-(A1*n)			A005092(n),A010056(n)	A005092(n) - (A010056(n)*n)
A293235	multraf	0	A0-(A1*n)			A035316(n),A010052(n)	A035316(n) - (A010052(n)*n)
A357698	multraf	0	A0-(A1*n)			A073185(n),A212793(n)	A073185(n) - (A212793(n)*n)
