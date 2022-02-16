#!perl

# Examine tabl triangles for some condition
# @(#) $Id$
# 2021-10-26, Georg Fischer: copied from tricheck.pl
#
#:# Usage:
#:#   perl trixamine.pl [-b bfdir] [-d debug] [-m {trixy}] [-r rows] [-s start] trigen.tmp > output
#:#       -b directory with b-files to be investigated (default: do not read b-files)
#:#       -m type of check to be performed (default: trixy)
#:#       -r minimum number of rows (default: 6)
#:#       -s starting row (default: 1)
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
my $mode = "trixy";
my $start_row = 1;
my $min_rows  = 6;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{b}) {
        $bfdir     = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      = shift(@ARGV);
    } elsif ($opt  =~ m{r}) {
        $min_rows  = shift(@ARGV);
    } elsif ($opt  =~ m{s}) {
        $start_row = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my @t; # triangular matrix
my $line;
my ($aseqno, $offset, $data);
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    if ($line =~ m{^A\d+\t\S+\t\S}) { # with A-number
        ($aseqno, $offset, $data) = split(/\t/, $line);
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
        if (0) {
        #--------
        } elsif ($mode =~ m{trixy}) {
            # A052179: This triangle belongs to the family of triangles defined by:
            # T(n,k) = 0 if k < 0 or if k > n,
            # T(0,0) = 1,
            # T(n,0) = x*T(n-1,0) + T(n-1,1),
            # T(n,k) = T(n-1,k-1) + y*T(n-1,k) + T(n-1,k+1) for k >= 1.
            # with parameters (x,y)
            my $ok = $nmax >= $min_rows ? 1 : 0; # require at least $min_rows rows
            $n = 2;
            $k = 1;
            my $x0;
            my $numx = (&T($n,0) - &T($n-1,1));
            my $denx = &T($n-1,0);
            if ($numx == 0) {
            	$x0 = 0;
            } elsif ($denx != 0 && $numx % $denx == 0) {
                $x0 = $numx / $denx;
            } else {
                $ok = 0;
            }
            my $y0;
            my $numy = (&T($n,$k) - &T($n-1,$k-1) - &T($n-1,$k+1));
            my $deny = &T($n-1,$k);
            if ($deny != 0 && $numy % $deny == 0) {
                $y0 = $numy / $deny;
            } else {
                $ok = 0;
            }
            $n = $start_row;
            while ($ok > 0 && $n < $nmax) {
                $numx = (&T($n,0) - &T($n-1,1));
                $denx = &T($n-1,0);
                if ($numx == 0) {
            	    if ($x0 != 0) {
            	        $ok = 0;
            	    }
                } elsif ($denx != 0) {
                    if ($x0 * $denx != (&T($n,0) - &T($n-1,1))) {
                        $ok = 0;
                    }
                } else {
                    $ok = 0;
                }
                for ($k = 1; $k < $n; $k ++) {
                    $deny = &T($n-1,$k);
                    if ($deny != 0) {
                        if ($y0 * $deny != (&T($n,$k) - &T($n-1,$k-1) - &T($n-1,$k+1))) {
                            $ok = 0;
                        }
                    } else {
                        $ok = 0;
                    }
                } # for $k
                $n ++;
            } # while
            my $inits = "";
            for ($n = 0; $n < $start_row; $n ++) {
                for ($k = 0; $k <= $n; $k ++) {
                    $inits .= "," . &T($n, $k);
                } # for $k
            } # for $n
            if ($ok == 1) {
                print join("\t", $aseqno, "trixy", $offset, "bseqno", substr($inits, 1), $x0, $y0) . "\n";
            }
        #--------
        } else {
            print STDERR "invalid mode \"$mode\"\n";
        }
    } # with A-number
} # while <>
#----
sub T { # n, k
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
A007318	1,1,1,1,2,1,1,3,3,1,1,4,6,4,1,1,5,10,10,5,1,1,6,15,20,15,6,1,1,7,21,35,35,21,7,1,1,8,28,56,70,56,28,8,1,1,9,36,84,126,126,84,36,9,1,1,10,45,120,210,252,210,120,45,10,1,1,11,55,165,330,462,462,330,165,55,11,1
