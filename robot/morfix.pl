#!perl

# Extract parameters for MorphismFixedPointSequence
# @(#) $Id$
# 2023-09-18, Georg Fischer: copied from fischer/morfps.pl
#
#:# Usage:
#:#   perl morfix.pl input.seq4 > output.seq4
#---------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}

my $debug = 0;
my $anchor_mode = "anch";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt    =~ m{\-a}  ) {
        $anchor_mode = shift(@ARGV);
    } elsif ($opt    =~ m{\-d}  ) {
        $debug       = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options

my $line;
my ($aseqno, $callcode, $offset, $name);
my $start;
my $maps;
my $nok;

while(<>) {
    s{\s+\Z}{}; # chompr
    $line = $_;
    $callcode = "morfix";
    $start = "1";
    if ($line =~ m{^(A\d+)}) {
        ($aseqno, $callcode, $offset, $name) = split(/\t/, $line);
    } else {
        next;
    }
    $nok = "noarrow";
    if (0) {
    #                   1                                    1
    } elsif ($name =~ m{(\d+ *\-\>[ 0-9\-\>\,\;\{\}\(\)\[\]]+)}) {
        $maps = $1;
        $maps =~ s{([\}\d]) +(\d)}{$1;$2}g; # insert ";" delimiter between maps
        $maps =~ s{ }{}g; # remove all spaces
        $maps =~ tr{\(\)\[\]}
                   {\{\}\{\}}; # normalize parentheses to "{}"
        $maps =~ s{\}[\,\.]\{}{\}\;\{}g; # normalize delimiter between maps to ";"
        #          1   1    2   2   
        $maps =~ s{(\d+)\-\>(\d+)}{$1\-\>\{$2\}}g; # surround target with "{...}"
        
        if ($debug >= 1) {
            print "# $aseqno.1: maps=\"$maps\", line=" . substr($line, 0, 64) . "\n";
        }
        #                 1   1    2 {3   4           4 3 }2
        while ($maps =~ s{(\d+)\-\>(\{(\d+([\,\;\.]\d+)*)\})}{\#}) { # shield, with "{...}"
            my ($source, $target) = ($1, $3);
            if ($debug >= 2) {
                print "# $aseqno.2: maps=\"$maps\", source=$source, target=$target\n";
            }
            $source = &encode($source);
            my @terms = map { &encode($_) } split(/[\,\;\.]/, $target);
            $target = join("", @terms);
            $maps =~ s{\#}{$source\-\>$target}; # unshield, without "{...}"
            if ($debug >= 2) {
                print "# $aseqno.3:     maps=\"$maps\", source=$source, target=$target\n";
            }
        } # while
        $nok = "";
    }
    if ($maps =~ m{[\{\}\?]}) {
        $nok = "nomap";
    } else {
        $maps =~ s{\;}{\,}g;
        $maps =~ s{\,\Z}{};
    }
    my $anchor = $anchor_mode;
    if ($anchor =~ m{^anch}) {
        $anchor = $start;
    }
    if ($nok eq "") {
        print        join("\t", $aseqno, $callcode, $offset, $start, $anchor, $maps, "",   $name) . "\n";
    } else {
        print STDERR join("\t", $aseqno, $callcode, $offset, $start, $anchor, $maps, $nok, $name) . "\n";
    }
} # while <>
#----
sub encode { # map numbers < 62 to 0-9A-Za-z 
	my ($term) = @_;
    if (0) {
    } elsif ($term >= 62) { # too big
        $nok = "toobig";
        $term = ".";
    } elsif ($term >= 36) { # map to a-z
        $term = chr($term - 36 + ord('a'));
    } elsif ($term >= 10) { # map to A-Z
        $term = chr($term - 10 + ord('A'));
    } elsif ($term >=  0) { # map to 0-9
        $term = chr($term -  0 + ord('0'));
    }
	return $term;
} # encode
__DATA__
A072845 morfix  0   Let S(1) = {1, 3, 7, 9}, S(n) be obtained from S(n-1) via 1 -> {1, 3, 7, 9}, 3 -> {3, 9, 1, 7}, 7 -> {7, 1, 9, 3}, 9 -> {9, 7, 3, 1}, then this sequence is the concatenation of S(1), S(2), ... - _Jianing Song_, Dec 24 2022
A093951 morfix  0   Substitutions 1 -> {2}, 2 -> {3,1}, 3 -> {4,2}, 4 -> {5,3,1}, 5 -> {6,4,2}, 6 -> {7,5,3,1}, 7 -> {8,6,4,2}, etc. The function f(n) gives determinant of (I_{n} - x * A(n)) where I_{n} is the identity matrix and  A(n) = 0 if j > i + 1 otherwise (i+j) mod 2, for i = 1, ..., n and j = 1, ..., n, and can be written in terms of Dickson polynomials as : g(w) = x*D_(w-1)(1+x, x*(1+x)) + (1-2*x)*E_(w-1)(1+x, x*(1+x)). - Francisco Salinas (franciscodesalinas(AT)hotmail.com), Apr 13 2004.
A103269 morfix  0   Apply the tribonacci morphism 1 -> {1, 2}, 2 -> {1, 3}, 3 -> {1} n times to 1, and concatenate the resulting string.
A103682 morfix  0   Trajectory of 1 under repeated applications of the morphism 1-> {1,2}, 2->{1,2,3}, 3->{1,1,3}.
A103684 morfix  0   Triangle read by rows, based on the morphism f: 1->{1,2}, 2->{1,3}, 3->{1}. First row is 1. If current row is a,b,c,..., then the next row is a,b,c,...,f(a),f(b),f(c),...
A103748 morfix  0   Triangle read by rows, based on the morphism f: 1->{2}, 2->{3}, 3->{3,3,2,1}. First row is 1. If current row is a,b,c,..., then the next row is a,b,c,...,f(a),f(b),f(c),...
A103956 morfix  0   1-> {1, 2} 2->{1, 3} 3->1 nested nest of substitution list are taken in a chaotic order.
A103957 morfix  0   Involves substitutions 1-> {1, 2}, 2->{1, 3}, 3->1.
A105256 morfix  0   1->{4, 2} 2->{1, 3} 3->{1} 4->{1, 5} 5->{4, 6} 6->{4}
