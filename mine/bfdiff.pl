#!perl

# get 2 bf-files and compare them
# @(#) $Id$
# 2019-03-22, Georg Fischer
#
#:# usage:
#:#   perl bfdiff.pl [-d] [-l localdir] [-wget] seqno1 seqno2 > diff-listing
#:#     -d    debug (0: none, 1: some, 2: more)
#:#     -c    output milong.create.sql
#:#     -l    local directory for b-files, default ../common/bfile
#:#     -g    the files must be fetched first (with wget, implies "-l .") 
#:#     -w    width of signature line (default: 128)
#---------------------------------
use strict;
use integer;

# get options
my $debug     = 0;
my $local     = "";
my $localdir  = "../common/bfile";
my $must_wget = 0;
my $sigwidth  = 128;
my $infile    = ""; # undefined so far
my $diwid     = 10; # caution, the position of the diff indicator (" ", "|", "<", ">") relies on this!
my $dipos     = $diwid / 2 - 1; #  position of the diff indicator
my $r0pos     = $dipos     + 3; #  position of 1st digit in right column

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) { # get options
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-c}) {
    	&print_create_sql();
    	exit();
    } elsif ($opt =~ m{\-f}) {
        $infile   = shift(@ARGV);
    } elsif ($opt =~ m{\-l}) {
        $localdir = shift(@ARGV);
    } elsif ($opt =~ m{\-g}) {
        $must_wget = 1;
    } elsif ($opt =~ m{\-w}) {
        $sigwidth = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV

if (0) { # read from where
} elsif ($infile eq "") { # undefined
        &process1(join(" ", @ARGV));
} elsif ($infile eq "-") { # STDIN
    while (<>) {
        &process1($_);
    }
} else { # from -f infile
    open(INF, "<", $infile) or die "cannot read \"$infile\"\n";
    while (<INF>) {
        &process1($_);
    }
    close(INF)
}  # read from where

sub process1 { 
    my ($line) = @_;
    my @args = split(/\s+/, $line);
    # prepare both files
    my @aseqnos = ();
    my @values  = ();
    my $ianum = 0;
    while (scalar(@args) > 0) { # non-options
        my $value = shift(@args);
        push(@values, $value);
        if ($value =~ m{^A(\d{6})}) { # is an A-number, read b-file
            my $seqno = $1; 
            push(@aseqnos, $value);
            my $bfilename = sprintf("b%06d.txt", $seqno);
            my $localname = ($must_wget > 0 ? "./" : "$localdir/") . $bfilename;
            if ($must_wget > 0) {
                print `wget -q -O "$localname" https://oeis.org/$bfilename`;
            }
            print `sed -e "s/#.*//" $localname | grep -E \"^ *[\-0-9]\" | gawk \'{print \$2}\' > bfd$ianum.tmp`; 
            $ianum ++;
        } # read b-file
    } # while non-options
    my @lines = split(/\r?\n/, `diff -y --width=$diwid --expand-tabs bfd0.tmp bfd1.tmp | tee bfd2.tmp`);
    my 
    $ilin = scalar(@lines) - 1;
    my $imax = $ilin;
    while ($ilin > 0) { # truncate the tail
        $line = $lines[$ilin];
        if ((substr($line, 0, 1) ne " ") and (substr($line, 0, $r0pos) ne " ")) { 
            $imax = $ilin;
            $ilin = 0; # break loop
        }
        $ilin --;
    } # truncate the tail
    $ilin = 0;
    my $imin = $ilin;
    while ($ilin < $imax) { # truncate the head
        $line = $lines[$ilin];
        if ((substr($line, 0, 1) ne " ") and (substr($line, 0, $r0pos) ne " ")) { 
            $imin = $ilin;
            $ilin = $imax; # break loop
        }
        $ilin ++;
    } # truncate the head
    my $counts = $imax - $imin; # number of compared terms
    if ($debug > 0) {
        print STDERR "splice [$imin..$imax]\n";
    }
    # @lines = splice(@lines, $imin, $imax - $imin + 1);
    my $signature = "";
    my %hcount = ( ".", 0
                 , "<", 0
                 , ">", 0
                 , "|", 0
                 );
    my $dind;
    for ($ilin = $imin; $ilin <= $imax; $ilin ++) {
        $dind = substr($lines[$ilin], $dipos, 1);
        $dind =~ s{ }{\.};
        $signature .= $dind;
        $hcount{$dind} ++;
    } # for $ilin
    foreach my $key (sort(keys(%hcount))) {
    	if ($debug > 0) {
    		print STDERR "hcount{\"$key\"} = $hcount{$key}\n";
    	}
        $counts .= "\t$hcount{$key}";
    } # foreach $key
    $signature = substr($signature, 0, $sigwidth);
    $signature =~ tr{.|<>}{.|{}};
	print join("\t", @values, $counts, $signature) . "\n";
} # process1
#---------------------
sub print_create_sql {
	print <<"GFis";
--  Table for OEIS - mine occurrences of long terms
--  @(#) \$Id\$
--  2019-03-25: with counts, signature; cf. output of bfdiff.pl
--  2019-03-22: Georg Fischer
--
DROP    TABLE   IF EXISTS milong;
CREATE  TABLE             milong
    ( id        INT 
    , dummy     VARCHAR(4)    -- not used
    , nsame     INT           -- number of same long terms
    , aseqno    VARCHAR(10)   -- A322469
    , bseqno    VARCHAR(10)   -- A322469
    , ntotal    INT           -- no. terms diffed
    , nequal    INT           -- " " in diff -y
    , nleft     INT           -- "<"
    , nright    INT           -- ">"
    , ndiffer   INT           -- "|"
    , signature VARCHAR(130)  -- eg. ".2.2.2.2.2.2.2.2.2.2.2.2.2.2.2"
    , PRIMARY   KEY(id)         -- aseqno, bseqno)
    );
DROP    VIEW    IF EXISTS milong_view;
CREATE  VIEW    milong_view AS
    SELECT      id, nsame, aseqno, bseqno, ntotal, nequal, nleft, nright, ndiffer, signature
    FROM        milong
    WHERE nequal * 4 >= ntotal -- 1/4 are equal
    ;
COMMIT;
GFis
} # print_create_sql
#---------------------
__DATA__
0123456789
1      1
3   <
1      1
9   |  3
4   <
2      2
30  |  4
16  <
9      9
5      5
112 |  9
67  |  16
41  |  30
25  <
15     15
463 |  25
299 |  41
195 |  67
127 |  112
82  <
52     52
209 |  82
142 |  127
979 |  195
670 |  299
456 |  463
307 <
203    203
102 |  307
730 |  456
520 |  670
370 |  979