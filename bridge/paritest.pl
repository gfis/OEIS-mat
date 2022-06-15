#!perl

# Run a batch of PARI snippets and compare the results with the b-files
# 2022-06-15, Georg Fischer
#:# Usage:
#:#   perl paritest.pl input.seq4
#:#
#:# input.seq4 has tab-separated:
#:#   aseqno type offset bfimax gpline1 gpline2 ...
#--------------------------------
use strict;
use integer;
use warnings;
use POSIX;
# use IPC::Open3;
use IPC::Open2;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) = gmtime (time);
my $utc_stamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec) . "z";
if (0 and scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}

my $bfiledir = "../common/bfile";
my $debug    = 0; # 0 (none), 1 (some), 2 (more)
my $timeout  = 4; # in seconds
my $dwindow  = 4; # window of differing terms to be shown
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{bf}) {
        $bfiledir  = shift(@ARGV);
    } elsif ($opt  =~ m{dw}) {
        $dwindow   = shift(@ARGV);
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{to}) {
        $timeout   = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

# my $pid = open3(\*PIN, \*POUT, \*PERR, 'gp -fq') or die "open3() failed $!";
my $pid = open2(\*POUT, \*PIN, 'gp -fq') or die "open2() failed $!";
print PIN <<'GFis';
default(realprecision, 2000); default(parisize,1024000000);
GFis
print STDERR "Process gp created, pid = $pid\n";

# states of the automaton in &test1
my $IN_READ = 1;
my $IN_DIFF = 2;
my $IN_SKIP = 3;
# globals, overwritten by &read_bfile, used in &test1
my $offset;
my $bfimin;
my $bfimax;
my @terms;
while (<>) { # read seq4 format
    s/\s+\Z//; # chompr
    my ($aseqno, $type, $offset, $imax, @gplines) = split(/\t/);
    &test1($aseqno, $type, $offset, $imax, @gplines);
} # while seq4

sub test1 {
    # Run the test for one A-number until:
    # (1) the timeout stops the computation
    # (2) there is a difference, and a windows of following terms will be shown
    # (3) the number of required terms (bfimax - bfimin + 1) is reached
    my ($aseqno, $type, $offset, $bfimax, @gplines) = @_;
    &read_bfile($aseqno);
    foreach my $gpline(@gplines) {
        print PIN "$gpline\n";
        last; # ??? only one line for the moment
    }
    if (0) {
    } elsif ($type eq "an") {
        print PIN "alarm($timeout,for(n=$offset,$bfimax,print(a(n))))\n";
    } else {
        print STDERR "unknown type \"$type\" for $aseqno\n";
    }
    my $state = $IN_READ;
    my $index = $offset - 1;
    my $busy = 1;
    my @result = ($aseqno, 0, "pass", 0, "ms");
    my $wincount = $dwindow;
    while (<POUT>) {
        s/\s+\Z//; # chompr
        my $line = $_;
        $index ++;
        if ($debug >= 1) {
            print STDERR ($debug >= 2 ? "$aseqno ": "") . "gpout[$index]: $line\n";
        }
        if ($line =~ m{\A([\-]?\d+)}) { # next term
            my $term = $1;
            if (0) {
            } elsif ($state == $IN_READ) {
                if ($term ne $terms[$index]) { # first difference, start the window
                    $result[1] = $index;
                    $result[2] = "FAIL";
                    $result[3] = &shorten($terms[$index]);
                    $result[4] = &shorten($term);
                    $wincount  = $dwindow;
                    $state     = $IN_DIFF;
                }
            } elsif ($state == $IN_DIFF) {
                $result[3] .= "," . &shorten($terms[$index]);
                $result[4] .= "," . &shorten($term);
                $wincount  --;
                if ($wincount <= 0) {
                    $state = $IN_SKIP;
                }
            } elsif ($state == $IN_SKIP) {
            }
        } else { # some message
            if ($debug >= 1) {
                print STDERR "gpmsg[$index]: $line\n";
            }
            if (0) {
            } elsif ($line =~ m{error\(\"alarm\D+(\d+[\,\.]\d+ ms)}) {
                # error("alarm interrupt after 1,141 ms.")
                my $ms = $1;
                $ms =~ s{[\.\,]}{};
                $result[1] = $index;
                $result[2] = "FATO";
                $result[3] = $ms;
                $result[4] = "ms";
                $state     = $IN_SKIP;
                last;
            } elsif ($line =~ m{warning}) { 
                # ignore
            } else {
                $result[1] = $index;
                $result[2] = "FATAL";
                $result[3] = "";
                $result[4] = "$line";
                $state     = $IN_SKIP;
                last;
            }
        }  # some message
        if ($index >= $bfimax) {
            print join("\t", @result) . "\n";
            last;
        }
    } # while POUT
    if ($state == $IN_READ) {
        $result[1] = $index;
        $result[2] = "pass";
        $result[3] = "";
        $result[4] = "";
    }
    print join("\t", @result) . "\n";
} # test1

sub read_bfile { # parameter aseqno; writes to $offset, $bfimax, @terms
    my ($aseqno) = @_;
    my $filename = "$bfiledir/b" .substr($aseqno, 1) . ".txt";
    my $inbuffer  = "";
    open(BF, "<", $filename) || die "cannot read \"$filename\"\n";
    read(BF, $inbuffer, 100000000); # 100 MB, should be less than 10 MB
    close(BF);
    my $state  = 0;
    my $bfimin = 0;
    my $bfimax = 0;
    my @lines  = split(/\n/, $inbuffer);
    foreach my $line(@lines) {
        $line =~ s{\s+\Z}{}; # chompr
        $line =~ s{\A\s+}{}; # remove leading whitespace
        if (0) {
        } elsif ($line =~ m{\A(-?\d+)\s+(\-?\d{1,})\s*(\#.*)?\Z}o) {
            # loose format: ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ -> "index term #?"
            my ($index, $term, $comment) = ($1, $2, $3);
            $bfimax = $index;
            $state ++ ; # first term seen - skip any further comments
            if ($state == 1) { # for first term
                $bfimin = $index;
            }
            push(@terms, $term);
        } elsif ($line =~ m{\A\#})   { # ignore comment
        } elsif (length($line) == 0) { # ignore empty line
        } else { # print STDERR "** bad format: $line\n";
        }
    } # foreach line
} # read_bfile

sub shorten {
    my ($term) = @_;
    if (length($term > 16)) {
        $term = substr($term, 0, 4) . "..." . substr($term, -4);
    }
    return $term;
} # shorten
__DATA__
while (<PERR>) {
    print "err: $_";
} # while <>
