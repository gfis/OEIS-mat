#!perl

# Extract formulas for sums of sequences
# @(#) $Id$
# 2024-02-28: reattempt; *HHS=78
# 2023-06-13, Georg Fischer
#
#:# Usage:
#:#     perl seqsum.pl [-d debug] cat25-extract > seqsum.gen
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $line;
my $orig_eq;
my $trunc_line;
my $aseqno;
while (<>) {
    $line = $_;
    $line =~ s/\s+\Z//; # chompr
    $line =~ s{ *([\;\.\,\:\[\{]|unless|for|with|where).*}{};
    $trunc_line = $line;
    #                      1    1  2           2   3  3
    if ($line =~ s{^%[NFC] (A\d+) +(a\(\w\) *\=)? *(.*)}{}) { # starts with "a(n) = "
        $aseqno = $1;
        my $equations = $3;
        $equations =~ s{ }{}g; # remove spaces
        $equations =~ s{(\d)A}{$1\*A}g; # insert missing "*"
        foreach my $equation (split(/\=/, $equations)) { # handle multiple equations
            $orig_eq = $equation;
            &norm_output($equation);
        }
    } # starts with "a(n) = "
} # while <>
#----
sub norm_output {
        my ($summands) = @_;
        if ($summands !~ m{\A[\+\-]}) { # no leading delimiter
            $summands = "+" . $summands; # prefix with "+"
        }
        $summands =~ s{(A\d+)\(n([\+\-]\d+)\)}{$1\@$2}g; # replace Axxxxxx(n+k) by Axxxxxx@k
        $summands =~ s{\@\-}{\@\_}g; # shield "@-k"
        $summands =~ s{\@\+}{\@}g; # shield (no "@+")
        $summands =~ s{(A\d+)\(n\)}{$1}g; # replace Axxxxxx(n) by Axxxxxx
        my @parts = split(/([\+\-])/, $summands); # yield delimiters
        shift(@parts);
        if ($debug >= 1) {
            print "# $aseqno #" .join("#", @parts) . "#\t$orig_eq\n";
        }
        my $nok = 0;
        my $ip = 0;
        while ($ip < scalar(@parts)) {
            my $part = $parts[$ip];
            if (0) {
            } elsif ($part =~ m{\A[\+\-]\Z}) { # ignore delimiter
            #                     1    2       2 13         3
            } elsif ($part =~ s{\A(A\d+(\@_?\d+)?)([\*\/\d]+)\Z}{$3\*$1}) { # Axxxxxx [*/] factor: put factor at the front
            } elsif ($part =~ m{\A[\d\*\/]*A\d+(\@_?\d+)?\Z}) { # factor * Axxxxxx ok
            } elsif ($part =~ m{\A\d+\Z}) { # constant: leave it
            } else { 
                $nok = $ip + 1; # > 0: syntax error
            }
            $parts[$ip] = $part;
            $ip ++;
        } # while
        if (scalar(@parts) < 2) { 
            $nok = -1;
        }
        if ($nok == 0) {
            $summands = join(" ", @parts);
            $summands =~ s{\@\_}{\@\-}g; # unshield "@_k"
            print join(" ", "%F", $aseqno, "$summands", "\t. $orig_eq") . "\n";
        } else {
            print STDERR "# $aseqno #" .join("#", @parts) . "#\tnok=$nok, $trunc_line\n";
        }
        return join(" ", "%F", $aseqno, $summands) . "\n";
} # nomr_output
#--------------------------------------------
__DATA__
    | grep -P "^%[NFC] A\d+ (a\(\w\) *\=)( *[\+\-]? *\(?\d+(\/\d+)?\)? *(\*| ) *A\d+(\(n\))?)( *[\+\-] *\(?\d+(\/\d+)?\)? *(\*| ) *A\d+(\(n\))?)+ *(\.|unless\for\with)" \
    | perl -ne 's/ *(\.|unless\for\with).*\Z//; s/a\(n\) *\= *//; print;'\


%F A332835 a(n) = 2 * A332836(n) - A329738(n).
%F A341880 a(n) = 6 * A000005(n) - 4 * A007425(n) + A007426(n) - 4 for n > 1.