#!perl

# Extract A-numbers and natural number for transform.MUltiTransformationSequence
# @(#) $Id$
# 2024-04-15, Georg Fischer
#
#:# Usage:
#:#   perl multraf_prep.pl [-d debug] input.cut25 > output.seq4
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
    ($aseqno, $callcode, $offset, $name) = split(/\t/, $line);
    my $old_name = $name;
    next if $callcode !~ m{\Amultra}; # select CC "multraf"
    $cond = "";
    if ($name =~ s{(for|\:\;|\bif\b|when)(.*)}{}) {
        $cond = "$1$2";
    }
    $name =~ s{modulo}{mod}g;
    $name =~ s{\b(mod|xor|and|or|unless)\b}{"\{" . lc($1) . "\}"}eig; # shield infix word operators
    $name =~ s/ //g; # remove all spaces
    if (1) { # from expr_mma.pl
    #   $name =~ tr{\[\]}
    #              {\(\)};
        $name =~ s{[\)\!] *\(}          {\)\*\(}g;      # ) (
        $name =~ s{[\)\!] *(\w)}        {\)\*$1}g;      # ) a
        $name =~ s{(\b\w|\!) +\(}       {$1\*\(}g;      # a (
        $name =~ s{(\b\d) *([a-z])}     {$1\*$2}g;      # 2 a
        $name =~ s{(\w|\!) +(\w)}       {$1\*$2}g;      # a b
    }
    my $rno = 0;
    @rseqnos = ();
    while ($name =~ s{(A\d+\(n([\+\-]\d+)?\))}{"A" . $rno}e) {
        push(@rseqnos, $1);
        $rno ++;
    }
    @naturals = ();
    $rno = 0;
    while ($name =~ s{\b(\d+)}{"I" . $rno}e) {
        push(@naturals, $1);
        $rno ++;
    }
    if (scalar(@rseqnos) > 0) {
        print        join("\t", $aseqno, $callcode, $offset, $name, $cond, join(";", @naturals), join(",", @rseqnos), $old_name) . "\n";
    } else {                                                                                                        
        print        join("\t", $aseqno, "lambdan", $offset, $name, $cond, join(";", @naturals)                     , $old_name) . "\n";
    }
    
} # while <>
__DATA__
A103565	multraf	0	2+3*(A103564(n))^2
A103745	multraf	0	A103528(n) + 2^(n-1)
A103856	dirtraf	0	A020639(A103855(n))
A103857	dirtraf	0	A006530(A103855(n))
A103858	dirtraf	0	A001221(A103855(n))
A103859	dirtraf	0	A000005(A103855(n))
A103861	dirtraf	0	A000010(A103855(n))
A104137	multraf	0	A007663(n) + A061285(n) + 1
A104379	multraf	0	square root of digital reversal of A102859(n)^2
A104384	multraf	0	p(2n-1) - A000070(n) + 1 and
A104492	dirtraf	0	A055400(A000040(n))
A104645	dirtraf	0	A151800(A019518(n)) - A151799(A019518(n))
A104718	multraf	0	A023202(n) concatenated with A023202(n)+8
