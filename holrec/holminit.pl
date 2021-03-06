#!perl
# replace initial terms for a holonomic matrix; 
# 2021-05-23, Georg Fischer: copied from rpseqhol.pl
#
#:# Usage:
#:#   perl holminit.pl [-cc holos] [-a add] [-n noterms] seq4-dump > output
#:#     MATRIX=parm1, INIT=parm2, DIST=parm3, GFTYPE=parm4, rest ... unchanged
#:#     -a  additional terms (default 1)
#:#     -cc output callcode (default: "holos")
#:#     -d  debugging level (0=none (default), 1=some, 2=more)
#:#     -n  number of terms (default: determined from the matrix and -a)
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $line = "";
my $cc = "holos";
my $add = 1;
my $nlen = 0;
my ($aseqno, $callcode, $offset, $matrix, $inits, @rest);
my $debug   = 0;
while (scalar(@ARGV) > 0 && ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt   =~ m{\-d}  ) {
        $debug      = shift(@ARGV);
    } elsif ($opt   =~ m{\-a}  ) {
        $add        = shift(@ARGV);
    } elsif ($opt   =~ m{\-cc}  ) {
        $cc         = shift(@ARGV);
    } elsif ($opt   =~ m{\-n}  ) {
        $nlen       = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

while (<>) { # from $(DBAT) -x "SELECT ... FROM seq4"
    s/\s+\Z//; # chompr
    $line = $_;
    ($aseqno, $callcode, $offset, $matrix, $inits, @rest) = split(/\t/, $line);
    # $callcode = $cc;
    $matrix =~ s{\s}{}g;
    $inits  =~ s{\s}{}g;
    $rest[0] = $rest[0] || 0;
    $rest[1] = $rest[1] || 0;
    my @terms = split(/\,/, $inits);
    if ($aseqno =~ m{\AA\d+}) { # valid aseqno
        my $mcopy = $matrix;
        my $inilen = $nlen;
        if ($nlen == 0) { # no option -n
            my @polys;
            if ($matrix =~ m{\[\[}) { # is nested
                $mcopy  =~ s{\A\[\[}{};
                $mcopy  =~ s{\]\]\Z}{};
                @polys  = split(/\]\,\[/, $mcopy);
                $inilen = scalar(@polys) + $add;
            } else {
                $mcopy  =~ s{\A\[}{};
                $mcopy  =~ s{\]\Z}{};
                @polys  = split(/\,/, $mcopy);
                $inilen = scalar(@polys) + $add;
            }
        }
        # print STDERR "inilen=$inilen\n";
        my @nterms = splice(@terms, 0, $inilen);
        print join("\t", $aseqno, $callcode, $offset, $matrix, join(",", @nterms), @rest) . "\n";
    } else {
        print "# $line\n";
    }
} # while <>
__DATA__
A253443	hiter3	0	[[0],[-32,16],[32,-15]],[0,-1]]
A254006	hiter3	0	[[0],[0,0,-3],[0],[0,0,1]]
A254322	hiter3	0	[[0],[0,-1,11],[0,-1]]
A254381	hiter3	0	[[0],[0,6,12],[0,-1]]
A254619	hiter3	0	[[0],[0,8,16],[0,-1]]
A254749	hiter3	0	[[0],[0,0],[2,2],[1,-3],[0,1]]
A254796	hiter3	0	[[0],[0,-1,4,-4],[0,-4],[0,1]]
A255381	hiter3	0	[[0],[20,-10],[7,11]],[0,-1]]
