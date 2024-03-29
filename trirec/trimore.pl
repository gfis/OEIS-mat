#!perl

# Process triangle sequences with "more" and generate SQL SELECT statements
# @(#) $Id$
# 2021-09-30: all ones was A000041, -> A000012; -p for PascalTrait; AH=79
# 2020-03-22: -t = process traits, -l limit
# 2020-02-22, Georg Fischer
#
#:# Usage:
#:#   make trimore
#:#   perl trimore.pl [-d debug] [-m 2] [-t] [-l 2] [-s] trimore.tmp > trimore.sql
#:#       -l limit SQL SELECT yields so many sequences which contain these terms in the DATA section
#:#       -m skip initial terms with abs() < this value
#:#       -p special SQL for PascalTrait and ConstantTrait
#:#       -t process traits (otherwise generate some)
#:#       -s do skip initial terms (default: off)
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $name_len = 64;
my $limit = 2;
my $minterm = 2;
my $skip_init = 0; # no skipping, 1 = with skipping
my $pascal_traits = 0;
my $with_traits = 0;
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
    } elsif ($opt  =~ m{l}) {
        $limit     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $minterm   = shift(@ARGV);
    } elsif ($opt  =~ m{p}) {
        $pascal_traits = 1;
    } elsif ($opt  =~ m{t}) {
        $with_traits = 1;
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
        if ($with_traits == 0) {
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
        } else { # $with_traits == 1
            &vector($callcode, @terms);
        } # with_traits
    } else {
        # ignore
    }
} # while <>
#------------------------
sub vector {
    my ($title, @terms) = @_;
    my $width = 0;
    map {   if (length($_) > $width) {
                $width = length($_);
            }
        } @terms;
    $width = ($width >= scalar(@widlen)) ? $widlen[scalar(@widlen) - 1] : $widlen[$width];
    if ($pascal_traits or scalar(@terms) >= $width) { # long enough
        my $termlist = join(",", @terms);
        $title = substr($title, 0, 4);
        my $tseqno_name_list = &is_known($termlist);
        if (length($tseqno_name_list) > 0) {
            print "SELECT \'$aseqno\', \'$title\', 296, $tseqno_name_list"
                . ", \'well-known\',  \'\',  \'\'"
            #   . ", a.keyword"
            #   . " FROM asinfo a"
            #   . " WHERE a.aseqno  = \'$aseqno\'"
                . ";\n"
                ;  
        } elsif ($pascal_traits) {
            print "SELECT \'$aseqno\', \'$title\', s.offset, COALESCE(d.aseqno, s.parm1)" 
                . ", COALESCE(SUBSTR(n.name, 1, $name_len), \'unknown\')" 
                . " FROM seq4 s "
                . " LEFT JOIN asdata d ON d.data LIKE \'$termlist\%' AND d.aseqno <> s.aseqno "
                . " LEFT JOIN asname n ON d.aseqno = n.aseqno"
                . " WHERE s.aseqno  = \'$aseqno\' "
                . "   AND s.callcode = \'$callcode\' "
                . " ORDER BY 1,2 LIMIT $limit;" 
                # "LIMIT" is MariaDB specific, DB2 would need "FETCH FIRST $limit ROWS ONLY"
                . "\n"
                ;
        } else { # deprecated code
            print "SELECT \'$aseqno\', \'$title\', COALESCE(t.aseqno, 'Annnnnn')" 
                . ", COALESCE(SUBSTR(n.name, 1, $name_len), 'unknown')" 
                . " , \'$termlist\'"
                . " , COALESCE(i.keyword, ''), COALESCE(i.author, ''), COALESCE(a.keyword, '')"
                . " FROM asinfo a, asinfo i, asname n, asdata t"
                . " WHERE t.data LIKE \'$termlist\%' "
                . "   AND a.aseqno  = \'$aseqno\'"
                . "   AND t.aseqno <> \'$aseqno\'"
                . "   AND n.aseqno  = t.aseqno "
                . "   AND i.aseqno  = t.aseqno "
                . "   AND i.offset1 = 0 "
                . " ORDER BY 1,3 LIMIT $limit;" 
                # "LIMIT" is MariaDB specific, DB2 would need "FETCH FIRST $limit ROWS ONLY"
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

    } elsif (index("1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1", $list) == 0) { 
        $result = "\'A000012\', \'all ones\', \'$list\'";
    } elsif (index("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0", $list) == 0) { 
        $result = "\'A000004\', \'all zeroes\', \'$list\'";
    } elsif (index("1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0", $list) == 0) { 
        $result = "\'A000007\', \'one, zeroes\', \'$list\'";
    } elsif (index("0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120", $list) == 0) { 
        $result = "\'A005843\', \'even numbers\', \'$list\'";
    } elsif (index("2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120", $list) == 0) { 
        $result = "\'A005843_1\', \'even numbers_1\', \'$list\'";
    } elsif (index("1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181,6765,10946,17711,28657,46368,75025,121393,196418,317811,514229,832040,1346269,2178309,3524578", $list) == 0) {
        $result = "\'A000045_1\', \'Fibonacci numbers_1\', \'$list\'";
    } elsif (index("1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181,6765,10946,17711,28657,46368,75025,121393,196418,317811,514229,832040,1346269,2178309,3524578", $list) == 0) {
        $result = "\'A000045_2\', \'Fibonacci numbers_2\', \'$list\'";
    } elsif (index("2,1,3,4,7,11,18,29,47,76,123,199,322,521,843,1364,2207,3571,5778,9349,15127,24476,39603,64079,103682,167761,271443,439204,710647,1149851,1860498,3010349,4870847,7881196,12752043,20633239,33385282,54018521,87403803", $list) == 0) {
        $result = "\'A000032\', \'Lucas numbers\', \'$list\'";    
    } elsif (index("1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41", $list) == 0) { 
        $result = "\'A005408\', \'odd numbers\', \'$list\'";
    } elsif (index("0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32", $list) == 0) { 
        $result = "\'A001477\', \'nonnegative integers\', \'$list\'";
    } elsif (index("1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32", $list) == 0) { 
        $result = "\'A000027\', \'positive integers\', \'$list\'";
    } elsif (index("1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304,8388608,16777216,33554432,67108864,134217728,268435456,536870912,1073741824,2147483648,4294967296", $list) == 0) { 
        $result = "\'A000079\', \'powers of 2\', \'$list\'";
    } elsif (index("2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304,8388608,16777216,33554432,67108864,134217728,268435456,536870912,1073741824,2147483648,4294967296", $list) == 0) { 
        $result = "\'A000079_1\', \'powers of 2_1\', \'$list\'";
    } elsif (index("0,1,3,7,15,31,63,127,255,511,1023,2047,4095,8191,16383", $list) == 0) { 
        $result = "\'A000225\', \'2^n - 1\', \'$list\'";
    } elsif (index("1,3,9,27,81,243,729,2187,6561,19683,59049", $list) == 0) { 
        $result = "\'A000244\', \'powers of 3\', \'$list\'";
    } elsif (index("3,9,27,81,243,729,2187,6561,19683,59049", $list) == 0) { 
        $result = "\'A000244_1\', \'powers of 3_1\', \'$list\'";
    } elsif (index("1,1,2,6,24,120,720,5040,40320,362880,3628800,39916800,479001600,6227020800,87178291200,1307674368000,20922789888000,355687428096000,6402373705728000,121645100408832000,2432902008176640000,51090942171709440000,1124000727777607680000,25852016738884976640000,620448401733239439360000,15511210043330985984000000,403291461126605635584000000,10888869450418352160768000000,304888344611713860501504000000,8841761993739701954543616000000,265252859812191058636308480000000,8222838654177922817725562880000000,263130836933693530167218012160000000", $list) == 0) {
        $result = "\'A000142\', \'factorials\', \'$list\'";
    } elsif (index("1,2,6,24,120,720,5040,40320,362880,3628800,39916800,479001600,6227020800,87178291200,1307674368000,20922789888000,355687428096000,6402373705728000,121645100408832000,2432902008176640000,51090942171709440000,1124000727777607680000,25852016738884976640000,620448401733239439360000,15511210043330985984000000,403291461126605635584000000,10888869450418352160768000000,304888344611713860501504000000,8841761993739701954543616000000,265252859812191058636308480000000,8222838654177922817725562880000000,263130836933693530167218012160000000", $list) == 0) {
        $result = "\'A000142_1\', \'factorials_1\', \'$list\'";
    } elsif (index("1,1,2,5,14,42,132,429,1430,4862,16796,58786,208012,742900", $list) == 0) {
        $result = "\'A000108\', \'Catalan numbers\', \'$list\'";
    } elsif (index("1,1,2,3,5,7,11,15,22,30,42,56,77,101,135,176,231,297,385", $list) == 0) { 
        $result = "\'A000041\', \'no. partitions\', \'$list\'";
    } elsif (index("1,3,6,10,15,21,28,36,45,55,66,78,91,105,120,136,153,171,190,210,231,253,276,300,325,351,378,406,435,465,496,528", $list) == 0) { 
        $result = "\'A000217_1\', \'triangular numbers_1\', \'$list\'";
    } elsif (index("1,1,2,5,15,52,203,877,4140,21147", $list) == 0) { 
        $result = "\'A000110\', \'Bell numbers\', \'$list\'";
    } elsif (index("1,7,28,84,210,462,924,1716,3003,5005", $list) == 0) { 
        $result = "\'A000579\', \'figurate numbers\', \'$list\'";
    } elsif (index("1,2,4,10,36,202,1828,27338", $list) == 0) { 
        $result = "\'A002577\', \'partitions of 2^n\', \'$list\'";
    } elsif (index("1,2,5,13,34,89,233,610,1597,4181,10946,28657,75025", $list) == 0) { 
        $result = "\'A001519\', \'Fibonacci bisection\', \'$list\'";
    } elsif (index("1,6,21,56,126,252,462,792,1287,2002,3003,4368", $list) == 0) { 
        $result = "\'A000389\', \'binomial C(n,5)\', \'$list\'";
    } elsif (index("1,4,16,64,256,1024,4096,16384,65536,262144,1048576,4194304,16777216", $list) == 0) { 
        $result = "\'A000302\', \'powers of 4\', \'$list\'";
    } elsif (index("1,4,9,16,25,36,49,64,81,100,121,144,169,196,225,256,289,324,361,400,441,484,529,576,625,676,729,784,841,900,961,1024", $list) == 0) { 
        $result = "\'A000290_1\', \'squares_1\', \'$list\'";
    } elsif (index("1,8,27,64,125,216,343,512,729,1000,1331,1728,2197,2744,3375,4096,4913,5832,6859,8000,9261,10648,12167,13824,15625,17576,19683,21952,24389,27000,29791,32768,35937,39304,42875,46656,50653,54872,59319,64000", $list) == 0) { 
        $result = "\'A000578_1\', \'cubes_1\', \'$list\'";
    } elsif (index("1,2,4,5,6,8,9,11,12,13,15,16,18,19,20,22,23,25,26,27,29,30,32,33,34,36,37,38,40", $list) == 0) { 
        $result = "\'A000062\', \'Beatty a(n) = floor(n/(e-2))\', \'$list\'";
    } elsif (index("1,6,21,56,126,252,462,792,1287,2002,3003,4368", $list) == 0) { 
        $result = "\'A000389\', \'binomial C(n,5)\', \'$list\'";
    } elsif (index("1,6,21,56,126,252,462,792,1287,2002,3003,4368", $list) == 0) { 
        $result = "\'A000389\', \'binomial C(n,5)\', \'$list\'";
    } elsif (index("0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1", $list) == 0) { 
        $result = "\'A057427\', \'0 followed by ones\', \'$list\'";
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
