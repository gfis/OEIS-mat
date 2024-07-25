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
my $slash = "/";
my %tree; # maps index -> etype:formula_string
my $nok;

# some functions are appended; keep in sync with oeisfunc.pl!
my %afuncs = qw(
ABS             abs
SIGN            signum
NEG             negate
);

# while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_;
    if ($line =~ m{\AA\d+\s\w+\t\-?\d+\t\S}) {
        if ($debug > 0) {
            print "$line\n";
        }
        $nok = 0;
        ($aseqno, $callcode, $offset, @parms) = split(/\t/, $line);
        $form = $parms[$iparm];

        if ($actions =~ m{en}) {
            %tree = ();
            $form =~ s{ }{}g;
            $parms[1] = $parms[1] || "\"\"";
            $parms[2] = $parms[2] || "";
            $parms[3] = $form;
            $lambda = "";
            #                1     (       )1
            if ($form =~ s{\A(\w+|\([^\)]*\))\-\>}{}) { # remember lambda parameter list
                $lambda = "$1 -> ";
            }
            $form =~ s{\-\>}{\,}g; # replace inner arrows
            $form .= "    ";
            my $busy = 1;
            my $index = 0;
            while ($busy >= 1) {
                my $changed = 0; # assume that nothing was changed

                # L ->           1                2         21  3       3
                while($form =~ s{(\{\d+\}|[ijkn]|\([a-z\,]+\))µ(\{\d+\})}               {\{$index\}}) { # J012345(n+2)
                    $tree{$index} = "L$slash$1µ$2";
                    print "# whileL tree{$index} = $tree{$index}, form=\"$form\"\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }

                # JJJJ             1       ( 2     2  )1
                while($form =~ s{\b(J\d{6}\(n(\+\d+)?\))}                         {\{$index\}}) { # J012345(n+2)
                    $tree{$index} = "J$slash$1";
                    print "# whileJ tree{$index} = $tree{$index}, form=\"$form\"\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }

                # Nnnn           1                             1
                while($form =~ s{([ijkn0-9]([\+\-\*][ijkn0-9])+)}                 {\{$index\}}) { # integer expression with n + - * 7
#               while($form =~ s{([\+\-\*0-9i-n]+)}                               {\{$index\}}) { # integer expression with n + - * 7
                    $tree{$index} = "N$slash$1";
                    print "# whilen tree{$index} = $tree{$index}, form=\"$form\"\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }

                my $start_index = $index;
                # FFFF             1               (2-----------23 ,4-----------43  1)
                while($form =~ s{\b([A-Z][A-Z0-9]+\((\{\d+\}|\d+)(\,(\{\d+\}|\d+))*\))}  {\{\#\}}) { # F012345({17}), BI({1},{2})
                    $tree{$index} = "F$slash$1";
                    print "# whileF tree{$index} = $tree{$index}, form=\"$form\"\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }
                for (my $ix = $start_index; $ix < $index; $ix ++) {
                    $form =~ s{\#}{$ix};
                }

                # P^^^           12-----------23    4-----------43 1
                while($form =~ s{((\{\d+\}|\d+)([\^](\{\d+\}|\d+))+)}                          {\{$index\}}) { # {2}^{3}
                    $tree{$index} = "P$slash$1";
                    print "# while^ tree{$index} = $tree{$index}, form=\"$form\"\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }

                # M***           12-----------23      4-----------43 1
                while($form =~ s{((\{\d+\}|\d+)([\*\%](\{\d+\}|\d+))+)}                        {\{$index\}}) { # {2}*{3}
                    $tree{$index} = "M$slash$1";
                    print "# while* tree{$index} = $tree{$index}, form=\"$form\"\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }

                # A+++           12-----------23      4-----------43 1
                while($form =~ s{((\{\d+\}|\d+)([\+\-](\{\d+\}|\d+))+)}                        {\{$index\}}) { # {2}+{3}
                    $tree{$index} = "A$slash$1";
                    print "# while+ tree{$index} = $tree{$index}, form=\"$form\"\n" if ($debug >= 1);
                    $index ++;
                    $changed = 1;
                }
                $busy = $changed;
            } # while busy
            if (length($lambda) > 0) {
                if ($form =~ s{\A\{(\d+)\} *}{\{$index\}    }) {
                    $tree{$index} = "L$slash$lambda$slash\{$1\}";
                    $index ++;
                }
            }
            # append the tree structure:
            foreach my $key (sort(keys(%tree))) {
                $form .= "$sep$key$eq$tree{$key}";
            } # foreach key
            if ($form !~ m{\A\{\d+\} *$sep}) {
                $nok = "noroot";
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
                    if ($debug >= 2) {
                        print "# add tree{$index}=$elem\n";
                    }
                } # foreach $node
            } # reconstructed
            # now walk over all nodes of the tree and expand them
            $form = &expand_node($root);
        } # -de

        $parms[$iparm] = "$form"; # original formula with structure tree elements appended
        if ($nok ne "0") {
            print STDERR join("\t", $aseqno, $nok     , $offset, @parms) . "\n";
        } else {
            print        join("\t", $aseqno, $callcode, $offset, @parms) . "\n";
        }
    } else {
        # ignore lines without A-numbers
    }
} # while
#----
sub expand_node { # expand a node (recursive)
    my ($index) = @_;
    my @list;
    my $result = "";
    my ($oper, $elem, $il);
    if ($index =~ m{\A\{(\d+)\}\Z}) { # reference to another node
        $index = $1;
    }
    my ($code, $node) = split(/$slash/, $tree{$index}, 2);
    if ($debug >= 2) {
        print "# expand_node tree{$index}=\"$tree{$index}\", code=$code, node=\"$node\"\n";
    }
    if (0) {
    } elsif ($code eq "P") {
            @list = split(/(\^)/, $node);
            for ($il = 0; $il < scalar(@list); $il ++) {
                $elem = $list[$il];
                if ($il == 0) {
                    $result .= ($elem =~ m{\A(\d+)\Z}) ? "ZV($1)" : &expand_node($elem);
                } elsif ($elem eq "^") {
                    $oper = $elem;
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= ".$oper(" . $elem . ")";
                } else {
                    $result .= ".$oper(" . &expand_node($elem) . ")";
                }
            }
    } elsif ($code eq "M") {
            @list = split(/(\*)/, $node);
            for ($il = 0; $il < scalar(@list); $il ++) {
                $elem = $list[$il];
                if ($il == 0) {
                    $result .= ($elem =~ m{\A(\d+)\Z}) ? "ZV($1)" : &expand_node($elem);
                } elsif ($elem eq "*") {
                    $oper = $elem;
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= ".$oper(" . $elem . ")";
                } else {
                    $result .= ".$oper(" . &expand_node($elem) . ")";
                }
            }
    } elsif ($code eq "L") {
            @list = split(/(µ)/, $node);
            for ($il = 0; $il < scalar(@list); $il ++) {
                $elem = $list[$il];
                if (0) {
                } elsif ($elem eq "µ") {
                    $oper = " -> ";
                } elsif ($elem =~ m{\A\(}) { # (term,n)
                    $result .= "$elem";
                } elsif ($elem =~ m{\A[ijkn]\Z}) { # n
                    $result .= "$elem";
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= "$oper$elem";
                } else {
                    $result .= "$oper" . &expand_node($elem);
                }
            }
    } elsif ($code eq "A") {
            @list = split(/([\+\-])/, $node);
            for ($il = 0; $il < scalar(@list); $il ++) {
                $elem = $list[$il];
                if ($il == 0) {
                    $result .= ($elem =~ m{\A(\d+)\Z}) ? "ZV($1)" : &expand_node($elem);
                } elsif ($elem eq "-") { # ignore
                    $oper = $elem;
                } elsif ($elem eq "+") { # ignore
                    $oper = $elem;
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= ".$oper(" . $elem . ")";
                } else {
                    $result .= ".$oper(" . &expand_node($elem) . ")";
                }
            }
    } elsif ($code eq "F") { # ;3=F/D000290({1});
        # FFFF                1               (2-----------23 ,4-----------43  1)
        #  while($form =~ s{\b([A-Z][A-Z0-9]+\((\{\d+\}|\d+)(\,(\{\d+\}|\d+))*\))}  {\{\#\}}) { # F012345({17}), BI({1},{2})
        if (0) {
        #                     1              1 (23-----------34  5-----------54 2 )
        } elsif ($node =~ m{\b([A-Z][A-Z0-9]+)\(((\{\d+\}|\d+)(\,(\{\d+\}|\d+))*)\)}) {
            my $funame = $1;
            my $reflist = $2;
            $result = "$funame(";

            @list = split(/(\,)/, $reflist);
            for ($il = 0; $il < scalar(@list); $il ++) {
                $elem = $list[$il];
                if ($il == 0) {
                    $result .= ($elem =~ m{\A(\d+)\Z}) ? "$elem" : &expand_node($elem);
                } elsif ($elem eq ",") {
                    $oper = $elem;
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= ", $elem";
                } else {
                    $result .= ", " . &expand_node($elem);
                }
            }

            $result .= ")";
        } else {
            $nok = "syntax";
            $result .= "<?syntax?>";
        }
    } elsif ($code eq "J") { # ;1=J/J059253(n);
        $result .= $node;
    } elsif ($code eq "N") { # ;2=n/k;
        $result .= $node;
    }
    if ($debug >= 3) {
        print "# expand_node result=\"$result\"\n";
    }
    return $result;
} # expand_node
__DATA__
A243035	lsmtraf	0	n -> 9*10^(FA(n)-1)	"1,2,3"
A229361	lsmtraf	0	n -> 97+41*Z2(n)+21*3^n+13*4^n+8*5^n+5*6^n+3*7^n+2*8^n+9^n+10^n
A163545	lsmtraf	0	n -> D000290(J059252(n))+D000290(J059253(n))
A163547	lsmtraf	0	n -> D000290(J059253(n))+D000290(J059252(n))	"1,2,3"
A365161	lsmtraf	0	n -> D001223(J059305(n)-1)	"1,6,1"
A120355	lsmtraf	0	n -> D002034(ABS(n))+FA(n)*NEG(k)^Z2(n)	""
A162455	multraf	0	(self,n) -> D002061(F000142(BI(n, 3))+1)	""	new A171819()
A324115	lsmtraf	0	n -> SU(0, n, k -> D002487(E323244(k)*2))
A131822	sintrif	0	(term, n) -> D003961(J036035(n-1)+n-3)
