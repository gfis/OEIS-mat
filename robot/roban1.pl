#!perl

# Extract parameters for of the form a(n) = aseqno(n) oper num
# @(#) $Id$
# 2026-10-05: copied from roban0.pl
# 2022-12-08, Georg Fischer: copied from dersimple.pl
#
#:# Usage:
#:#     grep ... jcat25.txt ... \
#:#     | perl roban1.pl [-d debug] [-f ofter_file] > $@.tmp 2> $@.rest.tmp
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#:#     -f  file with aseqno, offset1, terms (default $(COMMON)/joeis_oftea.txt)
#:# Reads ofter_file for implemented jOEIS sequences with their offsets and first terms
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $COMMON = "../common";
my $ofter_file = "$COMMON/joeis_oftea.txt";
my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-f}  ) {
        $ofter_file = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while options
#----------------
my $aseqno;
my $offset = 0;
my $line;
my $name;
my $cond; 
my $callcode = "adjext";
my @parms;
#----
my $terms;
my %ofters = ();
open (OFT, "<", $ofter_file) || die "cannot read $ofter_file\n";
while (<OFT>) {
    s{\s+\Z}{};
    ($aseqno, $offset, $terms) = split(/\t/);
    $terms = $terms || "";
    if ($offset < -1) { # offsets -2, -3: strange, skip these
    } else {
        $ofters{$aseqno} = "$offset\t$terms";
    }
} # while <OFT>
close(OFT);
print STDERR "# $0: " . scalar(%ofters) . " jOEIS offsets and some terms read from $ofter_file\n";
#----
# while (<DATA>) {
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    ($aseqno, $name, $cond) = split(/\t/, $line); 
    $name = $name || "";
    $name =~ s{ }{}g;
    $cond = $cond || ""; 
    my $nok = "";
    #                1                 1 2          2 (3      3  4         4  )5          56                   6
    if ($name =~ m{\A(\-?\d*[\+\-\*\/]?)?([A-Z]\d{6})\((\d+\*?)?n([\-\+]\d+)?\)([\+\-\*\/])([n0-9\+\-\*\/\(\)]*)\Z}) {
        my (         $pref,              $jseqno,     $ifact,    $index,       $oper,      $postf) 
            =       ($1 || "",           $2 || "",    $3 || "",  $4 || "",     $5,         $6 || "");
        @parms = ($offset);
        my $rseqno = "A" . substr($jseqno, 1);
        push(@parms, "new $rseqno()");
        push(@parms, "() -> mSeq.next()" 
            . (($pref =~ s{(\d+)\*?\Z}{$1}) > 0 ? ".*($pref)" : "") 
            . ".$oper($postf)"); 
        push(@parms, $ofters{$aseqno});
        push(@parms, $ofters{$rseqno});
        if (length($postf) > 8) {
            $nok = "postf>8"; 
            $postf = substr($postf, 0, 24) . " ...";
        }
        if (0) {
        #                               1  1   2   2
        } elsif ($cond =~ m{\Afor *n *\>(\=)? *(\d+) *\Z}) {
            my ($eq, $low) = ($1 || "", $2);
            if ($eq ne "=") {
                $low ++;
            }
            $cond = $low;
        } elsif ($cond =~ m{\A\s*\Z}) { 
            $cond = "";
        }
        $name = substr($name, 0, 16); 
        if ($nok eq "") { 
            print join("\t", $aseqno, $callcode, @parms, $name, $cond) ."\n";
        } else { 
            print STDERR join("\t", $aseqno, $name, $cond, $nok) ."\n";
        }
    } else { 
        $nok = "nomatch";
    } 
} # while
#----------------
__DATA__
A163563	J001462(n + 1) - 1
A385515	J002277(n - 12) for n >= 18
A166460	J002808(n-1)-1 for n>2
