#!perl

# Preprocess homgf records
# @(#) $Id$
# 2020-04-08-03, Georg Fischer
#
#:# Usage:
#:#   perl prep_homgf.pl [-a init] infile > outfile
#:#       -a additional initial terms (more than order)
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug  = 0;
my $ainit  = 0; # additional initial terms
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{a}) {
        $ainit  = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) {
    next if m{\{}; # skip unresolved recurrences
    s{\s+\Z}{};
    my ($aseqno, $callcode, $offset, $info, $data, $dist, $gftype, $gf, @rest) = split(/\t/);
    $info =~ s{k}{n}g; # Wolfram Koepf's FPS.mpl always yields a(k[+d])
    $info =~ s{\+a}{\+1\*a}g; # insert factor 1
    $info =~ s{\Aa}{\+1\*a}; # insert factor 1
    my $matrix = "[0";
    my $ndist  = 0; # a(n+0), a(n+1) ... a(n+d)
    my $factor = "";
    my $ilis   = 0;
    my @list   = split   (/(\*a\(n[\+\-0-9]*\))/, $info);
    # print STDERR "list=" . join("; ", @list) . "\n";
    while ($ilis < scalar(@list)) {
        my $elem = $list[$ilis];
        if (0) {
        } elsif ($elem =~ m{\*a\(n(\+\d+)?\)}) {
            my $cdist = $1 || 0;
            while ($ndist < $cdist) {
                $matrix .= ",0";
                $ndist ++;
            } # while $ndist
			$ndist ++;
            my $factor = $list[$ilis - 1];
            $factor =~ s{\A\+}{};  # remove leading "+"
            $matrix .= ",$factor";
        } else {
            # ignore factor for the moment
        }
        $ilis ++;
    } # while $ilis
    $matrix = $matrix . "]";
    $dist = $ndist - 1;
    my @terms = split(/\,/, $data);
    if (scalar(@terms) - 1 < $dist + $ainit) {
        # not enough terms
    } else {
        $callcode = "holo"; # for JoeisPreparer
        my $inits = "[" . join(",", splice(@terms, 0, $dist + $ainit)) . "]";
        print join("\t", $aseqno, $callcode, $offset, $matrix, $inits, $dist, $gftype, $gf, @rest) . "\n";
    }
} # while <>    
 
__DATA__
A102736 homgf   0   k*a(k)+a(k+1)+a(k+2)+(-k-3)*a(k+3)  1,1,2,4,16,80,400,2800,22400,179200,1792000,19712000,216832000,2    0   e   (1-x^3)^(1/3)/(1-x)
A004310 homgf   0   {(4*k^2+6*k+2)*a(k)+(-k^2-2*k+15)*a(k+1), a(0) = 0, a(1) = 0, a(2) = 0, a(3) = 0, a(4) = _C[0]} 1,10,66,364,1820,8568,38760,170544,735471,3124550,13123110,54627    0   o   x*(1/(sqrt(1-4*x)*x)-(1-sqrt(1-4*x))/(2*x^2))/((1-sqrt(1-4*x))/(2*x)-1)^5-(1/x^4-6/x^3+10/x^2-4/x)
A004312 homgf   0   {(4*k^2+6*k+2)*a(k)+(-k^2-2*k+35)*a(k+1), a(0) = 0, a(1) = 0, a(2) = 0, a(3) = 0, a(4) = 0, a(5) = 0, a(6) = _C[0]} 1,14,120,816,4845,26334,134596,657800,3108105,14307150,64512240,    0   o   ((1/(sqrt(1-4*x)*x)-(1-sqrt(1-4*x))/(2*x^2))*x)/((1-sqrt(1-4*x))/(2*x)-1)^7+6/x-35/x^2+56/x^3-36/x^4+10/x^5-1/x^6
A004981 homgf   0   (2+8*k)*a(k)+(-k-1)*a(k+1)  1,2,10,60,390,2652,18564,132600,961350,7049900,52169260,38889812    0   o   (1-8*x)^(-1/4)
A004982 homgf   0   (6+8*k)*a(k)+(-k-1)*a(k+1)  1,6,42,308,2310,17556,134596,1038312,8046918,62587140,488179692,    0   o   (1-8*x)^(-3/4)
A004983 homgf   0   (-6+8*k)*a(k)+(-k-1)*a(k+1) 1,-6,-6,-20,-90,-468,-2652,-15912,-99450,-640900,-4229940,-28455    0   o   (1-8*x)^(3/4)
A004984 homgf   0   (-2+8*k)*a(k)+(-k-1)*a(k+1) 1,-2,-6,-28,-154,-924,-5852,-38456,-259578,-1788204,-12517428,-8    0   o   (1-8*x)^(1/4)
