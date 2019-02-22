#!perl

# Prepare wget command lines for many sequences
# @(#) $Id$
# 2019-01-19, Georg Fischer
#
#:# usage:
#:#     perl aseq_wget.pl [-n numseq] [-o outdir] [-t (bfile|text|[a]json)] [-m maxnum] infile > outfile
#:#       -n number of sequences to be fetched per wget command (default 8, 1 for bf)
#:#       -m maximum number of sequences to be fetched
#:#       -t bfile or fmt=text|json
#:#       -o outdir (for -t bfile only)
#---------------------------------
use strict;
use integer;
use warnings;

my $TIMESTAMP = &iso_time(time());
# get options
my $action = "comp";
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $numseq = 8;
my $maxnum = 65536;
my $type   = "ajson"; # for $outdir
my $fmt    = "json";  # for OEIS request parameter &ftm=
my $outdir = "./temp/$type";
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\-m}) {
        $maxnum   = shift(@ARGV);
    } elsif ($opt =~ m{\-n}) {
        $numseq   = shift(@ARGV);
    } elsif ($opt =~ m{\-o}) {
        $outdir   = shift(@ARGV);
    } elsif ($opt =~ m{\-t}) {
        $type     = shift(@ARGV);
        $fmt      = $type;
        $fmt      =~ s{ajson}{json};
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
if ($type =~ m{bfile}) {
    $numseq = 1;
}
$maxnum /= $numseq;
#----
my $buffer = "";
my $count_id  = 0;
my $count_cmd = 0;
my $aseqno;
while (<>) {
    my $line = $_;
    if ($count_cmd <= $maxnum) {
        if ($line =~ m{\A(A\d+)}) { # has A-number
            $aseqno = $1;
            $buffer .= "|id:$aseqno";
            $count_id ++;
            if ($count_id % $numseq == 0) {
                &print_buffer();
            }
        } # has A-number
    } # below command limit
} # while <>
if (length($buffer) > 0) {
    &print_buffer();
}
#----
sub print_buffer {
    $count_cmd ++;
    if ($count_cmd <= $maxnum) {
        if ($type =~ m{bfile}) {
            $buffer =~ s{\|id:(A(\d+))}{b$2.txt};
            print "--directory-prefix=$outdir https://oeis.org/$1/$buffer\n";
        } else { # json|text
            print "https://oeis.org/search?q="
                . substr($buffer, 1) . "\&fmt=$fmt\n"; # -O is set outside
        }
    }
    $buffer = "";
}
#----
sub iso_time {
    my ($unix_time) = @_;
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
    return sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
} # iso_time
__DATA__
