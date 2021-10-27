#!perl

# Check tabl triangles for some condition
# @(#) $Id$
# 2021-10-26: -m trixy
# 2020-07-28, Georg Fischer
#
#:# Usage:
#:#   perl tricheck.pl [-b bfdir] [-d debug] [-e errlim] [-m {knoll|diag1}] trigen.tmp > triknoll.tmp
#:#       -b directory with b-files to be investigated
#:#       -e maybe an error if condition is not fulfilled above this row number, default: 4
#:#       -m type of check to be performed, default: knoll
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (scalar(@ARGV) < 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $bfdir = "";
my $debug = 0;
my $errlim = 4;
my $mode = "knoll";
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{b}) {
        $bfdir     = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{e}) {
        $errlim    = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @t; # triangular matrix
my $line;
my $aseqno;
my $errmess = "knoll";

while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if ($line =~ m{^(A\d+)\s+(.*)}) { # with A-number
        $aseqno  = $1;
        my $data = $2;
        my @terms = split(/\,/, $data);
        if (length($bfdir) > 0) {
            @terms = &read_bfile($aseqno);
        }
        my $nterm = scalar(@terms);
        my $ind = 0;
        my $n = 0;
        my $k;
        my $busy = 1;
        while ($busy > 0 and $ind < $nterm) { # build an array T(n,k) with the triangle
            if ($ind + $n + 1 < $nterm) { # complete row still available
                for ($k = 0; $k <= $n; $k ++) {
                    $t[$n][$k] = $terms[$ind ++];
                } # for $k
                $n ++;
            } else { # incomplete row
                $busy = 0;
            }
        } # while $ind
        my $nmax = $n - 1;
        my $ffind = $ind;
        
        # now check the triangle
        my $ok = 1;
        my $rowok = -1;
        $n = 0;
        while ($ok == 1 and $n <= $nmax) { # check each row
            my $term0 = &get($n, 0);
            if ($term0 != 1 and $term0 != -1) { # check +/-1 at start and end
                $ok = 0;
                $errmess = "+/-1 at T($n,$k)";
                if ($debug >= 1) {
                    print "# violates +/-1 at T($n,$k)\n";
                }
            } else { # check symmetricity
                $k = 0;
                while ($ok == 1 and $k <= $n - $k) {
                    if (&get($n, $k) != &get($n, $n - $k)) {
                        $ok = 0;
                        $errmess = "T($n,$k)=" . &get($n, $k) . " != T($n," . ($n-$k) . ")=" . &get($n, $n - $k);
                        if ($debug >= 1) {
                            print "# violates symmetricity at T($n,$k)\n";
                        }       
                    }
                    $k ++;
                } # while symmetric
            } # symmetricity
            if ($ok == 1) {
                $rowok = $n;
            } else {
                if ($rowok >= $errlim) {
                    print "# $aseqno knoll violation at row $n - possible error: $errmess\n";
                }
            }
            $n ++;
        } # each row
        if ($nmax >= 3 and $ok == 1) {
            print join("\t", $aseqno, "triknoll", $errmess) . "\n";
        }
        if ($debug >= 1) { # debug
            for ($n = 0; $n <= $nmax; $n++) {
                for ($k = 0; $k <= $n; $k ++) {
                    print sprintf("%4d", &get($n, $k));
                } # for k
                print "\n";
            } # for n
        } # if debug
    } # with A-number
} # while <>
#----
sub get { # n, k
    my ($n, $k) = @_;
    return ($k >= 0 and $k <= $n) ? ($t[$n][$k]) : 0;
} # get
#----
sub get_row { # n = row number
    my ($n) = @_;
    my $k;
    my @row = ();
    for ($k = 0; $k <= $n; $k ++) {
        push(@row, &get($n, $k));
    } # for k
    return @row;
} # get_row
#----
sub check_knoll { # check row n for start, end = +/-1 and symmetricity
    my ($n) = @_;
    my $k;
    my $ok = 1;
    my @row = &get_row($n);
    my $term0 = &get($n, 0);
    if ($term0 != 1 and $term0 != -1) { # check +/-1 at start and end
        $ok = 0;
        if ($debug >= 1) {
            print "# violates +/-1 at T($n,$k)\n";
        }
    } else { # check symmetricity
        $k = 0;
        while ($ok == 1 and $k <= $n - $k) {
            if (&get($n, $k) != &get($n, $n - $k)) {
                $ok = 0;
                if ($debug >= 1) {
                    print "# violates symmetricity at T($n,$k)\n";
                }       
            }
            $k ++;
        } # while symmetric
    } # symmetricity
    
    for ($k = 0; $k <= $n; $k ++) {
        push(@row, &get($n, $k));
    }
    return $ok;
} # check_knoll
#----
sub read_bfile {
    my ($aseqno) = @_;
    my $buffer;
    my $src_file = "$bfdir/b" . substr($aseqno, 1) . ".txt";
    open(FIL, "<", $src_file) or die "cannot read $src_file\n";
    read(FIL, $buffer, 100000000); # 100 MB
    close(FIL);
    my @terms = grep { m{\S} } # keep non-empty lines only
            map { 
                s{\#.*}{};      # remove comments
                s{\A\s+}{};     # remove leading whitespace
                s{\s+\Z}{};     # remove trailing whitespace
                s{\A\-?\d+\s+}{}; # remove index
                $_
            } split(/\n/, $buffer);
    print STDERR "# $src_file read with " . scalar(@terms) . " terms\n";
    return @terms;
} # sub read_bfile
#--------------------------------------------
__DATA__
A007318 1,1,1,1,2,1,1,3,3,1,1,4,6,4,1,1,5,10,10,5,1,1,6,15,20,15,6,1,1,7,21,35,35,21,7,1,1,8,28,56,70,56,28,8,1,1,9,36,84,126,126,84,36,9,1,1,10,45,120,210,252,210,120,45,10,1,1,11,55,165,330,462,462,330,165,55,11,1

