#!perl

# @(#) $Id$
# 2024-07-24, Georg Fischer
#
#:# Filter seq4 records and possibly append a structure tree to parm1
#:# Usage:
#:#   perl struct.pl [-d debug] {-en|-de} infile.seq4 > outfile.seq4
#:#       -d debugging mode: 0=none, 1=some, 2=more
#:#       -en structure encoding
#:#       -tr structure transformation
#:#       -de structure deconding
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
my $actions = "en,tr,de"; # or a sublist thereof
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  eq "-d") {
        $debug     =  shift(@ARGV);
    } elsif ($opt  =~ m{\A\-(en|tr|de)(\,(de|tr))*\Z}) {
        $actions =  $1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($aseqno, $callcode, $offset, $form, $inits, $seqlist, @rest, $lambda, $etype, $root);
my $iparm = 0; # $(PARM1)
my @parms;
my $sep = ";";
my $eq  = "=";
my $colon = ":";
my %tree; # maps index -> etype:formula_string
my $nok;
# while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_;
    if ($line =~ m{\AA\d+\s\w+\t\-?\d+\t\S}) {
        if ($debug > 0) {
            print "$line\n";
        }
        ($aseqno, $callcode, $offset, @parms) = split(/\t/, $line);
        $nok = 0;
        my $form = $parms[$iparm];

        if ($actions =~ m{en}) {
            %tree = ();
            $form =~ s{ }{}g;
            $parms[1] = $parms[1] || "\"\"";
            $parms[2] = $form;
            $form .= "    ";
            my $busy = 1;
            my $index = 0;
            while ($busy >= 1) {
                my $changed = 0; # assume that nothing was changed
                #                  1       ( 2     2  )1  
                while($form =~ s{\b(J\d{6}\(n(\+\d+)?\))}                         {\{$index\}}) { # J012345(n+2)
                    $tree{$index} = "J$colon$1";
                    print "# whileJ tree{$index} = $tree{$index}\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }
                #                1                             1
                while($form =~ s{([\+\-\*0-9]*[i-n][\+\-\*0-9]*)}                 {\{$index\}}) { # integer expression with n + - * 7
                    $tree{$index} = "n$colon$1";
                    print "# whilen tree{$index} = $tree{$index}\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }
                #                  1                                 ( {17 } )1
                while($form =~ s{\b(([BDEFKSTU]\d{6}|[A-Z][A-Z0-9]+)\(\{\d\}\))}     {\{$index\}}) { # F012345({17})
                    $tree{$index} = "F$colon$1";
                    print "# whileF tree{$index} = $tree{$index}\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }
                #                1      2             2 1   
                while($form =~ s{(\{\d\}([\^\^]\{\d+\})+)}                        {\{$index\}}) { # {2}*{3}
                    $tree{$index} = "^$colon$1";
                    print "# while^ tree{$index} = $tree{$index}\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }
                #                1      2             2 1   
                while($form =~ s{(\{\d\}([\*\%]\{\d+\})+)}                        {\{$index\}}) { # {2}*{3}
                    $tree{$index} = "*$colon$1";
                    print "# while* tree{$index} = $tree{$index}\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }
                #                1      2             2 1   
                while($form =~ s{(\{\d\}([\+\-]\{\d+\})+)}                        {\{$index\}}) { # {2}+{3}
                    $tree{$index} = "+$colon$1";
                    print "# while+ tree{$index} = $tree{$index}\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }
                $busy = $changed;
            } # while busy
            # append the tree structure:
            foreach my $key (sort(keys(%tree))) {
                $form .= "$sep$key$eq$tree{$key}";
            } # foreach key
            if ($form !~ m{\A\{\d+\} *$sep}) {
                $nok = "nroot";
            }
        } # -en

        if ($actions =~ m{tr}) { # "tr" - structure transformation
            # nyi
        }

        if ($actions =~ m{de}) { # flatten the structure tree and introduce jOEIS infix operators
            if ($actions !~ m{en|tr}) { # no previous encoding - reconstruct the tree:
                %tree = ();
                my @nodes = split(/$sep/, $form);
                $root = shift(@nodes); 
                $root =~ s{\D}{}g; # keep the index only
                foreach my $node (@nodes) { # store all nodes in the hash = tree
                    my ($index, $elem) = split(/$eq/, $node);
                    $tree{$index} = $elem;
                } # foreach $node
            } # reconstructed
            # now walk over all nodes of the tree and expand them
            $form = &expand_node($root);
        } # -de

        $parms[$iparm] = $form; # original formula with structure tree elements appended
    } else {
        $nok = "noano"; # not starting with A-number
    }
    if ($nok ne "0") {
        print STDERR join("\t", $aseqno, $nok     , $offset, @parms) . "\n";
    } else {
        print        join("\t", $aseqno, $callcode, $offset, @parms) . "\n";
    }
} # while
#----
sub expand_node { # expand a node (recursive)
    my ($index) = @_;
    my @list;
    my $result = "";
    my ($code, $node) = split(/$colon/, $tree{$index});
    if ($debug >= 2) {
        print "# expand_node code=$code, node=$node\n";
    }
    if (0) {
    } elsif ($code eq "^") {
        @list = split(/(\^)/, $node);
        $result .= &expand_node(shift(@list));
        foreach my $elem (@list) {
            if (0) {
            } elsif ($elem eq "^") { # ignore
            } else {
                $result .= ".^(" . &expand_node($elem) . ")";
            }
        }
    } elsif ($code eq "*") {
        @list = split(/(\*)/, $node);
        $result .= &expand_node(shift(@list));
        foreach my $elem (@list) {
            if (0) {
            } elsif ($elem eq "^") { # ignore
            } else {
                $result .= ".^(" . &expand_node($elem) . ")";
            }
        }
    } elsif ($code eq "+") {
        @list = split(/([\+\-])/, $node);
        $result .= &expand_node(shift(@list));
        foreach my $elem (@list) {
            if (0) {
            } elsif ($elem eq "-") { # ignore
                $result .= ".-(" . &expand_node($elem) . ")";
            } else {
                $result .= ".+(" . &expand_node($elem) . ")";
            }
        }
    }
    return $result;
} # expand_node
__DATA__
A243035	lsmtraf	0	9*10^(FA(n)-1)	"1,2,3"
A229361	lsmtraf	0	97+41*Z2(n)+21*3^n+13*4^n+8*5^n+5*6^n+3*7^n+2*8^n+9^n+10^n
A163545	lsmtraf	0	D000290(J059252(n))+D000290(J059253(n))
A163547	lsmtraf	0	D000290(J059253(n))+D000290(J059252(n))	"1,2,3"
A365161	lsmtraf	0	D001223(J059305(n)-1)	"1,6,1"
A120355	lsmtraf	0	D002034(ABS(n))+FA(n)*NEG(k)^Z2(n)	""
A162455	lsmtraf	0	D002061(F000142(J051856(n+1))+1)
A324115	lsmtraf	0	D002487(E323244(n))
A131822	lsmtraf	0	D003961(J036035(n-1))
