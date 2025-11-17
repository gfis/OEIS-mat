#!perl

# Normalize programming languages, keep important ones only, truncate fields
# @(#) $Id$ 
# 2025-11-16: perl,scheme etc.
# 2022-06-17, Georg Fischer
#
#:# usage:
#:#   perl asprog_clean asprog.txt > outputfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
my $debug      = 0; # 0 (none), 1 (some), 2 (more)
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

while (<>) {
    s/\s+\Z//; # chompr
    my ($aseqno, $lang, $curno, $type, $code, @rest) = split(/\t/);
    if (length($code) >= 16384) {
        print STDERR join("\t", $aseqno, $lang, $curno, $type, $code, @rest) . "\n";
        next;
    }
    my $known_lang = 0
        + ($lang =~ s{\Agap.*}      {gap}          )
        + ($lang =~ s{\Ahaskel.*}   {haskell}      )
        + ($lang =~ s{\Amaxima.*}   {maxima}       )
        + ($lang =~ s{\Apari.*}     {pari}         )
        + ($lang =~ s{\Aperl.*}     {perl}         )
        + ($lang =~ s{\Apython.*}   {python}       )
        + ($lang =~ s{\Asagemath.*} {sagemath}     )
        + ($lang =~ s{\Ascheme.*}   {scheme}       )
        ;
    if ($known_lang > 0) {
        print        join("\t", $aseqno, $lang, $curno, $type, $code, @rest) . "\n";
    } else { 
    }
} # while <>
#------------------------------------
__DATA__
A000001	magma	1	type	~~~~D:=SmallGroupDatabase(); [ NumberOfSmallGroups(D, n) : n in [1..1000] ]; // _John Cannon_, Dec 23 2006
A000001	gap	1	type	~~~~A000001 := Concatenation([0], List([1..500], n -> NumberSmallGroups(n))); # _Muniru A Asiru_, Oct 15 2017
A000002	pari	1	type	~~~~my(a=[1,2,2]); for(n=3,80, for(i=1,a[n],a=concat(a,2-n%2))); a
A000002	pari	2	type	~~~~{a(n) = local(an=[1, 2, 2], m=3); if( n<1, 0, while( #an < n, an = concat( an, vector(an[m], i, 2-m%2)); m++); an[n])};
A000002	haskell	1	type	~~~~a = 1:2: drop 2 (concat . zipWith replicate a . cycle $ [1,2]) -- _John Tromp_, Apr 09 2011
A000002	python	1	type	~~~~~~# For explanation see link.~~def Kolakoski():~~    x = y = -1~~    while True:~~        yield [2,1][x&1]~~        f = y &~ (y+1)~~        x ^= f~~        y = (y+1) | (f & (x>>1))~~K = Kolakoski()~~print([next(K) for _ in range(100)]) # _David Eppstein_, Oct 15 2016
