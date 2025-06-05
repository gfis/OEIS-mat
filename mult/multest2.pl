#!perl

# Grep sequences that are problably multiplicative
# @(#) $Id$
# 2025-06-01, Georg Fischer, copied from ../common/zero_spaced.pl; *UP=56
#
#:# usage:
#:#   perl multest.pl mudata.tmp > outputfile
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\z"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

# get options
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $sep = "*";
my $debug  = 0;   # -d 0 (none), 1 (some), 2 (more)
my $nterms = 256; # -n, calculate factors up to this number
my $value   = 0;
my $minterm = 8;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-n}) {
        $minterm  = shift(@ARGV);
    } elsif ($opt =~ m{\-n}) {
        $nterms   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----
# precompute the factor lists
my @primes = (1, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97
    , 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199
    , 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271);
my @falis = (1); # list of factors in product of (increasing prime) powers, or 0 if only one prime is involved
my @fanos = (0); # number of factors in $falis[$num]
for (my $num = 1; $num <= $nterms; $num ++) { # over all possible numbers
    my %fas = (); # factors
    my $ipm = 1; # start with 2
    while ($ipm < scalar(@primes)) { # over all primes
        my $prime = $primes[$ipm];
        my $nuf = $num;
        while ($nuf % $prime == 0) {
            if (defined($fas{$prime})) {
                $fas{$prime} *= $prime;
            } else {
                $fas{$prime} = $prime;
            }
            $nuf /= $prime;
        } # while $prime divides
        $ipm ++; # try next prime
    } # while $ipm
    $fanos[$num] = scalar(keys(%fas));
    $falis[$num] = join($sep, values(%fas));
    if ($debug >= 1) {
        print "# factorize " . sprintf("%4d", $num) . ": $fanos[$num] -> $falis[$num]\n";
    }
} # for $num
#----
while (<>) {
#while (<DATA>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    if ($line =~ m{\A[A-Z]\d{6}}) { # starts with A-number
        my ($aseqno, $cc, $offset1, $termlist) = split(/\t/, $line);
        my @a = ();
        if ($offset1 == 1) {
            push(@a, 0);
        }
        push(@a, split(/\,/, $termlist));
        if (0) {
        } elsif ($offset1 < 0 || $offset1 >= 2) {
            $cc .= "?off$offset1";
        } elsif (scalar(@a) <= $minterm) {
            $cc .= "?mint";
        } elsif (length($a[scalar(@a) - 1]) > 16) {
            $cc .= "?big";
        } else { # now test all terms
            $termlist = "pass\t" .scalar(@a) . "\t$termlist";
            for (my $ix = 6; $ix < scalar(@a); $ix ++) {
                if ($fanos[$ix] > 1) { # bigomega >= 2
                    my $prod = 1;
                    my @prods = ();
                    foreach my $fact (split(/\*/, $falis[$ix])) {
                        $prod *= $a[$fact];
                        push(@prods, "(a($fact)=$a[$fact])");
                    }
                    if ($prod != $a[$ix]) { 
                        $termlist = "FAIL: The sequence is not multiplicative since a($ix)=$a[$ix] differs from $prod = " . join(" * ", @prods) . ". ~~~~";
                        last;
                    }
                } # bigomega >= 2
            } # foreach $ia
        }
        $line = join("\t", $aseqno, $cc, $offset1, $termlist);
    }
    print $line . "\n";
} # while <>
__DATA__
#------------------------------------
A000001	core	0	0,1,1,1,2,1,2,1,5,2,2,1,5,1,2,1,14,1,5,1,5,2,2,1,15,2,2,5,4,1,4,1,51,1,2,1,14,1,2,2,14,1,6,1,4,2,2,1,52,2,5,1,5,1,15,2,13,2,2,1,13,1,2,4,267,1,4,1,5,1,4,1,50,1,2,3,4,1,6,1,52,15,2,1,15,1,2,1,12,1,10,1,4,2
A000002	core	1	1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,2,1,2,1,1,2,1,2,2,1,1,2,1,1,2,1,2,2,1,2,2,1,1,2,1,2,2,1,2,1,1,2,1,1,2,2,1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,1,2,2,1,2,1,1,2,2,1,2,2,1,1,2,1,2,2,1,2,2,1,1,2,1,1,2,2,1,2,1,1,2,1,2,2
A000009	core	0	1,1,1,2,2,3,4,5,6,8,10,12,15,18,22,27,32,38,46,54,64,76,89,104,122,142,165,192,222,256,296,340,390,448,512,585,668,760,864,982,1113,1260,1426,1610,1816,2048,2304,2590,2910,3264,3658,4097,4582,5120,5718,6378
A000004	mult	0	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
A000005	mult	1	1,2,2,3,2,4,2,4,3,4,2,6,2,4,4,5,2,6,2,6,4,4,2,8,3,4,4,6,2,8,2,6,4,4,4,9,2,4,4,8,2,8,2,6,6,4,2,10,3,6,4,6,2,8,4,8,4,4,2,12,2,4,6,7,4,8,2,6,4,8,2,12,2,4,6,6,4,8,2,10,5,4,2,12,4,4,4,8,2,12,4,6,4,4,4,12,2,6,6,9,2,8,2,8
A000003	nonn	1	1,1,1,1,2,2,1,2,2,2,3,2,2,4,2,2,4,2,3,4,4,2,3,4,2,6,3,2,6,4,3,4,4,4,6,4,2,6,4,4,8,4,3,6,4,4,5,4,4,6,6,4,6,6,4,8,4,2,9,4,6,8,4,4,8,8,3,8,8,4,7,4,4,10,6,6,8,4,5,8,6,4,9,8,4,10,6,4,12,8,6,6,4,8,8,8,4,8,6,4
A000006	nonn	1	1,1,2,2,3,3,4,4,4,5,5,6,6,6,6,7,7,7,8,8,8,8,9,9,9,10,10,10,10,10,11,11,11,11,12,12,12,12,12,13,13,13,13,13,14,14,14,14,15,15,15,15,15,15,16,16,16,16,16,16,16,17,17,17,17,17,18,18,18,18,18
A000008	nonn	0	1,1,2,2,3,4,5,6,7,8,11,12,15,16,19,22,25,28,31,34,40,43,49,52,58,64,70,76,82,88,98,104,114,120,130,140,150,160,170,180,195,205,220,230,245,260,275,290,305,320,341,356,377,392,413,434,455,476,497,518,546
