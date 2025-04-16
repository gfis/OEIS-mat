#!perl

# Parse the JSON and prepare fields for table seqdb
# @(#) $Id$
# 2025-04-10: copied from sequencedb
# 2021-06-25, Georg Fischer: copied from sdb_flat.pl
#
#:# Usage:
#:#     perl seqdb_parse.pl [-s] [-d] compiled_entities.json > seqdb.txt
#:#         -d debug: 0=none, 1=some, 2=more
#:#         -s keep only subset that is not implemented in jOEIS
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
my $ofter_file = "../common/joeis_ofter.txt";
my $subset  = 0;
my $prepend = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-f}  ) {
        $ofter_file = shift(@ARGV);
    } elsif ($opt   =~ m{\-s} ) {
        $subset     = 1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
my $aseqno;
my $offset = 1;
my $terms;
my %ofters = ();
if ($subset != 0) {
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
}
#----------------
my %nums = qw (
  zer 0
  one 1
  two 2
  thr 3
  thi -3
  for 4
  fou -4
  fiv 5
  fif -5
  six -6
  sev -7
  eig -8
  nin -9
  ten 10
  ele 11
  twe 12
  );

my ($si, $mt, $ix, $px, $tags);
my $in_ps = 0;
my $in_px = 0;
my $in_tags = 0; 
my $sep = ";";

while (<>) {
    s/\s//g; # remove all whitespace
    my $line = $_;
    my $h3 = substr($line, 0, 3);
    # print "# $line\n";
    if (0) {
    } elsif ($in_ps == 1) {
        if (0) {
        } elsif ($h3 eq "}") { # end of ps
            $in_ps = 0;
            $in_px = 0;
            $in_tags = 0;
            &output();
        } elsif ($h3 eq "]\,?") {
            # ignore
        } elsif ($in_tags == 1) {
            if ($line =~ m{\"(\w+)\"}) {
                $tags .= "$1 ";
            }
        } elsif ($h3 eq "\"mt") {
            $line =~ m{\: *(\d+)};
            $mt = $1;
        } elsif ($h3 eq "\"ix") {
            $ix = substr($line, 6);
            $ix =~ s{\"\,\Z}{};
        } elsif ($h3 eq "\"px") {
            $in_px = 1;
            $px = "";
            $tags = "";
            $si ++;
        } elsif ($h3 eq "\"tags") {
            $tags = "";
            $in_tags = 1;
        } else {
            $line = substr($line, 1);
            if ($line =~ s{\"\,\Z}{}) {
                $px .= &parsez($line) . $sep;
            } else {
                $line =~ s{\"\Z}{};
                $px .= &parsez($line);
            }
        }
    } elsif ($h3 eq "\"oi") {
        $line =~ m{\: *(\d+)};
        my $seqno = $1;
        $aseqno = sprintf("A%06d", $seqno);
        if ($seqno % 4096 == 0) {
            print STDERR "parse $aseqno\n";
        }
        $si = 0;
        $mt = -1;
        $in_ps = 0;
        $in_px = 0;
        $in_tags = 0;
    } elsif ($h3 eq "\"ps") {
        $in_ps = 1;
    }
} # while <>
#----
sub output {
    my $keep = 1;
    if ($subset != 0) {
        if (! defined($ofters{$aseqno})) {
            $ix =~ s{([AC]\d\d+)}{defined($ofters{$1}) ? $1 : lc($1)}eg;
            if ($ix =~ m{[ac]\d\d+}) {
              $keep = 0;
            }
        } else { # ! defined
            $keep = 0;
        }
    }
    if ($keep == 1) {
        print join("\t", $aseqno, sprintf("%02d", $si), $mt, $ix, $px, $tags) . "\n";
    }
} # sub output
#----
sub parsez {
    my ($z) = @_;
    my $prez = "";
    my $result = $z;
    my $n = $nums{substr($z, 0, 3)};
    if (defined($n)) {
        # print "# parsez: $z ($n)\n";
        if ($n >= 0) {
                $result = "$prez$n";
        } else {
            if (0) {
            } elsif ($z =~ m{teen}) {
                $n = -$n + 10;
                $result = "$prez$n";
            } elsif ($z =~ m{ty}) {
                $result = -$n * 10;
                $z =~ s{^(twenty|thirty|fourty|fifty|sixty|seventy|eighty|ninet)}{};
                $n = $nums{substr($z, 0, 3)};
                if (defined($n)) {
                    $result += abs($n);
                }
                $result = "$prez$result";
            } else {
                $result = abs($n);
                $result = "$prez$result";
            }
        }
    }
    return $result;
} # sub parsez
#----------------
__DATA__
{
  "entities": [
    {
      "oi": 4,
      "ps": [
        {
          "ix": "0",
          "mt": 1001,
          "px": [
            "zero"
          ]
        }
      ]
    },

    {
      "oi": 8598,
      "ps": [
        {
          "ix": "16*n",
          "mt": 1001,
          "px": [
            "sixteen",
            "n",
            "*"
          ]
        }
      ]
    },
    {
      "oi": 22973,
      "ps": [
        {
          "ix": "17-n",
          "mt": 61,
          "px": [
            "seventeen",
            "n",
            "sub"
          ]
        }
      ]
    },


{
  "oi": 382963,
  "ps": [
    {
      "d": "2025-04-12",
      "ix": "A060257(n+2)-A060257(n+1)",
      "mt": 87,
      "px": [
        "n",
        "2",
        "+",
        "A060257",
        "n",
        "1",
        "+",
        "A060257",
        "sub"
      ],
      "s": "oeis",
      "tags": [
        "proven"
      ]
    }
  ]
}