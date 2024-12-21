#!perl

# @(#) $Id$
# 2024-11-15: "/" -> D, division; *EFF=3
# 2024-07-24, Georg Fischer
#
#:# Filter seq4 records and possibly append a structure tree to parm1
#:# Usage:
#:#   perl struct.pl [-d debug] {-en|-de|-re} infile.seq4 > outfile.seq4
#:#       -d debugging mode: 0=none, 1=some, 2=more
#:#       -en structure encoding
#:#       -re structure transformation
#:#       -de structure deconding
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $debug = 0;
my $actions = "en,re,de"; # or a sublist thereof
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  eq "-d") {
        $debug     =  shift(@ARGV);
    } elsif ($opt  =~ m{\A\-(en|re|de|ec)(\,(de|re|ec))*\Z}) {
        $actions =  $1;
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my ($aseqno, $callcode, $offset, @parms, $inits, $seqlist, @rest);
my $lambda; # the outermost lambda parameter tuple
my $lamvars; # lambda expression parameter names (single lc char.)
my $root;
my $form;
my $iparm = 0; # $(PARM1)
my $semic = ";";
my $idiv  = "~"; # symbol for integer division
my $eq    = "=";
my $colon = ":";
my %tree; # maps index -> etype:formula_string
my %reft; # reference from a tree node to its parent, e.g. BC -> BB
my $nok;
my $index = 0;
my $itext = "A"; # $index encoded with uppercase letters
my $changed = 0;
my $has_ratdiv = 0; # whether the tree contains a D node with "/" (rational division)
my $dtype; # desired overall type
my $indent = ""; # in/decrease by 2 spaces


# some functions are appended; keep in sync with oeisfunc.pl!
my %zfuncs = qw(
ABS     abs
SIGN    signum
NEG     negate
CEIL    ceiling
FLOOR   floor
);
my %qiters = qw(
SU      RU
SD      RD
PR      RQ    
);
# map type to "...valueOf()", for boolean, int, Integers, Rationals, ComputableReals; keys must be increasing
my %types_vof = qw (
B       BV
I       (int)
N       ZV
Q       QV
R       CV
); 
my $ztype = "N";
# Functions and their expected types
my %ftypes = qw(
ABS     NN
BI      IIN
CEIL    NN
FA      IN
FLOOR   NN
GCD     NN,NN
MAX     NN,NN
PD      IILN
PP      NB
PR      IIILN
QV      NQ
RD      IILQ
RQ      IIILQ
RU      IIILQ
S1      IIN
S2      IIN
SD      IILN
SU      IIILN
Z2      IN
ZV      IN
);

# while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_;
    if ($line =~ m{\AA\d+\s\w+\t\-?\d+\t\S}) {
        print "#----------------------------------------------------------------\n# >$line\n" if ($debug > 0);
        $nok = 0;
        ($aseqno, $callcode, $offset, @parms) = split(/\t/, $line);
        $form = $parms[$iparm];
        #---------------- enstruct ----
        if ($actions =~ m{en}) {
            %tree = ();
            %reft = ();
            $form =~ s{ }{}g; # remove spaces
            if (length($parms[1]) == 0) {
               $parms[1] = "\"\"";
            }
            $lambda = "";
            #                1     (       )1
            if ($form =~ s{\A(\w+|\([^\)]*\))\-\>}{}) { # remember lambda parameter list
                $lambda = "$1 -> ";
            }
            $lamvars = join("", ($form =~ m{([a-z])\-\>}g)) . "n";
            $form =~ s{\-\>}{\,\,}g; # replace inner arrows by ",,"
            $form .= "    ";
            my $busy = 1;
            $index = 0; $itext = "A";
            my $startx = 0;
            my $node;
            while ($busy >= 1) {
                $changed = 0; # assume that nothing was changed; set in &store_next_node

                # JJJJ             1       ( 2     2  )1
            #   while($form =~ s[\b(J\d{6}\(n(\+\d+)?\))]                               [\{$itext\}]) { # J012345(n+2)
                while($form =~ s[\b(J\d{6}\(n\))]                                       [\{$itext\}]) { # J012345(n+2)
                    &store_next_node("J$ztype", $1);
                }

                # Nnnn           1      12        3                      3 24      4
                while($form =~ s[([\(\,])([a-z0-9]([\+\-\*\~\%\$][a-z0-9])*)([\)\,])]   [$1\{$itext\}$4]) { # integer expression with n + - * 7
                    &store_next_node("NI", $2);
                }
                # Nnnn             1         1
                while($form =~ s[\b([a-z]|\d+)]                                         [\{$itext\}]) { # integer variable or constant
                    &store_next_node("NI", $1);
                }
                # FFFF             1               (2----------23 ,4           43  )1
                while($form =~ s[\b([A-Z][A-Z0-9]+\((\{[A-J]+\})(\,(|\{[A-J]+\}))*\))]  [\{$itext\}]) { # F012345({AB}), BI({A},{B})
                    &store_next_node("F$ztype", $1);
                }

                # CC()            (1          1 )
                while($form =~ s[\((\{[A-J]+\})\)]                                      [\{$itext\}]) { # ({A})
                    $node = $1;
                    &store_next_node("C" . &get_type($node), $node);
                }

                # P^^^           12----------23    4----------43 1
                while($form =~ s[((\{[A-J]+\})([\^](\{[A-J]+\}))+)]                     [\{$itext\}]) { # {A}^{B}
                    &store_next_node("P$ztype", $1);
                }

                # M***           12----------23        4----------43 1
                while($form =~ s[((\{[A-J]+\})([\~\*\%](\{[A-J]+\}))+)]                 [\{$itext\}]) { # {A}*{B}
                    &store_next_node("M$ztype", $1);
                }

                # A+++           12----------23      4----------43 1
                while($form =~ s[((\{[A-J]+\})([\+\-](\{[A-J]+\}))+)]                   [\{$itext\}]) { # {A}+{B}
                    &store_next_node("A$ztype", $1);
                }
                # D///           12----------23      4----------43 1
                while($form =~ s[((\{[A-J]+\})([\/\~](\{[A-J]+\}))+)]                   [\{$itext\}]) { # {A}/{B}, {A}${B}
                    &store_next_node("DQ", $1);
                }
                $busy = $changed;
                if ($debug >= 3) {
                    print "# busy=$busy, form=\"$form\"\n";
                }
            } # while busy
            if (length($lambda) > 0) { # insert leading lambda parameter list
                # LL->             1      1
                if ($form =~ s[\A\{([A-Z]+)\} +]                                        [\{$itext\}  ]) {
                    $tree{$itext} = "L$ztype$lambda$colon\{$1\}";
                    &store_next_node("L$ztype", "\{$1\}$colon$lambda");
                }
            }
            # append the tree structure:
            foreach my $key (sort(keys(%tree))) {
                $form .= "$semic$key$eq$tree{$key}";
            } # foreach key
            #                  1   1
            if ($form =~ m[\A\{(\w+)\} *$semic]) {
                if ($debug >= 1) {
                    my $root = $1;
                    $indent = ""; 
                    &print_tree($root);
                }
            } else {
                $nok = "noroot";
            }
            foreach my $lowvar ($form =~ m{([a-z])}g) {
                if (index($lamvars, $lowvar) < 0) {
                    $nok = "unk_$lowvar";
                }
            } # foreach $lowvar
            if ($index <= 2) {
                $nok = "ix<=2";
            }
        } # -en
        #---------------- destruct ----
        if ($actions =~ m{de}) { 
        #   if ($actions !~ m{en}) { # no previous encoding - reconstruct the tree:   
                $has_ratdiv = "";
                $root = &build_tree($form);
        #   } # reconstructed
            &entype_tree($root);
            &dump_tree($root) if ($debug >= 2);
            $indent = ""; &print_tree($root) if ($debug >= 1);
            $form = &generate($root);
            $form =~ s{$idiv}{\/}g;
            if ($dtype eq "Q") {
                $form .= ".num()";
            }
        }
        #---------------- finish ----
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
#-------- end of main --------
#----
sub entype_tree { # force type of 1st child
    my ($parent) = @_;
    #                1   1
    $parent =~ s[\A\{(\w+)\}\Z][$1]; # remove any surrounding { } 
    my ($code, $node) = split(/$colon/, $tree{$parent}, 2);
    my $etype = "$ztype"; # default
    if ($code =~ m{([A-Z])([A-Za-z])}) { # separate into 2 uppercase letters
        ($code, $etype) = ($1, $2);
    }
    #                           1       1
    my @node_list = ($node =~ m[(\{\w+\})]g);
    if (0) {
    #----
    } elsif ($code =~ m{[ADMP]}) {
        for (my $il = 0; $il < scalar(@node_list); $il ++) {
            &entype_tree($node_list[$il]);
        }
        #                       1  2   2  1
        if ($tree{$parent} =~ m{(\{(\w+)\})}) { # first in node list
            my $child = $1;
            if (&get_type($child) ne $dtype) { # not the desired type
                &insert_vof($parent, $child);
            }
        }
        # ADMP
    #----
    } elsif ($code =~ m{[C]} ) {
        for (my $il = 0; $il < scalar(@node_list); $il ++) {
            &entype_tree($node_list[$il]);
        }
        #                       1  2   2  1
        if ($tree{$parent} =~ m{(\{(\w+)\})}) { # first in node list
            my $child = $1;
            if (&get_type($child) ne $dtype) { # not the desired type
                #&insert_vof($parent, $child);
            }
        }
    #----
    } elsif ($code =~ m{[F]} ) { # Function
        for (my $il = 0; $il < scalar(@node_list); $il ++) {
            &entype_tree($node_list[$il]);
        }
        #                1                    1
        if ($node =~ m{\A([A-Za-z][A-Z0-9_\.]*)\(}) { # extract the function's name
            my $funame = $1;
            if (0) {
            } elsif (defined($ftypes{$funame})) {
                my $futype_string = $ftypes{$funame};
                my $result_type = substr($futype_string, -1); # last letter
                if (0) {
                } elsif ($dtype eq "Q" && defined($qiters{$funame})) { # SU -> RU
                    $node =~ s{\A$funame}{$qiters{$funame}};
                    $tree{$parent} = "F$dtype$colon$node";
                #} elsif ($funame ne "QV" || &get_type($node_list[0]) ne "Q") { # no duplicate QV
                #   $node =~ s{\A$funame}{$qiters{$funame}};
                #   $tree{$parent} = "F$dtype$colon$node";
                }
            } elsif ($funame =~ m{\A[A-Z]\d{6}\Z}) {
                # ignore
            } else { 
                $nok = "unfu_$funame";
            }
            # (SU|SD|PR|PD|RU|RD|RQ)
         }
    #----
    } elsif ($code =~ m{[L]} ) { # not used
    } elsif ($code =~ m{[N]} ) {
    } elsif ($code =~ m{[J]} ) {
    #----
    } else {
    }
} # entype_tree
#----
sub propagate_up { # propagate a type to all parents of a node
    my ($child, $ctype) = @_;
    $child =~ s{[\{\}]}{}g; # remove { }
    #                    1  12  2
    $tree{$child} =~ s{\A(.)(.)}{$1$ctype}; # replace the type
    while (defined($reft{$child})) {
        $child = $reft{$child};
        $tree{$child} =~ s{\A(.)(.)}{$1$ctype};
    } # while
    print "# propagate_up child=$child, ctype=$ctype\n" if ($debug >= 3);
} # propagate_up
#----
sub insert_vof { # insert type.valueOf()
    my ($parent, $child) = @_;
    print "# insert_vof start parent=$parent, child=$child, type(child)=" . &get_type($child) . "\n" if ($debug >= 3);
    if (&get_class($child) eq "C") {
        $child =~ s{[\{\}]}{}g; # remove all { }
        $tree{$child} = "F$dtype$colon$types_vof{$dtype}(" . substr($tree{$child}, index($tree{$child}, ":") + 1) . ")";
        &propagate_up($parent, $dtype);
    } else {
        my $old_child = quotemeta($child);
        my $new_child = quotemeta("{$itext}");
        $tree{$parent} =~ s[$old_child][\{$itext\}];
        &propagate_up($parent, $dtype);
        &store_next_node("F$dtype", "$types_vof{$dtype}($child)");
    }
    if ($debug >= 3) {
        print "# insert_vof end parent=$parent, child=$child, type(child)=" . &get_type($child) . ", tree=\n";
        &print_tree($root);
        print "\n";
    }
} # insert_vof
#----
sub store_next_node { 
    my ($code, $expr) = @_;
    if (! defined($code)) {
        $code = "";
        print "# undefined code for expr=\"$expr\", form=\"$form\"\n";
    }
    $tree{$itext} = "$code$colon$expr";
    foreach my $child ($expr =~ m[\{(\w+)\}]g) {
        $reft{$child} = $itext;
    }
    print "# store_next_code($code, $expr), tree{$itext}=$tree{$itext}, form=\"$form\"\n" if ($debug >= 3);
    $index ++;
    $itext = $index;
    $itext =~ tr{0123456789}
                {ABCDEFGHIJ};
    $changed = 1;
} # store_next_node
#----
sub build_tree {
    my ($form) = @_;
    %tree = ();
    %reft = ();
    my @nodes = split(/$semic/, $form);
    my $root = shift(@nodes);
    $root =~ s{[^A-Za-z]}{}g; # keep the index only
    foreach my $node (@nodes) { # store all nodes in the hash = tree
        my ($parent, $elem) = split(/$eq/, $node);
        $tree{$parent} = $elem;
        foreach my $child ($elem =~ m[\{(\w+)\}]g) {
            $reft{$child} = $parent;
        }
        if (($elem =~ m{D[Q$ztype]$colon}) && ($elem =~ m{\/})) {
            $has_ratdiv = $parent;
        }
        print "# add tree{$parent}=$elem\n" if ($debug >= 4);
    } # foreach $node
    $dtype = (length($has_ratdiv) > 0) ? "Q" : "$ztype";
    if ($debug >= 1) {
        print "# has_ratdiv=\"$has_ratdiv\", dtype=$dtype\n";
        &dump_tree($root);
    }
    $index = $root;
    $index =~ tr{ABCDEFGHIJ}
                {0123456789};
    $index ++;
    $itext = $index;
    $itext =~ tr{0123456789}
                {ABCDEFGHIJ};
    $indent = ""; &print_tree($root) if ($debug >= 2);
    return $root;
} # build_tree
#----
sub generate { # expand a node (recursively), and generate code for it
    my ($parent) = @_;
    my ($oper, $elem, $il, @list);
    my $result = "";
    if ($parent =~ m{\A\{([A-Z]+)\}\Z}) { # reference to another node
        $parent = $1;
    }
    my ($code, $node) = split(/$colon/, $tree{$parent}, 2);
    my $etype = "$ztype";
    if ($code =~ m{([A-Z])([A-Za-z])}) {
        ($code, $etype) = ($1, $2);
    }
    print "# generate tree{$parent}=\"$tree{$parent}\", code=$code, etype=$etype, node=\"$node\"\n" if ($debug >= 3);
    if (0) {

    } elsif ($code =~ m{[ADMP]}) {
            @list = split(/([\+\-\*\/\~\^])/, $node);
            for ($il = 0; $il < scalar(@list); $il ++) {
                $elem = $list[$il];
                if ($il == 0) {
                    $result .= &generate($elem);
                } elsif ($elem =~ m{([\+\-\*\/\^\~])}) {
                    $oper = $elem;
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= ".$oper(" . $elem . ")";
                } else {
                    if (&get_class($elem) =~ m{[C]}) {
                        $result .= ".$oper"  . &generate($elem);
                    } else {
                        $result .= ".$oper(" . &generate($elem) . ")";
                    }
                }
            }

    } elsif ($code eq "C") {
            $result .= "(" . &generate($node) . ")";

    } elsif ($code eq "F") { # ;3=F:D000290({1});
        # FFFF   
        if (0) {
        #                     1              1 (23-----------34 5-----------54 2 )
        } elsif ($node =~ m{\b([A-Z][A-Z0-9]+)\(((\{[A-Z]+\})(\,(|\{[A-Z]+\}))*)\)}) {
            my $funame = $1;
            my $fzname = $zfuncs{$funame}; # when it is a Z method that must be appended
            my $reflist = $2;
            if (defined($fzname)) {
                if (0) {
                } elsif ($funame eq "FLOOR") {
                    $result .= "(";
                } elsif ($funame eq "CEIL") {
                    $result .= "(-(-(";
                } else { # append
                    $result .= "(";
                }
            } else {
                if ($dtype eq "Q" && (defined($qiters{$funame}))) { # patch the Z iterators into Q iterators: SU -> RU, SD - RD, PR -> RQ
        #            $funame = $qiters{$funame};
        #            $tree{$parent} = "FQ$colon$funame($reflist)";
        #            print "# patch Z iterators: funame=$funame, tree{$parent}=$tree{$parent}, node=\"$node\"\n" if ($debug >= 2);
                } 
                $result .= "$funame(";
            }
            @list = split(/(\,)/, $reflist);
            $il = 0;
            while ($il < scalar(@list)) {
                $elem = $list[$il];
                if ($il == 0) {
                    $result .= &generate($elem);
                    # $result .= &force_1st_type($elem, $parent);
                } elsif ($elem eq ",") {
                    $oper = ", ";
                } elsif ($elem =~ m{\A\Z}) { # empty - was a lambda arrow
                    $il ++; # skip the 2nd comma
                    $oper = " -> ";
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= "$oper$elem";
                } else {
                    $result .= "$oper" . &generate($elem);
                }
                $il ++;
            } # while $il
            if (defined($fzname)) {
                if (0) {
                } elsif ($funame eq "FLOOR") {
                    $result .= "(";
                } elsif ($funame eq "CEIL") {
                    $result .= ")))";
                } else { # append
                     $result .= ").$fzname()";
                }
            } else {
                $result .= ")";
            }
        } else {
            $nok = "syntax";
            $result .= "<?syntax parent=$parent,node=$node?>";
        }

    } elsif ($code eq "J") { # ;1=J:J059253(n); parameter is no expression of n
            $result .= $node;

    } elsif ($code eq "L") {
            my ($tref, $lparm) = split(/$colon/, $node); # must be: reference, lambda parmlist
            $result .= $lparm . &generate($tref);

    } elsif ($code eq "N") { # ;2=n/k;
            $result .= $node;

    }
    print "# generate result=\"$result\"\n" if ($debug >= 3);
    return $result;
} # generate
#----
sub get_class {
    my ($node) = @_;
    $node =~ s{[\{\}]}{}g; # remove { }
    my $result = substr($tree{$node}, 0, 1);
    print "# get_class($node) -> $result\n" if ($debug >= 2);
    return $result;
} # get_class
#----
sub get_type {
    my ($node) = @_;
    $node =~ s{[\{\}]}{}g; # remove { }
    my $result = substr($tree{$node}, 1, 1);
    print "# get_type($node)  -> $result\n" if ($debug >= 2);
    return $result;
} # get_type
#----
sub print_tree { # print a legible representation of the node (recursively): indented tree
    my ($parent) = @_;
    #                1   1
    $parent =~ s[\A\{(\w+)\}\Z][$1]; # remove any surrounding { } 
    my $node = $tree{$parent};
    print "$indent$parent=$node\n";
    #                        1       1
    foreach my $child(split(/(\{\w+\})/, $node)) {
        if ($child =~ m{\{(\w+)\}}) {
            $indent .= "  ";
            &print_tree($child);
            $indent = substr($indent, 2);
        }
    } # foreach child
} # print_tree
#----
sub dump_tree { # print the internal representation of the tree
    my ($parent) = @_;
    print "# dump_tree: $parent    ";
    my $result = "";
    foreach my $key(sort(keys(%tree))) {
        $result .= "$semic$key=$tree{$key}";
    } # foreach $key
    print "$result\n";
    print "reft=";
    $result = "";
    foreach my $key(sort(keys(%reft))) {
        $result .= " $key->$reft{$key}";
    } # foreach $key
    print "$result\n";
} # dump_tree
#----
sub flatten_tree { # print an expression with node information interspersed
    my ($parent) = @_;
    #                1   1
    $parent =~ s[\A\{(\w+)\}\Z][$1]; # remove any surrounding { } 
    my $node = $tree{$parent};
    #                        1       1
    print "<";
    foreach my $elem(split(/(\{\w+\})/, $node)) {
        if (0) {
        } elsif ($elem =~ m{\{(\w+)\}}) {
            &flatten_tree($elem);
        } else {
            print $elem;
        }
    } # foreach child
    print ">";
} # flatten_tree
#----
sub swap_node { # swap M and A nodes if the first operand is of simpler type than the second (I < Z, Z < Q, Q < R)
    my ($parent) = @_;
    my ($oper, $elem, $il, @list);
    my $result = "";
    if ($parent =~ m{\A\{([A-Z]+)\}\Z}) { # reference to another node
        $parent = $1;
    }
    my ($code, $node) = split(/$colon/, $tree{$parent}, 2);
    my $etype = "Z";
    if ($code =~ m{([A-Z])([A-Za-z])}) {
        ($code, $etype) = ($1, $2);
    }
    print "# swap_node1 tree{$parent}=\"$tree{$parent}\", code=$code, etype=$etype, node=\"$node\"\n" if ($debug >= 2);
    if (0) {
    } elsif ($code =~ m{\A[AM]\Z}) { # add, mul node
            @list = split(/([\+\-\*\%])/, $node);
            $il = 0; 
            while ($il < scalar(@list)) {
                $elem = $list[$il];
                print "#   swap_node2 elem=$elem\n" if ($debug >= 2) ;
                if ($elem =~ m{[\+\*]}) { # commutative operators
                    my $ltype = &get_type($list[$il - 1]);
                    my $rtype = &get_type($list[$il + 1]);
                    print "#     swap_node3 ltype=$ltype, rtype=$rtype\n" if ($debug >= 2) ;
                    if ($ltype eq "I" && $rtype eq "Z") { # swap
                        my $temp       = $list[$il - 1];
                        $list[$il - 1] = $list[$il + 1];
                        $list[$il + 1] = $temp;
                        print "#       swap_node4 swapped: $list[$il - 1] $list[$il] $list[$il + 1]\n" if ($debug >= 2);
                        $il ++; # the following was the left operand - it's already processed, skip it
                    }
                }
                $il ++;
            } # while il
            $node = join("", @list); # with possibly swapped elements
            $tree{$parent} = "$code$etype$colon$node";
            @list = $node =~ m{(\{\w+\})}g;
            for ($il = 0; $il < scalar(@list); $il ++) { # walk into all subnodes
                &swap_node($list[$il]);
            }
    } else { # all other nodes 
            #                    1     1
            @list = $node =~ m{(\{\w+\})}g;
            for ($il = 0; $il < scalar(@list); $il ++) { # walk into all subnodes
                &swap_node($list[$il]);
            }
    }
    print "# swap_node5 node=\"$node\"\n" if ($debug >= 2);
    return $result;
} # swap_node
#----
sub polish_form {
    # polish ".^()"
    $form =~ s{\b2\.\^\(}                                               {Z2\(}g;               # 2^x -> Z2(x)
    #            1   1
    $form =~ s{\b(\w+)\.\^\(}                                           {ZV($1).\^\(}g;        # x^.(y)  -> ZV(x).^(y)
    #          1                  12         3                     3 2
    $form =~ s{(\-\> *|[^A-Z0-9]\()([a-z0-9]+([\+\-\*\~\%][a-z0-9]+)*)} {${1}ZV\($2\)}g;       # -> ???
    #            1         2                     2 1
    $form =~ s{\A([a-z0-9]+([\+\-\*\~\%][a-z0-9]+)*)}                   {ZV\($1\)}g;           # 
    $form =~ s{\~}{\/}g;

    # polish ".$(ZV(17))" -> integer division without rest
    #                    1   1
    $form =~ s{\.$idiv\(ZV\((\d+)\)\)}      {/$1}g;
    #           1   1
    $form =~ s{$idiv(\d+)}                  {/$1}g;
    
    # polish superfluous brackets
    #           (1 (ZV (       ) )1 )
    $form =~ s{\((\(ZV\([^\)]+\)\))\)}                                  {$1}g;                 # ((ZV(...))) -> (ZV(...))
    
    # polish ".^(ZV(...))"
    #           . ^ (ZV (1      1 ) )
    $form =~ s{\.\^\(ZV\(([^\)]+)\)\)}                                  {\.\^\($1\)}g;         # ".^(ZV(...))" -> .^(...)
}
__DATA__
A243035	lsmtraf	0	n -> 9*10^(FA(n)-1)	"1,2,3"
A229361	lsmtraf	0	n -> 97+41*Z2(n)+21*3^n+13*4^n+8*5^n+5*6^n+3*7^n+2*8^n+9^n+10^n
A163545	lsmtraf	0	n -> D000290(J059252(n))+D000290(J059253(n))
A163547	lsmtraf	0	n -> D000290(J059253(n))+D000290(J059252(n))	"1,2,3"
A365161	lsmtraf	0	n -> D001223(J059305(n)-1)	"1,6,1"
A120355	lsmtraf	0	n -> D002034(ABS(n))+FA(n)*NEG(k+1)^Z2(n-1)	""
A162455	multraf	0	(self,n) -> D002061(F000142(BI(n-1, k-3))+1)	""	new A171819()
A324115	lsmtraf	0	n -> SU(0, n, k -> D002487(E323244(k)*2))
A131822	sintrif	0	(term, n) -> D003961(J036035(n-1)+n-3)
A226355	lambdan	0	n -> 1+4*n+4*SU(1,n,k->F000005(k~2))
A255541	lambdan	0	n -> 1+SU(1,2^n-1,k->F000010(k%2))
A135570	lambdan	0	n -> 1+SU(1,n,i->S2(i)*2^i)
A368638	lambdan	0	n -> 1+SU(1,n,i->BI(n-i+2,2)*F000010(i))
A255170	lambdan	0	n -> 1-n+SU(1,n,k->M000081(k))
