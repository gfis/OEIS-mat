#!perl

# Extract parameters for of the form a(n) = aseqno(n) oper num
# @(#) $Id$
# 2026-10-05: copied from roban0.pl
# 2022-12-08, Georg Fischer: copied from dersimple.pl
#
#:# Usage:
#:#     grep ... jcat25.txt ... \
#:#     | perl roban1.pl [-d debug] > $@.tmp 2> $@.rest.tmp
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#:#     -f  file with aseqno, offset1, terms (default $(COMMON)/joeis_ofter.txt)
#:# Reads ofter_file for implemented jOEIS sequences with their offsets and first terms
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
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
my $parm1;
my $parm2;
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
        $parm1 = "new A" . substr($jseqno, 1) . "()";
        $parm2 = "() -> mSeq.next().$oper($postf)";
        if (length($postf) > 8) {
            $nok = "postf>8";
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
    } else { 
        $nok = "nomatch";
    } 
    if ($nok eq "") { 
        print join("\t", $aseqno, $callcode, $offset, $parm1, $parm2, $name, $cond) ."\n";
    } else { 
        print STDERR join("\t", $aseqno, $name, $cond, $nok) ."\n";
    }
} # while
#----------------
__DATA__
A163563	J001462(n + 1) - 1
A385515	J002277(n - 12) for n >= 18
A166460	J002808(n-1)-1 for n>2
