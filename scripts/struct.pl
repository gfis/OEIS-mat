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
    } elsif ($opt  =~ m{\A\-(en|re|de)(\,(de|re))*\Z}) {
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
my $eq    = "=";
my $colon = ":";
my %tree; # maps index -> etype:formula_string
my $nok;
my $index = 0;
my $itext = "A";
my $changed = 0;
my $has_ratdiv = 0; # whether the tree contains a D node with "/" (rational division)

# some functions are appended; keep in sync with oeisfunc.pl!
my %zfuncs = qw(
ABS             abs
SIGN            signum
NEG             negate
CEIL            ceiling
FLOOR           floor
);

# while (<DATA>) {
while (<>) {
    s/\s+\Z//; # chompr;
    my $line = $_;
    if ($line =~ m{\AA\d+\s\w+\t\-?\d+\t\S}) {
        if ($debug > 0) {
            print ">$line\n";
        }
        $nok = 0;
        ($aseqno, $callcode, $offset, @parms) = split(/\t/, $line);
        $form = $parms[$iparm];
        #---------------- enstruct ----
        if ($actions =~ m{en}) {
            %tree = ();
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
            while ($busy >= 1) {
                $changed = 0; # assume that nothing was changed; set in &store_next_node

                # JJJJ             1       ( 2     2  )1
            #   while($form =~ s[\b(J\d{6}\(n(\+\d+)?\))]                               [\{$itext\}]) { # J012345(n+2)
                while($form =~ s[\b(J\d{6}\(n\))]                                       [\{$itext\}]) { # J012345(n+2)
                    &store_next_node("JZ", $1);
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
                    &store_next_node("FZ", $1);
                }

                # CC()            (1          1 )
                while($form =~ s[\((\{[A-J]+\})\)]                                      [\{$itext\}]) { # ({A})
                    &store_next_node("CZ", $1);
                }

                # P^^^           12----------23    4----------43 1
                while($form =~ s[((\{[A-J]+\})([\^](\{[A-J]+\}))+)]                     [\{$itext\}]) { # {A}^{B}
                    &store_next_node("PZ", $1);
                }

                # M***           12----------23        4----------43 1
                while($form =~ s[((\{[A-J]+\})([\~\*\%](\{[A-J]+\}))+)]                 [\{$itext\}]) { # {A}*{B}
                    &store_next_node("MZ", $1);
                }

                # A+++           12----------23      4----------43 1
                while($form =~ s[((\{[A-J]+\})([\+\-](\{[A-J]+\}))+)]                   [\{$itext\}]) { # {A}+{B}
                    &store_next_node("AZ", $1);
                }
                # D///           12----------23      4----------43 1
                while($form =~ s[((\{[A-J]+\})([\/\$](\{[A-J]+\}))+)]                   [\{$itext\}]) { # {A}/{B}, {A}${B}
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
                    $tree{$itext} = "LZ$colon$lambda$colon\{$1\}";
                    &store_next_node("LZ", "\{$1\}$colon$lambda");
                }
            }
            # append the tree structure:
            foreach my $key (sort(keys(%tree))) {
                $form .= "$semic$key$eq$tree{$key}";
            } # foreach key
            if ($form !~ m{\A\{[A-J]+\} *$semic}) {
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
        #---------------- restruct ----
        if ($actions =~ m{re}) { # "re" - restructuring
            if ($actions !~ m{en}) { # no previous encoding - reconstruct the tree:   
                $has_ratdiv = "";
                $root = &build_tree($form);
            } # reconstructed
            $root = &build_tree($form);
            $form = &flatten_node($root);
        }
        #---------------- destruct ----
        if ($actions =~ m{de}) { # flatten the structure tree and introduce jOEIS infix operators
            if ($actions !~ m{en|re}) { # no previous encoding - reconstruct the tree:   
                $has_ratdiv = "";
                $root = &build_tree($form);
            } # reconstructed

            # walk over all nodes of the tree and expand them
            $form = &flatten_node($root);
            &polish_form();
        } # -de
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
    $form =~ s{\.\$\(ZV\((\d+)\)\)}      {/$1}g;
    #           1   1
    $form =~ s{\$(\d+)}                  {/$1}g;
    
    # polish superfluous brackets
    #           (1 (ZV (       ) )1 )
    $form =~ s{\((\(ZV\([^\)]+\)\))\)}                                  {$1}g;                 # ((ZV(...))) -> (ZV(...))
    
    # polish ".^(ZV(...))"
    #           . ^ (ZV (1      1 ) )
    $form =~ s{\.\^\(ZV\(([^\)]+)\)\)}                                  {\.\^\($1\)}g;         # ".^(ZV(...))" -> .^(...)
}
#----
sub store_next_node { 
    my ($code, $match) = @_;
    if (! defined($code)) {
        $code = "";
        print "# undefined code for match=\"$match\", form=\"$form\"\n";
    }
    $tree{$itext} = "$code$colon$match";
    if ($debug >= 2) {
        print "# while=$code tree{$itext} = $tree{$itext}, form=\"$form\"\n";
    }
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
    my @nodes = split(/$semic/, $form);
    my $root = shift(@nodes);
    $root =~ s{[^A-Za-z]}{}g; # keep the index only
    foreach my $node (@nodes) { # store all nodes in the hash = tree
        my ($index, $elem) = split(/$eq/, $node);
        $tree{$index} = $elem;
        if (($elem =~ m{D[QZ]$colon}) && ($elem =~ m{\/})) {
            $has_ratdiv = $index;
        }
        if ($debug >= 2) {
            print "# add tree{$index}=$elem\n";
        }
    } # foreach $node
    if ($debug >= 1) {
        print "# has_ratdiv=\"$has_ratdiv\"\n";
    }
    return $root;
} # build_tree
#----
sub flatten_node { # expand a node (recursively), and generate code for it
    my ($index) = @_;
    my @list;
    my $result = "";
    my ($oper, $elem, $il);
    if ($index =~ m{\A\{([A-Z]+)\}\Z}) { # reference to another node
        $index = $1;
    }
    my ($code, $node) = split(/$colon/, $tree{$index}, 2);
    my $etype = "Z";
    if ($code =~ m{([A-Z])([A-Za-z])}) {
        ($code, $etype) = ($1, $2);
    }
    if ($debug >= 2) {
        print "# flatten_node tree{$index}=\"$tree{$index}\", code=$code, etype=$etype, node=\"$node\"\n";
    }
    if (0) {

    } elsif ($code eq "A") {
            @list = split(/([\+\-])/, $node);
            for ($il = 0; $il < scalar(@list); $il ++) {
                $elem = $list[$il];
                if ($il == 0) {
                    $result .= ($elem =~ m{\A(\d+)\Z}) ? "ZV($1)" : &flatten_node($elem);
                } elsif ($elem eq "-") { # ignore
                    $oper = $elem;
                } elsif ($elem eq "+") { # ignore
                    $oper = $elem;
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= ".$oper(" . $elem . ")";
                } else {
                    $result .= ".$oper(" . &flatten_node($elem) . ")";
                }
            }

    } elsif ($code eq "C") {
            $result .= "(" . &flatten_node($node) . ")";

    } elsif ($code eq "D") {
            @list = split(/([\/\$])/, $node);
            for ($il = 0; $il < scalar(@list); $il ++) {
                $elem = $list[$il];
                if ($il == 0) {
                    $result .= ($elem =~ m{\A(\d+)\Z}) ? "ZV($1)" : &flatten_node($elem);
                } elsif ($elem eq "/") {
                    $oper = $elem;
                } elsif ($elem eq "\$") {
                    $oper = $elem;
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    if ($oper eq "/") {
                        $result .= ".$oper(" . $elem . ")";
                    } else { # = "$"
                        $result .= "/"       . $elem;
                    }
                } else {
                    $result .= ".$oper(" . &flatten_node($elem) . ")";
                }
            }

    } elsif ($code eq "F") { # ;3=F/D000290({1});
        # FFFF                1               (2-----------23 ,4-----------43  1)
        if (0) {
        #                     1              1 (23-----------34 5-----------54 2 )
        } elsif ($node =~ m{\b([A-Z][A-Z0-9]+)\(((\{[A-J]+\})(\,(|\{[A-J]+\}))*)\)}) {
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
                $result .= "$funame(";
            }
            @list = split(/(\,)/, $reflist);
            $il = 0;
            while ($il < scalar(@list)) {
                $elem = $list[$il];
                if ($il == 0) {
                    $result .= ($elem =~ m{\A(\d+)\Z}) ? "$elem" : &flatten_node($elem);
                } elsif ($elem eq ",") {
                    $oper = ", ";
                } elsif ($elem =~ m{\A\Z}) { # empty - was a lambda arrow
                    $il ++; # skip the 2nd comma
                    $oper = " -> ";
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= "$oper$elem";
                } else {
                    $result .= "$oper" . &flatten_node($elem);
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
            $result .= "<?syntax?>";
        }

    } elsif ($code eq "J") { # ;1=J/J059253(n); parameter is no expression of n
            $result .= $node;

    } elsif ($code eq "L") {
            my ($tref, $lparm) = split(/$colon/, $node); # must be: reference, lambda parmlist
            $result .= $lparm . &flatten_node($tref);

    } elsif ($code eq "M") { # * %
            @list = split(/([\*\%])/, $node);
            for ($il = 0; $il < scalar(@list); $il ++) {
                $elem = $list[$il];
                if ($il == 0) {
                    $result .= ($elem =~ m{\A(\d+)\Z}) ? "ZV($1)" : &flatten_node($elem);
                } elsif ($elem eq "*") {
                    $oper = $elem;
                } elsif ($elem eq "\~") {
                    $oper = "/";
                } elsif ($elem eq "\%") {
                    $oper = "mod";
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= ".$oper(" . $elem . ")";
                } else {
                    $result .= ".$oper(" . &flatten_node($elem) . ")";
                }
            }

    } elsif ($code eq "N") { # ;2=n/k;
            $result .= $node;

    } elsif ($code eq "P") {
            @list = split(/(\^)/, $node);
            for ($il = 0; $il < scalar(@list); $il ++) {
                $elem = $list[$il];
                if ($il == 0) {
                    #                        1               1
                    $result .= ($elem =~ m{\A([i-n0-9\+\-\*]+)\Z}) ? "ZV($1)" : &flatten_node($elem);
                } elsif ($elem eq "^") {
                    $oper = $elem;
                } elsif ($elem =~ m{\A(\d+)\Z}) { # number
                    $result .= ".$oper(" . $elem . ")";
                } else {
                    $result .= ".$oper(" . &flatten_node($elem) . ")";
                }
            }
    }
    if ($debug >= 3) {
        print "# flatten_node result=\"$result\"\n";
    }
    return $result;
} # flatten_node
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
