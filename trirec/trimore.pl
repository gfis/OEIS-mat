#!perl

# Process triangle sequences with "more" and generate SQL SELECT statements
# @(#) $Id$
# 2020-02-22, Georg Fischer
#
#:# Usage:
#:#   make trimore
#:#   perl trimore.pl [-d debug] [-m 4] trimore.tmp > trimore.sql
#:#       -m skip initial terms with abs() < this value
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $minterm = 2;
my $debug = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $minterm   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $line;
my $aseqno;
my $callcode;
my $offset  = 0;
my @terms;
my $termlist;
my @rowsums = ();
my $symmetrical = 0;
#             0      1  2  3  4  5  6  7
my @widlen = (16384, 6, 6, 4, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1);

while (<>) {
    $line = $_;
    next if $line =~ m{\A\s*\#};
    $line =~ s{\s+\Z}{}; # chompr
    if ($line =~ m{\A(A\d+)\s+(\w+)\s+(\-?\d+)\s+([\,\-0-9]+)}) {
        $aseqno   = $1;
        $callcode = $2;
        $offset   = $3;
        $termlist = $4;
        @terms = split(/\,/, $termlist);
        @rowsums = ();
        print "--  " . join("\t", $aseqno, $callcode, $offset, $termlist) . "\n";
        $symmetrical = -1; # do not know
        for (my $irow = 0; $irow <= 8; $irow ++) { # rows
            &vector("row  $irow"     , &get_row   ($irow));
            &vector("col  $irow"     , &get_column($irow));
        } # rows
        &vector    ("rowsum"      , @rowsums);
        for (my $idia = 0; $idia <= 2; $idia ++) { # diagonals, 0 = main, 1 = first sub
            &vector("diag $idia", &get_diagonal($idia));
        } # diagonals
        if ($symmetrical >= 1) {
        	print join("\t", "--", $aseqno, "symmetrical", $offset, $termlist) . "\n";
        }
    } else {
        # ignore
    }
} # while <>
#------------------------
sub vector {
    my ($title, @seqs) = @_;
    my $width = 0;
    map {   if (length($_) > $width) {
                $width = length($_);
            }
        } @seqs;
    if (scalar(@seqs) >= $widlen[$width]) { # long enough
        my $seq = join(",", @seqs);
        my $known = &is_known($seq);
        if (length($known) > 0) {
            print "SELECT \'$aseqno\', \'$title\', $offset, $known ;\n"
        } else {
            print "SELECT \'$aseqno\', \'$title\', $offset, d.aseqno, \'$seq\'"
                . " FROM asinfo i, asdata d WHERE i.aseqno = \'$aseqno\' AND d.aseqno <> \'$aseqno\'"
                . " AND d.data LIKE \'\%$seq\%' ORDER BY 1 LIMIT 4;"
                . "\n"
                ;
        }
    } # long enough
} # vector
#----
sub is_known {
    my ($list) = @_;
    my $result = "";
    if (0) {

    } elsif (index("1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1", $list) >= 0) { 
        $result = "\'A000041\', \'all ones\', \'$list\'";
    } elsif (index("0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,24,26,28,40", $list) >= 0) { 
        $result = "\'A005843\', \'even numbers\', \'$list\'";
    } elsif (index("1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41", $list) >= 0) { 
        $result = "\'A005408\', \'odd numbers\', \'$list\'";
    } elsif (index("0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20"
               . ",21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48", $list) >= 0) { 
        $result = "\'A000027\', \'positive integers\', \'$list\'";
    } elsif (index("1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384", $list) >= 0) { 
        $result = "\'A000079\', \'powers of 2\', \'$list\'";
    } elsif (index("0,1,3,7,15,31,63,127,255,511,1023,2047,4095,8191,16383", $list) >= 0) { 
        $result = "\'A000225\', \'2^n - 1\', \'$list\'";
    } elsif (index("1,3,9,27,81,243,729,2187,6561,19683,59049", $list) >= 0) { 
        $result = "\'A000244\', \'powers of 3\', \'$list\'";
    } elsif (index("1,1,2,6,24,120,720,5040,40320,362880,3628800,39916800,479001600", $list) >= 0) { 
        $result = "\'A000142\', \'factorials\', \'$list\'";
    } elsif (index("1,1,2,5,14,42,132,429,1430,4862,16796,58786,208012,742900", $list) >= 0) {
        $result = "\'A000108\', \'Catalan numbers\', \'$list\'";
    } elsif (index("1,1,2,3,5,7,11,15,22,30,42,56,77,101,135,176,231,297,385", $list) >= 0) { 
        $result = "\'A000041\', \'no. partitions\', \'$list\'";
    } elsif (index("1,3,6,10,15,21,28,36,45,55,66,78,91", $list) >= 0) { 
        $result = "\'A000217\', \'triangular numbers\', \'$list\'";
    } elsif (index("1,1,2,5,15,52,203,877,4140,21147", $list) >= 0) { 
        $result = "\'A000110\', \'Bell numbers\', \'$list\'";
    } elsif (index("1,7,28,84,210,462,924,1716,3003,5005", $list) >= 0) { 
        $result = "\'A000579\', \'figurate numbers\', \'$list\'";
    } elsif (index("1,2,4,10,36,202,1828,27338", $list) >= 0) { 
        $result = "\'A002577\', \'partitions of 2^n\', \'$list\'";
    } elsif (index("1,2,5,13,34,89,233,610,1597,4181,10946,28657,75025", $list) >= 0) { 
        $result = "\'A001519\', \'Fibonacci bisection\', \'$list\'";
    } elsif (index("1,6,21,56,126,252,462,792,1287,2002,3003,4368", $list) >= 0) { 
        $result = "\'A000389\', \'binomial C(n,5)\', \'$list\'";
    } elsif (index("1,4,16,64,256,1024,4096,16384,65536,262144,1048576,4194304,16777216", $list) >= 0) { 
        $result = "\'A000302\', \'powers of 4\', \'$list\'";
    } elsif (index("1,2,4,5,6,8,9,11,12,13,15,16,18,19,20,22,23,25,26,27,29,30,32,33,34,36,37,38,40", $list) >= 0) { 
        $result = "\'A000062\', \'Beatty a(n) = floor(n/(e-2))\', \'$list\'";

    } elsif (index("1,6,21,56,126,252,462,792,1287,2002,3003,4368", $list) >= 0) { 
        $result = "\'A000389\', \'binomial C(n,5)\', \'$list\'";
    } elsif (index("1,6,21,56,126,252,462,792,1287,2002,3003,4368", $list) >= 0) { 
        $result = "\'A000389\', \'binomial C(n,5)\', \'$list\'";
        
    } else {
    }
    return $result;
} # is_known
#----

sub get_row {
    my ($nrow) = @_;
    my @result = ();
    my $rowsum = 0; # global
    my $ielem = $nrow * ($nrow + 1) / 2;
    if ($ielem + $nrow < scalar(@terms)) { # in range
        my $iseq = 0;
        my $iqes = $nrow;
        my $skip = 1;
        $symmetrical = 1; # assume it is
        while ($iseq <= $nrow) {
            my $elem = $terms[$ielem + $iseq];
            if ($iseq <= $iqes and $elem != $terms[$ielem + $iqes]) {
                $symmetrical = 0;
            }
            $rowsum += $elem;
            if ($skip == 1 and abs($elem) < $minterm) { # ignore
            } else {
                $skip = 0;
                push(@result, $elem);
            }
            $iseq ++;
            $iqes --;
        } # while
        push(@rowsums, $rowsum);
    } # if in range
    return @result;
} # get_row

sub get_column {
    my ($ncol) = @_;
    my @result = ();
    my $ielem  = ($ncol + 1) * ($ncol + 2) / 2 - 1;
    my $iadd   = $ncol;
    my $skip   = 1;
    while ($ielem < scalar(@terms)) { # in range
        my $elem = $terms[$ielem];
        if ($skip == 1 and abs($elem) < $minterm) { # ignore
        } else {
            $skip = 0;
            push(@result, $elem);
        }
        $iadd ++;
        $ielem += $iadd;
    } # while in range
    return @result;
} # get_column

# getters
# column  0  1  2  3  4
# ------|---------------
# row 0 | 0
# row 1 | 1  2
# row 2 | 3  4  5
# row 3 | 6  7  8  9
# row 4 |10 11 12 13 14
# row 5 |15 16 17 18 19 20

sub get_diagonal {
    my ($ndia) = @_;
    my @result = ();
    my $ielem  = $ndia * ($ndia + 1) / 2; # starts like $nrow
    my $iadd   = $ndia + 1;
    my $skip   = 1;
    while ($ielem < scalar(@terms)) { # in range
        my $elem = $terms[$ielem];
        if ($skip == 1 and abs($elem) < $minterm) { # ignore
        } else {
            $skip = 0;
            push(@result, $elem);
        }
        $iadd ++;
        $ielem += $iadd;
    } # while in range
    return @result;
} # get_diagonal

#--------------------------------------------
__DATA__
A008985 trimore 0   1,1,1,1,1,2,3,3,2,4,10,11,10,4,10,35,57,57,35,10,26,133,290,364,290,133,26
A013561 trimore 3   1,1,1,1,3,1,1,11,11,1,1,31,90,31,1,1,85,544,544,85,1,1,225,2997,6559,2997,225,1
A013630 trimore 2   1,1,1,1,1,8,22,8,1,1,34,295,565,295,34,1
A034370 trimore 1   1,0,0,1,0,1,1,0,1,3,1,0,0,7,5,1,0,0,10,26,8,1,0,0,13,124,83,12,1
