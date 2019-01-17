#!perl

# Analyze a b-file
# @(#) $Id$
# 2019-01-15, Georg Fischer
#
# usage:
#   perl bfcheck.pl [-opt] input > output
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $commandline = join(" ", @ARGV);

# get options
my $action = "gen"; # "prep"rocess for sort, "gen"erate HTML lists
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $imin   = 0;
my $imax   = -1; # unknown
my $sleep  = 8; # sleep 8 s before all wget requests
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\-s}) {
        $sleep  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------------------------------------
if (1) {
    my $filename = shift(@ARGV);
    my $buffer;
    open(FIL, "<", $filename) or die "cannot read $filename\n";
    read(FIL, $buffer, 100000000); # 100 MB
    close(FIL);
    my $mess = "";
    my $line;
    my @indexes = 
        grep { m{\S} # keep non-empty lines only
        } map { $line = $_;
            $line =~ s{\A\s*(\#.*)?}{}; # remove leading whitespace and comments
            if ($line =~ m{\A\-?\d+\s+(\-?)\d{1,}\s*\Z}) { # loose format "index term" ?
                if (length($1) > 0 and ($mess !~ m{ sign})) {
                    $mess .= " sign";
                }
            } elsif (length($line) > 0) { # non-empty line
                if ($mess !~ m{ ndig}) { # not exactly 2 numbers
                    $mess .= " ndig\@$line";
                }
            }
            $line =~ s{\s.*}{};  # remove term
            $line
        } split(/\n/, $buffer);
    $imin = shift(@indexes);
    my $ind = 0;
    my $krun = $imin;
    while ($ind < scalar(@indexes)) {
        $krun ++;
        if ($indexes[$ind] != $krun) {
            $mess .= " ninc\@$indexes[$ind]";
            $krun  = $indexes[$ind];
        }
        $ind ++;
    } # while $ind
    $filename =~ m{b(\d{6})\.txt};
    my $aseqno = "A$1";
    if (length($mess) > 0 and ($mess =~ m{ n(dig|inc)})) {
        print STDERR "$aseqno\t$mess\n";
    }
    $mess = substr($mess, 1); # remove 1st space
    $imax  = pop(@indexes);
    print join("\t",
        ($aseqno, $imin, $imax, $mess)
        ) . "\n";
}
__DATA__
