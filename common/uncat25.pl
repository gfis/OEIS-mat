#!perl

# Split a CAT25 file with the internal format, separated by empty lines
# @(#) $Id$
# 2019-03-01, Georg Fischer
#
#:# usage:
#:#   perl uncat25.pl [-m mode] [-d debug] [-i] [-o tardir] input > output
#:#   perl uncat25.pl -m text cat25.txt (split into tardir/*.txt, default)
#:#   perl uncat25.pl -m json cat25.txt (split into tardir/*.json, nyi)
#:#   perl uncat25.pl -m comp cat25.txt (compare with tardir/*.json)
#:#       -o target directory, default "./atext"
#:#       -d 0 (none), 1 (more), 2 (most)
#:#       -i (do not ignore missing JSON "id")
#---------------------------------
use strict;
use integer;

# defaults
my $mode    = "text";
my $debug   = 0;
my $needi   = 0; # do not need JSON "id" tag
my $tardir  = "./atext";

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02d\+01:00"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
if (scalar(@ARGV) == 0) { # print help text
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
#----
# get options
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     =  shift(@ARGV);
    } elsif ($opt  =~ m{m}) {
        $mode      =  shift(@ARGV);
    } elsif ($opt  =~ m{ni}) {
        $needi     = 1;
    } elsif ($opt  =~ m{o}) {
        $tardir    =  shift(@ARGV);
        $tardir    =~ s{\\}{\/}g; # convert "\" to Unix path separator
        $tardir    =~ s{\/\Z}{};  # remove trailing "/"
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----
# mapping from internal format to JSON tags and vice versa
my %codes = qw(
    A   author
    C   comment
    D   reference
    e   example
    E   ext
    F   formula
    H   link
    I   id
    K   keyword
    N   name
    o   program
    O   offset
    p   maple
    S   data
    t   mathematica
    T   data
    U   data
    Y   xref
    ); # codes
my %sedoc;
for my $key (sort(keys(%codes))) { # build the inverse mapping
    my $code = $key;
    $sedoc{$codes{$key}} = $key;
} # foreach $key
if ($debug >= 2) {
	foreach my $key (sort(keys(%sedoc))) {
    	print "sedoc{$key} = \"$sedoc{$key}\"\n";
	} # foreach
}
#----
$/ = ""; # paragraph mode, separated by one or more empty lines
my $count = 0;
my $cpara = 0;
my %texts; # accumulated lines of text format
my %jsons; # accumulated lines of JSON format
if (0) {
#--
} elsif ($mode =~ m{text}) {
    while (<>) {
        my $block = $_;
        if ($block =~ m{^\%I (A\d+)}) {
            my $aseqno = $1;
            open (OUT, ">", "$tardir/$aseqno.txt") or die "cannot write \"$tardir/$aseqno.txt\"\n";
            print OUT $block;
            print OUT "\n";
            close(OUT);
            $count ++;
        } else {
            print STDERR join("\t", sprintf("\@%06d", $cpara), "?undef_block") . "\n";
        }
        $cpara ++;
    } # while <>
    print STDERR"$cpara blocks read, $count .txt files written to $tardir\n";
#--
} elsif ($mode =~ m{json}) {
    print "\"-m json\" not yet implemented\n";
#--
} elsif ($mode =~ m{comp}) {
    while (<>) {
        my $block = $_;
        if ($block =~ m{^\%I (A(\d+))}) {
            my $aseqno = $1;
            my $seqno  = $2;
            if ($debug >= 1) {
                print "================================ $aseqno ====\n";
            } else {
            	if ($seqno % 10000 == 0) {
            		print STDERR "<= $aseqno\n"
            	}
            }
            %texts = ();
            my $line;
            my $letter; # letter in column 2
            my $tag;  # JSON element name
            my $value;
            foreach $line (split(/\n/, $block)) { # compile the internal format
                # %I A000001 N2345 M2342
                # 012345678901
                $letter = substr($line, 1, 1);
                $letter =~ tr{STU}{UUU}; # append all 3 data lines
                if (substr($line, 3, 7) ne $aseqno) {
                    print "# wrong seqno: $line\n";
                }
                $value  = length($line) >= 11 ? substr($line, 11) : "";
                $texts{$letter} .= "$value\n";
            } # foreach

            if (open (JSON, "<", "$tardir/$aseqno.json")) { # JSON found
                %jsons = ();
                $letter = "";
                $block = <JSON>;
                $tag = "";
                my $in_array = 0;
                foreach $line (split(/\n/, $block)) { # compile the JSON elements
                    # $line =~ s{\\u00(\w\w)}{chr(hex($1))}eg;
                    $line =~ s{\\u003c}{\<}g;
                    $line =~ s{\\u003e}{\>}g;
                    $line =~ s{\\u0026}{\&}g;
                    if (0) {
                    } elsif ($in_array == 1) {
                        if (0) {
                        } elsif ($line =~ m{\A\s*\"(.*)\Z}) { # string
                                $value = $1;
                                $value =~ s{\"\,?\Z}{}; # remove trailing quote
                                $value =~ s{\\\"}{\"}g; # restore inner quotes
                                $value =~ s{\\\\}{\\}g; # restore \
                                $jsons{$letter} .= "$value\n";
                        } elsif ($line =~ m{\A\s*[\{\}\]]}) { # single opening or closing brackets
                            $in_array = 0;
                        }
                    } elsif ($line =~ m{\A\s*\"(\w+)\"\s*\:\s*(\S.*)\Z}) { # "tag": value
                        $tag   = $1;
                        $value = $2;
                        $in_array = 0;
                        if ($sedoc{$tag}) { # tag occurs in internal format
                            $letter = $sedoc{$tag};
                            if (0) {
                            } elsif ($value =~ m{\A\[}          ) { # [
                                $in_array = 1;
                            } elsif ($value =~ m{\A\"(.*)\Z}    ) { # string
                                $value = $1; 
                                $value =~ s{\"\,?\Z}{}; # remove trailing quote
                                $value =~ s{\\\"}{\"}g; # restore inner quotes
                                $value =~ s{\\\\}{\\}g; # restore \
                                $jsons{$letter} .= "$value\n";
                            } elsif ($value =~ m{\A(\-?d+)}     ) { # number
                                $value = $1;
                                $jsons{$letter} .= "$value\n";
                            } else {
                                print STDERR "unparseable JSON value: \"$value\" in line \"$line\"\n";
                            }
                        } else {
                            # ignore additional JSON tags
                            if ($debug >= 2) {
                                print "# JSON tag \"$tag\" ignored\n";
                                # $in_array = 0;
                            }
                        }
                    } elsif ($line =~ m{\A\s*[\{\}\]]}) { # single opening or closing brackets
                        $in_array = 0;
                    } else {
                        print "# unparseable JSON line: \"$line\"\n";
                    }
                } # foreach JSON line
                # now compare the %texts and %jsons
                my $differs = 0;
                my $tkey = join("", sort(keys(%texts)));
                my $jkey = join("", sort(keys(%jsons)));
                if ($debug >= 2) {
                		print "\.. $aseqno \"$tkey\"\n"
                            . "\.. $aseqno \"$jkey\"\n";
                }
	            $texts{"U"} =~ s{\n}{}g;
	            $jsons{"U"} =~ s{\n}{}g;
	            $texts{"K"} =~ s{\,?(changed|new)}{}g;
	            $jsons{"K"} =~ s{\,?(changed|new)}{}g;
                foreach my $key (sort(keys(%texts))) {
                    my $valtext = $texts{$key};
                    if (0) {
                    } elsif ($valtext =~ m{\A\s*\Z}) {
                    	# empty values do not need to be present in JSON
                    } elsif (defined($jsons{$key})) {
                        my $valjson = $jsons{$key};
                        if ($valtext ne $valjson) {
                            $differs ++;
                            if ($debug >= 1) {
                                print "\%$key $aseqno \"$valtext\"\n"
                                    . "\?$key $aseqno \"$valjson\"\n";
                            }
                        } else {
                            if ($debug >= 2) {
                                print "\=$key $aseqno \"$valtext\"\n"
                                    . "\=$key $aseqno \"$valjson\"\n";
                            }
                        }
                    } elsif ($key eq "I" ) {
                    	if ($needi == 1) { 
	                        $differs = ord($key) * 1000;
                    	} else {
                    		# ignore  missing "id" tag in JSON
                    	}
                    } else {
                        $differs = ord($key) * 1000;
                        if ($debug >= 1) {
	                        print "\.. $aseqno \"$tkey\"\n"
    	                        . "\.. $aseqno \"$jkey\"\n";
        				}
                    }
                } # foreach $key
                if ($differs == 0) {
                    if ($debug >= 2) {
                        print join("\t", $aseqno, "ok") . "\n";
                    }
                } else {
                    print join("\t", $aseqno, "diff $differs") . "\n";
                }
                close(JSON);
            } else {
                print "$aseqno JSON does not exist\n";
            }
            $count ++;
        } else {
            print join("\t", "#", sprintf("\@%06d", $cpara), "?undef_block") . "\n";
        }
        $cpara ++;
    } # while <>
    print STDERR "$cpara blocks read, $count $tardir/*.json files compared\n";
#--
} else {
    die "invalid mode \"$mode\"\n";
}
sub compare {
}
#================
__DATA__
012345678901
%I A000001 M0098 N0035
%S A000001 0,1,1,1,2,1,2,1,5,2,2,1,5,1,2,1,14,1,5,1,5,2,2,1,15,2,2,5,4,1,4,1,5
%T A000001 1,2,1,14,1,2,2,14,1,6,1,4,2,2,1,52,2,5,1,5,1,15,2,13,2,2,1,13,1,2,4
%U A000001 267,1,4,1,5,1,4,1,50,1,2,3,4,1,6,1,52,15,2,1,15,1,2,1,12,1,10,1,4,2
%N A000001 Number of groups of order n.
%C A000001 Also, number of nonisomorphic subgroups of order n in symmetric gro
%C A000001 Also, number of nonisomorphic primitives of the combinatorial speci
{
    "greeting": "Greetings from The On-Line Encyclopedia of Integer Sequences! http://oeis.org/",
    "query": "id:A000081",
    "count": 3939,
    "start": 750,
    "results": [
        {
            "number": 81,
            "id": "M1180 N0454",
            "data": "0,1,1,2,4,9,20,48,115,286,719,1842,4766,12486,32973,87811,235381,634847,1721159,4688676,12826228,35221832,97055181,268282855,743724984,2067174645,5759636510,16083734329,45007066269,126186554308,354426847597",
            "name": "Number of unlabeled rooted trees with n nodes (or connected functions with a fixed point).",
            "comment": [
                "Also called \"Polya trees\" by Genitrini (2016). - _N. J. A. Sloane_, Mar 24 2017"
            ],
            "reference": [
                "N. J. A. Sloane and Simon Plouffe, The Encyclopedia of Integer Sequences, Academic Press, 1995 (includes this sequence)."
            ],
            "link": [
                "\u003ca href=\"/index/Con#confC\"\u003eIndex entries for continued fractions for constants\u003c/a\u003e"
            ],
            "formula": [
                "For n \u003e 1, a(n) = A123467(n-1). - _Falk Hüffner_, Nov 26 2015"
            ],
            "example": [
                "(End)"
            ],
            "maple": [
                "seq(a(n), n=0..50); # _Alois P. Heinz_, Sep 06 2008"
            ],
            "mathematica": [
                "terms = 31; A[_] = 0; Do[A[x_] = x*Exp[Sum[A[x^k]/k, {k, 1, j}]] + O[x]^j // Normal, {j, 1, terms}]; CoefficientList[A[x], x] (* _Jean-François Alcover_, Jan 11 2018 *)"
            ],
            "program": [
                "[a(n) for n in (0..30)] # _Peter Luschny_, Jul 18 2014 after _Alois P. Heinz_"
            ],
            "xref": [
                "Cf. A087803 (partial sums)."
            ],
            "keyword": "nonn,easy,core,nice,eigen,changed",
            "offset": "0,4",
            "author": "_N. J. A. Sloane_",
            "ext": [
                "At _David Applegate_'s suggestion, 20 has been subtracted from each entry to make this sound better with the default settings used by the OEIS MIDI player. See A144488 for the old version."
            ],
            "references": 488,
            "revision": 282,
            "time": "2019-01-21T14:58:49-05:00",
            "created": "1991-04-30T03:00:00-04:00"
        }
        }
    ]
}

my %codes = qw(     # counts in cat.2019-02-28.txt:
                    # 320583    (blank lines)
                    #      1 #  (header comment)
    A   author      # 319262 %A
    C   comment     # 183546 %C
    D   reference   #  34451 %D
    e   example     # 149748 %e
    E   ext         #  68882 %E
    F   formula     # 135229 %F
    H   link        # 212316 %H
    I   id          # 320583 %I
    K   keyword     # 320583 %K
    N   name        # 320583 %N
    o   program     # 105488 %o
    O   offset      # 320583 %O
    p   maple       #  46070 %p
    S   data        # 320583 %S
    t   mathematica # 146311 %t
    T   data        # 295998 %T
    U   data        # 278689 %U
    Y   xref        # 219634 %Y
    ); # codes
