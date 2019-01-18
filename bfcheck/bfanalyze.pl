#!perl

# Analyze a b-file
# @(#) $Id$
# 2019-01-18: allow for comment behind term
# 2019-01-15, Georg Fischer
#
# usage:
#   perl bfcheck.pl [-l lead] [-w seconds] [-d level] > output
#---------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
my $commandline = join(" ", @ARGV);

# get options
my $action = "gen"; # not used
my $debug  = 0; # 0 (none), 1 (some), 2 (more)
my $imin   = 0;
my $imax   = -1; # unknown
my $lead   = 8;
my $sleep  = 8; # sleep 8 s before all wget requests
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-a}) {
        $action = shift(@ARGV);
    } elsif ($opt =~ m{\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\-l}) {
        $lead  = shift(@ARGV);
    } elsif ($opt =~ m{\-w}) {
        $sleep  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------------------------------------
if ($action eq "gen") {
    my $filename = shift(@ARGV);
    my $buffer;
    open(FIL, "<", $filename) or die "cannot read $filename\n";
    read(FIL, $buffer, 100000000); # 100 MB
    close(FIL);
    my $mess = "";
    my $line;
    my $terms = "";
    my $old_index = 0;
    my $iline = 0;
    my $index;
    my $term;
    foreach my $line (split(/\n/, $buffer)) {
        $line =~ s{\A\s*(\#.*)?}{}o; # remove leading whitespace and comments
        if ($line =~ m{\A(-?\d+)\s+(\-?\d{1,})\s*(\#.*)?\Z}o) { 
            # loose    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  format "index term #?"
            my ($index, $term) = ($1, $2);
            if ((substr($index, 0, 1) eq "-" or substr($term, 0, 1) eq "-") 
                    and ($mess !~ m{ sign})) {
                $mess .= " sign";
            }
            $iline ++;
            if ($iline <= $lead) { # store the leading ones
                $terms .= ",$index:$term";
                $old_index = $index;
            } else { # check for increasing only
                if ($index != $old_index + 1) {
                    if ($mess !~ m{ ninc}) {
                        $mess .= " ninc\@$line";
                    }
                }
                $old_index = $index;
            }
        } elsif (length($line) == 0) { # was comment or whitespace
        } else { # bad
            if ($mess !~ m{ ndig}) { # not exactly 2 numbers
               $mess .= " ndig\@$line";
            }
        }
    } # foreach $line

    $filename =~ m{b(\d{6})\.txt};
    my $aseqno = "A$1";
    if (length($mess) > 0 and ($mess =~ m{ n(dig|inc)})) {
        print STDERR "$aseqno\t$mess\n";
    }
    print join("\t",
        ($aseqno, $old_index, substr($terms, 1), substr($mess, 1))
        ) . "\n";
}
__DATA__
