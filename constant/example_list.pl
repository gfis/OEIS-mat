#!perl

# Build a list of constants from the examples
# @(#) $Id$
# 2021-07-28, Georg Fischer
#
#:# Usage:
#:#   perl example_list.pl [-d debug] input > seq4_out
#--------------------------------------------------------
use strict;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

if (0 && scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $debug = 0;
my $width = 4; # number of relevant digits for boundaries
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } elsif ($opt  =~ m{w}) {
        $width     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $old_aseqno = "";
my $new_aseqno = "";
my $old_tag = "";
my $new_tag = "";
my $data = "";
my $callcode = "example";
my $offset = 0;
my $example = "";
while (<>) {
    my $line = $_;
    next if $line =~ m{\A\-\-};
    $line =~ s/\s+\Z//; # chompr
    my $pos = index($line, "/A");
    $line = substr($line, $pos + 1);
    $line =~ s{(A\d+)\.json([\:\-])\t+}{};
    $new_aseqno = $1;
    my $contin = $2;
    if ($contin eq ":") {
        $line =~ s{\A\"(\w+)\"\: }{};
        $new_tag = $1;
        if (0) {
        } elsif ($new_tag eq "data") {
            $line =~ s{[\"\,]}{}g;
            $data = $line; # substr($line, 0, 16);
            $example = ""; # maybe missing
        } elsif ($new_tag eq "offset") {
            $line =~ s{[\"](\-?\d+).*}{$1}g;
            $offset = $line;
            &output();
        }
        $old_tag = $new_tag;
        # $contin eq ":"
    } else { # $contin eq "-"
        if ($old_tag eq "example") {
            $line =~ s{\"}{}g;
            $line =~ s{\A\s*A\d{6}\s*}{};
            if ($line =~ m{\A *[a-zA-Z]* *\=? *(\-?\d*\.?\d{4}[\.\d\*\-\^\(\) ]*)}) {
                $example = $1;
                $example =~ s{ }{}g;
                $example = "??$example" if $example !~ m{\d{4}};
            } else {
                $example = "??" . substr($line, 0, 16);
            }
        } 
        # $contin eq "-"
    } # contin
} # while
sub output {
    print join("\t", $new_aseqno, $callcode, $offset, $data, $example) . "\n";
    if (($example !~ m{\A\s*\Z}) && ($example !~ m{\?})) {
        $example =~ s{\*10\^\(?\-?\d+\)?}{}; # remove exponent
        if ($example =~ s{\((\d+\))\Z}{}) { # remove certainity
            my $certain = $1;
            $example = substr($example, 0, length($example) - length($certain) - 2);
        }
        $example =~ s{\A\-}{}; # remove sign
        $example =~ s{\A0\.0*}{}; # remove 0.0*
        $example =~ s{\.\.\.\d{4}.*}{};
        $example =~ s{\D}{}g; # also dots
        if ($data !~ m{$example}) {
            print "# $new_aseqno: $example not in $data\n";
        }
    }
    $example = "";
} # output
__DATA__
../common/ajson/A000007.json:			"data": "1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
../common/ajson/A000007.json-			"name": "The characteristic function of {0}: a(n) = 0^n.",
--
../common/ajson/A000007.json:			"example": [
../common/ajson/A000007.json-				"a(4) = 0 = (1, 5, 10, 10, 5) dot (1, -1/2, 1/6 0, -1/30) = (1 - 5/2 + 5/3 + 0 - 1/6) = 0; where (1, 5, 10, 10, 5) = row 4 of triangle A074909. - _Gary W. Adamson_, Mar 05 2012"
--
../common/ajson/A000007.json:			"offset": "0,1",
../common/ajson/A000007.json-			"author": "_N. J. A. Sloane_",
../common/ajson/A000012.json:			"data": "1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1",
../common/ajson/A000012.json-			"name": "The simplest sequence of positive numbers: the all 1's sequence.",
--
../common/ajson/A000012.json:			"example": [
../common/ajson/A000012.json-				"1 + 1/(1 + 1/(1 + 1/(1 + 1/(1 + ...)))) = A001622.",
--
../common/ajson/A000012.json:			"offset": "0,1",
../common/ajson/A000012.json-			"author": "_N. J. A. Sloane_, May 16 1994",
../common/ajson/A000035.json:			"data": "0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0",
../common/ajson/A000035.json-			"name": "Period 2: repeat [0, 1]; a(n) = n mod 2; parity of n.",
--
../common/ajson/A000035.json:			"offset": "0,1",
../common/ajson/A000035.json-			"author": "_N. J. A. Sloane_",
../common/ajson/A000796.json:			"data": "3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,0,2,8,8,4,1,9,7,1,6,9,3,9,9,3,7,5,1,0,5,8,2,0,9,7,4,9,4,4,5,9,2,3,0,7,8,1,6,4,0,6,2,8,6,2,0,8,9,9,8,6,2,8,0,3,4,8,2,5,3,4,2,1,1,7,0,6,7,9,8,2,1,4",
../common/ajson/A000796.json-			"name": "Decimal expansion of Pi (or digits of Pi).",
--
../common/ajson/A000796.json:			"example": [
../common/ajson/A000796.json-				"3.1415926535897932384626433832795028841971693993751058209749445923078164062\\",
--
../common/ajson/A000796.json:			"offset": "1,1",
../common/ajson/A000796.json-			"author": "_N. J. A. Sloane_",
../common/ajson/A001113.json:			"data": "2,7,1,8,2,8,1,8,2,8,4,5,9,0,4,5,2,3,5,3,6,0,2,8,7,4,7,1,3,5,2,6,6,2,4,9,7,7,5,7,2,4,7,0,9,3,6,9,9,9,5,9,5,7,4,9,6,6,9,6,7,6,2,7,7,2,4,0,7,6,6,3,0,3,5,3,5,4,7,5,9,4,5,7,1,3,8,2,1,7,8,5,2,5,1,6,6,4,2,7,4,2,7,4,6",
../common/ajson/A001113.json-			"name": "Decimal expansion of e.",
--
