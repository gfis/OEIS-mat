#!perl

# Check blocks of records for the necessary formula, skip and prepend operations
# @(#) $Id$
# 2023-08-12, Georg Fischer: copied from match_align.pl
#
#:# usage:
#:#   perl gcd_check.pl [-d debug] [-s start] [-w width] input.seq4 > output.seq4
#:#       -d debugging output: 0 (none), 1 (some), 2 (more)
#:#       -s maximum number of leading terms to be ignored (default: 4)
#:#       -w number of terms to be compared (dfault: 4)
#
# $o... = target, $n... = source
#---------------------------------
use strict;
use integer;

my $jcat25 = "jcat25_extract.tmp";
my $debug   = 0; # 0 (none), 1 (some), 2 (more)
my $start   = 4; # number of leading terms to be ignored, cf. &adjust
my $width   = 4; # number of terms to be compared, cf. & adjust
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\-d}) {
        $debug    = shift(@ARGV);
    } elsif ($opt =~ m{\-s}) {
        $start    = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while ARGV
#----------------
my  ($aseqno, $callcode, $offset1, $formula, $rseqno); # for new seq4 record
my  ( $oseqno, $occ, $ooff, $ogcd 
    , $nseqno, $ncc, $noff, $ngcd, $odata, $ndata);
my  ($factor, $shift);
$/ = "\n\n"; # blocks separated by empty lines
while (<>) {
    next if ! m{\AA\d{6}}; # must start with oseqno
    my $block = $_;
    $block =~ s/\s+\Z//m; # chompr
    $block =~ s{twice[^A]*(A\d{6})}  {\[twice\:\] 2\*$1}mg; 
    $block =~ s{half[^A]*(A\d{6})}   {\[half\:\] \(1\/2\)\*$1}mg; 
    my $ok = 0;
    my @lines = grep { ! m{Conject|Seem|App(ear|arent|differ)}i } split(/\n/, $block);
    ( $oseqno, $occ, $ooff, $ogcd 
    , $nseqno, $ncc, $noff, $ngcd, $odata, $ndata) = split(/\t/, $lines[0]);
    $odata =~ s{\,\-?\d*\Z}{}; # remove last (incomplete) term
    $ndata =~ s{\,\-?\d*\Z}{}; # remove last (incomplete) term
    $aseqno   = $oseqno;
    $callcode = "simgcd";
    $offset1  = $ooff;
    $rseqno   = "new $nseqno()";
    $factor   = 1;
    $shift    = 0;
    $formula  = "";
    if (1) { 
    # ignore all following tests
    #                              1   1                 2     3       3  2
    } elsif ($block =~ m{essential}i) {
        $factor = 1;
        $formula = "";
        $ok = 1;
    #                              1   1                 2     3       3  2
    } elsif ($block =~ m{\(?1 *\/ *(\d+)\)? *\*? *$nseqno(\(n *(\- *\d+)\))?}) {
        $factor = $1;
        $shift  = $3 || 0;
        if ($factor == $ngcd || $factor == $ogcd) {
            $ok = 1;
            $formula = ".divide($factor)";
        }
    #                           1     2       2  1       3   3
    } elsif ($block =~ m{$nseqno(\(n *(\- *\d+)\))? *\/ *(\d+)}) {
        $factor = $3;
        $shift  = $2 || 0;
        if ($factor == $ngcd || $factor == $ogcd) {
            $ok = 1;
            $formula = ".divide($factor)";
        }
    #                    1   1             2     3       3  2
    } elsif ($block =~ m{(\d+) *\* *$nseqno(\(n *(\- *\d+)\))?}) {
        $factor = $1;
        $shift  = $3 || 0;
        if ($factor == $ngcd || $factor == $ogcd) {
            $ok = 1;
            $formula = ".multiply($factor)";
        }
    #                           1     2       2  1       3   3
    } elsif ($block =~ m{$nseqno(\(n *(\- *\d+)\))? *\* *(\d+)}) {
        $factor = $3;
        $shift  = $2 || 0;
        if ($factor == $ngcd || $factor == $ogcd) {
            $ok = 1;
            $formula = ".multiply($factor)";
        }
    }  
    if ($ok == 0) { # not yet ok
        $ok = &adjust($odata, $ndata, $ogcd, $ngcd); # global $callcode, $rseqno, $formula, $occ=parm3, $ncc=parm6
    } # not yet ok

    # polishing
    $formula =~ s{\.add\(\-}                      {\.subtract\(}g;
    $formula =~ s{\.subtract\(1\)\.add\(1\)}      {}g;
    $formula =~ s{\.add\(1\)\.subtract\(1\)}      {}g;
    $formula =~ s{\.add\(1\)\.add\(1\)}           {\.add\(2\)}g;
    $formula =~ s{\.subtract\(1\)\.subtract\(1\)} {\.subtract\(2\)}g;
    $formula =~ s{(multiply|divide)\(2\)}         {$1 . "2()"}e; # shortcuts multiply2()
    
    @lines = split(/\n/, $block);
    if ($ok) {
        print        join("\t",   $aseqno , $callcode, $offset1, $rseqno, $formula, $occ, $ogcd, $odata, $ncc, $ngcd, $ndata) . "\n";
        if ($debug >= 1) {
            print        join("\n", splice(@lines, 1)) . "\n\n"; # all but 1st line of $block
        }
    } else {
        print STDERR join("\t", "?$aseqno", $callcode, $offset1, $rseqno, $formula, $occ, $ogcd, $odata, $ncc, $ngcd, $ndata) . "\n";
        if ($debug >= 1) {
            print STDERR join("\n", splice(@lines, 1)) . "\n\n"; # all but 1st line of $block
        }
    }
} # while <>
#--
sub adjust { # determine the factor, skip and prepend parameters
    # $o... = target, $n... = source
    my ($odata, $ndata, $ogcd, $ngcd) = @_; # global $callcode, $rseqno, $formula, $occ=parm3, $ncc=parm6
    my @oterms = split(/\,/, $odata);
    my $olen   = scalar(@oterms);
    my %trymul = (); # multiplicative factor
    $trymul{1    } = 1;
    $trymul{2    } = 1;
    $trymul{$ogcd} = 1;
    $trymul{$ngcd} = 1;
    my @tryopn = ("*", "/"); # operation
    my @tryada = (0, 1, -1); # add after
    my @tryadb = (0, 1, -1); # add before
    for (my $istart = 0; $istart < $start; $istart ++) {
        my @nterms = split(/\,/, $ndata); # following splice destroys nterms
        my @terms  = splice(@nterms, $istart, $olen - 2); 
        foreach my $opn (@tryopn) {
        foreach my $mul (keys(%trymul)) {
        foreach my $adb (@tryadb) {
        foreach my $ada (@tryada) {
            my @tests = ();
            foreach my $term (@terms) {
                push(@tests, ($opn eq "*") 
                    ? ($term + $adb)   * $mul + $ada 
                    : ($term + $adb)   / $mul + $ada
                    );
            } # for terms
            my $test = join(",", @tests);
            my $opos = index($odata, $test);
            if ($opos >= 0) {
                my $prepend = ($opos == 0) ? "" : substr($odata, 0, $opos - 1);
                if (length($prepend) > 0) {
                    $callcode .= "p"; # generate for PrependSequence
                    $prepend =~ s{\,\Z}{}; # remove trailing ","
                    my @prefs = split(/\,/, $prepend);
                    $occ = join(",", @prefs); # parm3
                    $ncc = ($istart == 0) ? "" : "~~    ~~{~~  skip($istart);~~}~~"; # parm6
                } else { # no prepending
                    if ($istart > 0) {
                        $rseqno .= ".skip($istart)";
                    }
                }
                if ($adb != 0) {
                    $formula .= ".add($adb)";
                }
                if ($mul != 1) {
                    $formula .= (($opn eq "*") ? ".multiply(" : ".divide(") . "$mul)";
                }
                if ($ada != 0) {
                    $formula .= ".add($ada)";
                }
                if ($debug >= 2) {
                    print "# mul=$mul adb=$adb ada=$ada istart=$istart ogcd=$ogcd ngcd=$ngcd test=$test prepend=\"$prepend\" odata=" . substr($odata, 0, 16) 
                        . " ndata=" . substr($ndata, 0, 16) . "\n";
                }
                return 1;
            }
        } # ada
        } # adb
        } # mul
        } # opn
    } # for $istart
} # adjust
#--
sub xref {
    my ($aseqno, $rseqno) = @_;
    my @lines = map {
            s/\A\s+//; s/\s+\Z//; # trim()
            $_
        } grep { m{$rseqno} } split(/\r?\n/, `grep -P \"^.[NCFY] $aseqno\" $jcat25`);
    if (scalar(@lines) > 0) {
        print "  " . join("\n  ", @lines), "\n";
    }
} # xref
# oseqno occ  ooff ogcd nseqno  ncc   noff ngcd odata                               ndata count data
__DATA__
A065689	ngcd0	1	100	A050634	yorig	1	1	0,100,8100,168100,146168100,2208	1,81,1681,1461681,220861461681,3
A065690	ngcd0	1	10	A050635	yorig	1	1	0,10,90,410,12090,4699590,176270	1,9,41,1209,469959,176270001209,
A065765	ngcd0	1	3	A065766	yorig	1	1	3,15,39,63,93,195,171,255,363,46	1,5,13,21,31,65,57,85,121,155,13
A067348	ngcd0	1	2	A058008	yorig	1	1	2,12,30,56,84,90,132,154,182,220	1,6,15,28,42,45,66,77,91,110,126
A068501	norig	1	1	A048161	yjcdm	1	2	1,2,5,9,14,29,30,35,39,50,65,69,	3,5,11,19,29,59,61,71,79,101,131
A069486	ngcd0	1	2	A006094	yorig	1	1	12,30,70,154,286,442,646,874,133	6,15,35,77,143,221,323,437,667,8
A069918	norig	1	1	A063867	yjcd0	0	2	1,1,1,1,3,5,4,7,23,40,35,62,221,	1,2,2,2,2,6,10,8,14,46,80,70,124
A070969	ngcd0	0	3	A006485	yorig	1	1	5,9,33,513,131073,8589934593,368	3,11,171,43691,2863311531,122978
