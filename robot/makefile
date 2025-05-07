#!make

# OEIS-mat/robot - automatic preparation of parameters for the generation of Java programs for jOEIS
# @(#) $Id$
# 2025-05-06: insect & Co.
# 2023-08-20: sumbin & Co.
# 2023-05-01, Georg Fischer: start with ogf
#---------------------------------
GITS=../..
COMMON=$(GITS)/OEIS-mat/common
DATA=$(GITS)/OEIS-mat/data
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
RAMATH=java -cp  $(GITS)/ramath/dist/ramath.jar org.teherba.ramath
CAT=$(COMMON)/jcat25.txt
JPREP=$(RAMATH).sequence.JoeisPreparer
PFRACT=java -cp  $(RAMATH).symbolic.PolyFraction
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
OEISDATA=$(GITS)/oeisdata
HERE=$(GITS)/OEIS-mat/robot
REMOTE=atair
NYI=perl $(COMMON)/nyi.pl -q
D=0
# set_env_var_REMOTE
#-------------
all: # all possible targets:
	grep -P "^\w[^\:]*\:" makefile | sort
#========
napp: # CC=; remove FAILed ones
	touch notapp/$(CC).napp
	cut -f1 notapp/$(CC).napp > napp.tmp
	grep -vf napp.tmp $(CC).gen > $(CC).tmp
	mv $(CC).tmp $(CC).gen
	wc -l    $(CC).gen
#----
# simple formula a(n) = Aqseqno(n...) op Arseqno(n...)
anopan: anopan0 anopan1
	grep -P "\tanopan\t" anopan1.tmp \
	| grep -vE "A068310|A121835|A123538|A130911|A137851|A178467|A185246|A262348|A274996|A277078" \
	>        $@.gen || :
	head -n2 $@.gen
	wc -l    $@.gen
anopan0:
	grep -Pi "\= *A\d+\([^\)]+\) *([\+\-\*\/\^]|and|or|xor|xand|mod) *A\d+\([^\)]+\)" $(CAT) \
	| grep -E "^%[NF]" | cut -b 4- | sort | uniq -w7 | sed -e "s/ /\t/" \
	>        $@.tmp
	wc -l    $@.tmp
	cd $(COMMON) ; make seq2 LIST=$(HERE)/$@.tmp
	$(DBAT) -x "SELECT s.aseqno, 'anopan', i.offset1, REGEXP_SUBSTR(d.data, '[\-0-9]+(\,[\-0-9]+){8}'), s.info \
	  FROM seq2 s, asinfo i, asdata d \
	  WHERE s.aseqno = i.aseqno \
	    AND i.aseqno = d.aseqno \
	    ORDER BY 1" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
anopan1:
	cd $(FISCHER) ; perl anopan.pl ../../../OEIS-mat/robot/anopan0.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	wc -l    $@.tmp $@.rest.tmp
	cut -f2  $@.tmp | sort | uniq -c
#--
nopan: nopan0 nopan1 # a(n) = gcd(n, Annnnnn(n))
	grep -P "\tnopan\t" nopan1.tmp \
	| grep -vE "A068310" \
	>        $@.gen || :
	grep -P "\tnopan\t" nopan1.man >> $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
nopan0:
	grep -Pi "a\(n\) *\= *(min|max|and|xor|or|lcm|gcd|xand)\(n\," $(CAT) \
	| grep -E "^%[NF]" | cut -b 4- | sort | uniq -w7 | sed -e "s/ /\t/" \
	>        $@.tmp
	wc -l    $@.tmp
	cd $(COMMON) ; make seq2 LIST=$(HERE)/$@.tmp
	$(DBAT) -x "SELECT s.aseqno, 'nopan', i.offset1, REGEXP_SUBSTR(d.data, '[\-0-9]+(\,[\-0-9]+){8}'), s.info \
	  FROM seq2 s, asinfo i, asdata d \
	  WHERE s.aseqno = i.aseqno \
	    AND i.aseqno = d.aseqno \
	    ORDER BY 1" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
nopan1:
	perl nopan.pl nopan0.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	wc -l    $@.tmp $@.rest.tmp
	cut -f2  $@.tmp | sort | uniq -c
#----
binomx:
	grep -E "^%" $(CAT) | grep -P "[Bb]inomial transform of [^A]*A" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{transform of [^A]*(A\d+)}) { my $$rn = $$1; '\
	' print join("\t", $$an, binomx, 0, "$$rn", ",0", (($$line =~ m{Inverse binomial}i) ? ", true" : ", false"), $$line);'\
	' } else { print "# $$line"; }}'\
	| tee    $@.gen
	wc -l    $@.gen
#----
cent1:
	grep -P  "Central (terms|coefficients|elements) of " $(COMMON)/joeis_names.txt | grep -E "nyi" | less
central:
	grep -P "Central (terms|coefficients|elements|values) of " $(CAT) | grep -v "€" | grep -P "^%[NF]" \
	| perl rseqnos.pl -cc "central" \
	2>       $@.rest.tmp \
	| tee    $@.gen
	wc -l    $@.*
cent_old:
	grep -P "Central (terms|coefficients|elements|values) of " $(CAT) | grep -v "€" | grep -P "^%[NF]" \
	| perl -ne 'my $$line = $$_; if ($$line =~ m{\A\%. (A\d+)\s*(\S.*)}) {'\
	' my ($$an, $$rest) = ($$1, $$2); if ($$rest =~ m{\b(A\d+)}) {'\
	' my $$rno = $$1; print join("\t", $$an, "$@", 0, "new $$rno()", $$line);'\
	' } else { print STDERR "# $$line"; }}' \
	2>       $@.rest.tmp \
	| tee    $@.gen
	wc -l    $@.*

#----------------
MANY=16
OPT=
#----
# helper targets for chaining

chain1: # process from source chain file to target chain file
	#### chain1 $(PROC) ####
	cp chain.ocn $(PROC).icn
	wc -l    $(PROC).icn
	cat $(PROC).icn | $(PROC) $(OPT) > $(PROC).ocn 2> $(PROC).ecn
	grep -A32 -P "^$(PROC):" makefile | sed -e '1d' | grep -A32 -P "^\w+\:" | tee chain.mf
	head -n$(MANY) $(PROC).ocn
	wc -l    $(PROC).*cn
	cp       $(PROC).ocn chain.ocn
	make -f chain.mf

next: # continue the chain with the next target
	#### next $(PROC) ####
	grep -A32 -P "^$(PROC):" makefile | sed -e '1d' | grep -A32 -P "^\w+\:" | tee chain.mf
	head -n$(MANY) $(PROC).ocn
	wc -l    $(PROC).*cn
	cp       $(PROC).ocn chain.ocn
	make -f chain.mf FISCHER=$(FISCHER)

restart: # get the output of the previous target in the chain
	#### restart $(PROC) ####
	grep -B32 -P "^$(PROC):" makefile | grep -P "^\w+\:" | tail -n2 | head -n1 \
	| tee x.tmp | perl -ne 'my $$target; if (m{\A(\w+)\:}) { $$target = $$1; }; '\
	' print "$$target\:\n\tcp -v $$target.ocn chain.ocn\n\tmake $(PROC)\n";'\
	| tee chain.mf
	make -f chain.mf FISCHER=$(FISCHER)

jump: # continue the chain with target $(FOLLOW)
	#### jump $(PROC) FOLLOW=$(FOLLOW) ####"
	grep -A16 -P "^$(FOLLOW):" makefile | tee chain.mf
	wc -l    $(PROC).*cn
	cp       $(PROC).ocn chain.ocn
	make -f chain.mf FISCHER=$(FISCHER)

#==== the chain of targets ====
GREP=A
chain:	grepan
grepan: # this is the start of the chain
	grep -P "a\(n\) *\=" $(CAT) 2> $@.ecn | grep -P "^%[NF] $(GREP)" | perl -pe 's{€}{A}g;' | endirect | cut -b 4- \
	| grep -P "^A\d{6}" | tee $@.ocn > chain.ocn
	make next PROC=$@
cutauth: # remove trailing author signature
	make -f makefile chain1 OPT= PROC=$@
insertcc: # insert callcode, make seq4 format
	make -f makefile chain1 OPT= PROC=$@
movinits: # extract assignments to initial terms and move them to parm2, or a condition like "n>=2"
	make -f makefile chain1 OPT= PROC=$@
spliteq: # split several assignments to a(n) into separate records
	make -f makefile chain1 OPT= PROC=$@
oeisfunc: # replace known OEIS functions by their A-numbers, and suppress O() and "..."
	make -f makefile chain1 OPT= PROC=$@
funcrest: # count the remaining function occurrences
	cp -v chain.ocn $@.ocn
	cut -f2 oeisfunc.ecn | sort | uniq -c | sort -rn > $@.ecn ; head -n32 $@.ecn
	make next PROC=$@
longwords: # remove those with elaborate wording
	grep -vP "\w{10}|(\w+ ){3}"                             chain.ocn > $@.ocn
	grep -P  "\w{10}|(\w+ ){3}"                             chain.ocn > $@.ecn
	make next PROC=$@
shortend: # remove those with short expressions in n and \d
	grep -vP "^A\d+\t\w+\t\d+\t[n0-9\+\-\*\/\^ \(\)]{1,}\t"   chain.ocn > $@.ocn
	grep  -P "^A\d+\t\w+\t\d+\t[n0-9\+\-\*\/\^ \(\)]{1,}\t"   chain.ocn > $@.ecn
	make next PROC=$@
oeisprep: # egalize OEIS formula conventions
	make -f makefile chain1 OPT=-all PROC=$@
remajx: # remove those with A|X-numbers and J-numbers if not Jxxx(n)
	grep -v -P "[X]\d{6}|[A]\d{6}\(|J\d{6}\(([^n]|n[^\)])"  chain.ocn > $@.ocn
	grep    -P "[X]\d{6}|[A]\d{6}\(|J\d{6}\(([^n]|n[^\)])"  chain.ocn > $@.ecn
	make next PROC=$@
sortuniq: # sort by callcode, parm1, parm2, parm3, and uniq
	sort chain.ocn | uniq | sort -k2,2 -k4,4 -k5,5 -k6,6 -k7,7 > $@.ocn 2> $@.ecn ; make next PROC=$@
enstruct: # append a structure tree to $(PARM1)
	make -f makefile chain1 OPT= PROC=$@
destruct: # flatten the structure tree into jOEIS infix syntax
	make -f makefile chain1 OPT= PROC=$@
lsmtraf: # separate into lambdan, sintrif or multraf callcodes
	make -i -f makefile chain1 OPT= PROC=$@
remove: # remove superfluous records
	grep -P "^A\d+\t" $(FISCHER)/aman/`date +%Y-%m-%d`.ack.man | cut -f1 >  $@.tmp
	grep -P "^A\d+\t" $(FISCHER)/aman/`date +%Y-%m-%d`.nak.man | sed -e "s/\^//" | cut -f1 >> $@.tmp
	grep -P "\tn *\-\> *ZV\(\w?\)\t"    chain.ocn              | cut -f1 >> $@.tmp
	sort $@.tmp | uniq | sed -e "s/^/\^/"                                >  $@.grep.tmp
	grep  -f $@.grep.tmp chain.ocn                                       >  $@.ecn || :
	grep -vf $@.grep.tmp chain.ocn                                       >  $@.ocn || :
	wc -l $@.*
	make next PROC=$@
getinits: # get initial terms
	getinits chain.ocn > $@.ocn 2> $@.err ; make next PROC=$@
lambdian: # patch CC=lambdin -> lambdan with inits in a condition of n
	lambdian chain.ocn > $@.ocn 2> $@.err ; make next PROC=$@
chatest: # compile and run, no break
	cp -v chain.ocn $(FISCHER)/aman/$@.man
	cp -v chain.ocn $@.ocn
	wc -l    $(FISCHER)/aman/$@.man
	cd $(FISCHER) ; make -i CC=chatest pegel
	make next PROC=$@
prune1: # prune and compile again, no break
	cd $(FISCHER) ; make -i CC=chatest prune gener dist               ; cut -f1 $(CC).javer.tmp >> aman/`date +%Y-%m-%d`.nak.man
	cat $(FISCHER)/$(CC).javer.tmp >  $(PROC).ecn
	make next PROC=$@
prune2: # prune and compile again, possibly break
	cd $(FISCHER) ; make CC=chatest prune gener dist test log TO=2 ; cut -f1 $(CC).javer.tmp >> aman/`date +%Y-%m-%d`.nak.man
	cat $(FISCHER)/$(CC).javer.tmp >> $(PROC).ecn
	make next PROC=$@
finish: # this is the end of the chain
	exit
stop1:
	exit
remfailed: # remove those that failed (code 'fx' in previous man files
	grep -vf getfailed.tmp chain.ocn | grep -v "A333387" > $@.ocn || :
	grep  -f getfailed chain.ocn > $@.ecn || :
	wc -l $@*
	make next PROC=$@
#==== end of the chain ====
parisums: parisum1 parisum2 # process (PARI) a(n) = sum(...)
parisum1:
	grep -P "^%o A\d+ +\(PARI\) +a\(n\) *\= *([^\*\+\-]+[\*\+\-]|)(sum|prod)" $(CAT) \
	| perl -pe 's/\(PARI\) *//; s/^\%o //;' \
	| grep -vP "my *\(|local|for *\(|polcoeff|bernfrac" \
	| cutauth  \
	| tee         cutauth.gp.ocn \
	| insertcc \
	| movinits                    | tee movinits.gp.ocn \
	| parifunc 2> parifunc.gp.ecn | tee parifunc.gp.ocn \
	| oeisfunc 2> oeisfunc.gp.ecn | tee oeisfunc.gp.ocn \
	| pariprep 2> pariprep.gp.ecn \
	| oeisprep 2> oeisprep.gp.ecn | tee oeisprep.gp.ocn \
	| cat
	tail -n8      oeisprep.gp.ocn
	wc -l *.gp*
funcrest.gp:
	cut -f2 oeisfunc.gp.ecn | sort | uniq -c | sort -rn > $@.ecn ; head -n32 $@.ecn
parisum2:
	cat           oeisprep.gp.ocn \
	| enstruct 2> enstruct.gp.ecn | tee enstruct.gp.ocn \
	| struct -de 2> destruct.gp.ecn \
	| lsmtraf                     | tee lsmtraf.gp.ocn
	wc -l *gp.*
	head          lsmtraf.gp.ocn
enstest:
	enstruct   -d $(D) enstest.man  2>&1 | tee enstest.ocn
	struct -de  -d $(D) enstest.ocn 2>&1 | tee destest.ocn
#========
ddn2:
	grep -P "\t[BDEFHIKMSTU]\d{6}\([n\+\-\*0-9]+\)\t" chain.ocn \
	| grep -vP "\(n\-\d{2}" \
	> $@.ocn 2> $@.ecn
	wc -l $@*
	make next PROC=$@

getfailed: # determine those that failed (code 'fx' in previous man files
	grep -h -P "^f\S*\tA\d+\t" $(FISCHER)/aman/`date +%Y-%m`*.man \
	| perl -pe 's{\Af\S*\t(A\d+).*}{\^$$1};' | tr -d "\r" | sort | uniq > $@.tmp
	wc -l $@*


FOLLOW=ddn2
branch1: # allow for several different followers
	cp -v chain.ocn $@.ocn
	make jump PROC=$@ FOLLOW=$(FOLLOW)

join1: # continue with the overall chain
	cp -v chain.ocn $@.ocn
	make next PROC=$@

# branch1
xxddn2:
	grep -P "\t[BDEFHIKMSTU]\d{6}\([n\+\-\*0-9]+\)\t" chain.ocn \
	| grep -vP "\(n\-\d{2}" \
	| getinits \
	| tee - \
	> $(FISCHER)/aman/$@.man
	make jump PROC=$@ FOLLOW=join1

ddn:
	grep -P "\t[BDEFHIKMSTU]\d{6}\([BDEFHIKMSTU]\d{6}\(([n\+\-\*0-9]+|term|[BDEFHIKMSTU]\d{6}\(([n\+\-\*0-9]|term)+\))\)\)\t" sortuniq.ocn \
	| getinits \
	| tee $@.tmp
ddn1:
	grep -P "\t[BDEFHIKMSTU]\d{6}\([BDEFHIKMSTU]\d{6}\(([n\+\-\*0-9][n\+\-\*0-9]+|[BDEFHIKMSTU]\d{6}\([n\+\-\*0-9][n\+\-\*0-9]+\))\)\)\t" sortuniq.ocn \
	| getinits \
	| tee $@.tmp
#----
insect: insect1 insect_eval1 insect_eval2 insect_gen # seq0 = intersection of 2 seq1 and seq2
insect1: # grep from jcat25 and preprocess
	grep -iP "(Intersection of| intersect )" $(COMMON)/jcat25.txt \
	| grep -P "^\%[NFCY]" | cut -b 4- | sed -e "s/ /\t/" \
	| perl insect_prep.pl -d 0 \
	| grep -vP "A100715|A185188|A220264|A276142|A281627|A352595" \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
insect_eval1: # determine the set of A-numbers in intersect and union
	cat insect1.tmp \
	| perl -ne 'print join("", map { "$$_\n" } m/new (A\d+)\(/g);' \
	| sort | uniq -c | sort -rn \
	| perl -pe 's/\A\s*(\w+)\s*(\w+).*/$$2\t$$1/;' \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
insect_eval2: # 
	cd ../common ; make seq2 LIST=../robot/insect_eval1.tmp
	$(DBAT) "SELECT s.aseqno, CAST(s.info AS INT), n.name \
	  FROM seq2 s, asname n \
	  WHERE s.aseqno = n.aseqno \
	  ORDER BY 2 DESC, 1" \
	>        $@.tmp
	head -n32 $@.tmp
	wc -l    $@.tmp
insect_gen: # generate for CC=filter
	perl insect_gen.pl insect1.tmp \
	>        insect.txt
	head -n2 insect.txt
	wc -l    insect.txt
#----------------
lingfcj: lingfcj1 lingfcj2 lingfcj3 lingfcj4 # conjectural o.g.f.s
lingfcj1: # extract from CAT
	grep -P "^[\?\%]F A\d+ " $(CAT) \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
lingfcj2: # extract g.f.
	perl lingf.pl lingfcj1.tmp \
	2>       $@.ecn \
	>        $@.ocn
	head -n8 $@.ocn
	wc -l    $@.?cn
lingfcj3: # convert into 2 bigvectors
	endirect lingfcj2.ocn \
	| grep -P "^A" \
	| grep -vP "^A128527" \
	| jprep    -ci lingf -co lingfcj -f - \
	2>       $@.ecn \
	>        $@.ocn
	head -n8 $@.ocn
	wc -l    $@.?cn
lingfcj4:
	cat lingfcj3.ocn \
	| perl -ne 'print if length($$_) < 1024;'\
	> ../../joeis-lite/internal/fischer/aman/lingfcj3.man
#----------------
lsm0: lsm1 lsm2 lsm3 # lambdan/sintraf/multraf
#--
lsm1: # prepare
	grep -P "a\(n\) *\=" $(CAT) | grep -P "^%[NF]" \
	| perl -pe 's{€}{A}g;' | endirect | cut -b 4- | grep -P "^A\d{6}" \
	| cutauth \
	| sed -e "s/ /\tlsm\t0\t/" \
	| perl -pe 's/(\d+)([i-n])/$$1\*$$2/g;' \
	| movinits 2> movinits.tmp \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
lsm2: # spliteq
	cat lsm1.tmp \
	| perl -pe 's{ a\(n\) *\= *}{\tlsm\t0\t};' \
	| spliteq \
	| grep -vP "\.\.\." \
	| grep -vP "..A\d{6}|J\d{6}\([A_Z]\d{6}" \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
#--
lsm3: # enshape
	cat lsmtraf1.tmp \
	| enshape -en \
	| sort -k4,4 \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
#--
lsm4:
	echo
	| spliteq \
	| grep -vP "\.\.\." | grep -vP "A\d{6}" \
	| sort -k2 \
	| perl $(COMMON)/poor.pl -a \
	| tee    $@.tmp
	wc -l    $@.tmp
#--
lsmDD: # lambdan Dnnnnnn(Dmmmmmm(n))
	grep -P "\t[BDEFM]\d{6}\([BDEFM]\d{6}\(n\)\)\t" lsm1.tmp | getinits \
	| sed -e "s/lsm\t0\t/lambdin\t0\tn \-\> /" \
	| tee $@.tmp
	wc -l $@.tmp
lsmDJ: # sintrif Dnnnnnn(Jmmmmmm(n))
	grep -P "\t[BDEFM]\d{6}\([J]\d{6}\(n\)\)\t" lsm1.tmp | getinits \
	| perl -ne 'use strict; s/\s+\Z/\t/; my ($$asn, $$cc, $$ofs, $$p1, $$p2, $$p3) = split(/\t/);'\
	' if ($$p1 =~ s{([A-Z]\d+)\([J](\d+)\(n\)\)}{$$1\(term\)}) {'\
	' $$p3 = "new A$$2\(\)"; $$p1 = "(term, n) -> $$p1"; $$cc = "sintrif"; if (length($$p2) == 0) { $$p2 = "\"\""; } '\
	' print join("\t", $$asn, $$cc, $$ofs, $$p1, $$p2, $$p3) . "\n"; }'\
	| tee $@.tmp
	wc -l $@.tmp
lsmDDD: # lambdan Dkkkkkk(Dnnnnnn(Dmmmmmm(n)))
	grep -P "\t[BDEFM]\d{6}\([BDEFM]\d{6}\([BDEFM]\d{6}\(n\)\)\)\t" lsm1.tmp | getinits \
	| sed -e "s/lsm\t0\t/lambdin\t0\tn \-\> /" \
	| tee $@.tmp
	wc -l $@.tmp
lsmDDJ: # sintrif Dkkkkkk(Dnnnnnn(Jmmmmmm(n)))
	grep -P "\t[BDEFM]\d{6}\([BDEFM]\d{6}\([J]\d{6}\(n\)\)\)\t" lsm1.tmp | getinits \
	| perl -ne 'use strict; s/\s+\Z/\t/; my ($$asn, $$cc, $$ofs, $$p1, $$p2, $$p3) = split(/\t/);'\
	' if ($$p1 =~ s{([A-Z]\d+)\([J](\d+)\(n\)\)}{$$1\(term\)}) {'\
	' $$p3 = "new A$$2\(\)"; $$p1 = "(term, n) -> $$p1"; $$cc = "sintrif"; if (length($$p2) == 0) { $$p2 = "\"\""; } '\
	' print join("\t", $$asn, $$cc, $$ofs, $$p1, $$p2, $$p3) . "\n"; }'\
	| tee $@.tmp
	wc -l $@.tmp
lsmSTU: # sintrif Dkkkkkk(Dnnnnnn(Jmmmmmm(n)))
	grep -P "\t[STU]\d{6}\([BDEFMSTU]\d{6}" lsm1.tmp | getinits \
	| perl -ne 'use strict; s/\s+\Z/\t/; my ($$asn, $$cc, $$ofs, $$p1, $$p2, $$p3) = split(/\t/);'\
	' if ($$p1 =~ s{([A-Z]\d+)\([J](\d+)\(n\)\)}{$$1\(term\)}) {'\
	' $$p3 = "new A$$2\(\)"; $$p1 = "(term, n) -> $$p1"; $$cc = "sintrif"; if (length($$p2) == 0) { $$p2 = "\"\""; } '\
	' print join("\t", $$asn, $$cc, $$ofs, $$p1, $$p2, $$p3) . "\n"; }'\
	| tee $@.tmp
	wc -l $@.tmp
#--
lsmH:
	grep -P "H\d{6}" lsm1.tmp \
	| tee $@.tmp
	wc -l $@.tmp

#----------------
charfun:
	grep -E "^%" $(CAT) | grep -Pi "Characteristic function (for|of) A" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{(for|of) (A\d+)}) { my $$rn = $$2; '\
	' print join("\t", $$an, charfun, 0, "$$rn", "", "", "", "", "", "") . "\n"; } else { print "# $$line"; }}'\
	| tee    $@.gen
	wc -l    $@.gen
#--------
complem: # Complement of Annnnnn
	grep -iP         "Complement of (A\d{6})[\.\:\;\,]" $(CAT) | grep -P "^\%[NFY]" | $(NYI) $@ \
	| perl -ne 'if (m{Complement of (A\d{6})[\.\:\;\,]}) { print join("\t", substr($$_, 0, 7), $@, 0, "new $$1()", "") ."\n"; }'\
	| grep -vE "A103146|A151768|A280930|A347360|A355571|A363998" \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#----
compound0: # prepare for CompoundSequence
	grep -P "^\%[NF] A\d+ +a\(n\) *\=[n0-9\(\)\+\-\^\*\!\/ ]*a[n0-9\(\)\+\-\^\*\!\/ ]*[\.fw\,\;]" $(CAT) \
	| grep -viP "\.\.\.|floor|ceil|mod|sum|a\(2" \
	| tee   $@.tmp
	wc -l   $@.tmp
#--------
convol: # convolution, convolved with or inverse
	grep -iP "convol" $(CAT) | grep -P "^\%[NFCY]" | grep -viP "Dirichlet|Exponential" | $(NYI) convprod \
	| grep -vE "A171238" \
	| perl convol.pl \
	2>       $@.rest.tmp \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.*
#----
diffseq:
	grep -E "^%" $(CAT) | grep -P "(First |Second |Third |)[Dd]ifferences of [^A]*A\d{6}" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{of [^A]*(A\d+)}) { my $$rn = $$1; '\
	' print join("\t", $$an, diffseq, 0, $$rn, $$line); } else { print "# $$line"; }}'\
	| grep -vE "A217866|A217976|A303749|A334087" \
	| tee    $@.gen
	wc -l    $@.gen
diffs:
	perl -ne 'if (m{\A(A\d{6})}) { print "$$1\n"; }' $@.napp  > $@.igno
	grep -P "\A\%[NF]" $(CAT) | grep -P "(A\d{6})\(n *\+ *1\) *\- \1\(n\)" | grep -P "^%" >  $@.tmp
	grep -P "\A\%[NF]" $(CAT) | grep -P "(A\d{6})\(n\) *\- \1\(n *\- *1\)" | grep -P "^%" >> $@.tmp
	cat $@.tmp | $(NYI) diffs \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{(A\d{6})\(n}) { my $$rn = $$1; '\
	' print join("\t", $$an, "diffseq", 0, $$rn, $$line); } else { print "# $$line"; }}'\
	| grep -vf $@.igno \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#--------
dirichcon: # Dirichlet convolution or inverse
	grep -P "Dirichlet convolution of " $(CAT) | grep -P "^\%[NF]" | $(NYI) dirichcon \
	| grep -vE "A159046" \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/);'\
	' $$name =~ s{(A\d+)(\(n\))? with itself}{$$1 with $$1};'\
	' if ($$name =~ m{(A\d+)[^A]+(A\d+)}) { my ($$rn1, $$rn2) = ($$1, $$2);'\
	' print join("\t", $$aseqno, "dirichcon2", $$offset, "new $$rn1()", 1, "new $$rn2()", 1, $$name); }'\
	| grep -vE "A366803" \
	>        $@.gen
	grep -P "Dirichlet inverse of " $(CAT) | grep -P "^\%[NF]" | $(NYI) dirichinv \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/); '\
	' if ($$name =~ m{(A\d+)}) { my $$rn1 = $$1;'\
	' print join("\t", $$aseqno, $$callcode, $$offset, "new $$rn1()", 1, $$name); }'\
	| grep -vE "A359777|A359784|A364953|A366875|A366879|A368694" \
	>>       $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
dirisqrt:
	grep -P "Dirichlet" $(CAT) | grep -P "^\%[NF]" | grep "itself yields" | $(NYI) dirisqrt \
	| grep -vE "A159046" \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/); '\
	' if ($$name =~ m{(Numerator|Denominator)}i) { my $$mode = uc(substr($$1, 0, 3)); '\
	' if ($$name =~ m{itself yields[^A]*(A\d+)}) { my $$rseqno = $$1; '\
	' print join("\t", $$aseqno, "dirisqrt", $$offset, "new $$rseqno()", $$mode, $$name); }} '\
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#--------
dirtraf:
	perl cuteqs.pl $(CAT) \
	2>       $@.restcut.tmp \
	>        $@.cut.tmp
	perl dirtraf.pl $@.cut.tmp \
	2>       $@.rest.tmp \
	| sort | uniq -w7 > $@.gen
	head -n2 $@.gen
	wc -l    $@.*
	make dirtraf_eval
dirtraf_eval:
	sort -k4,4 dirtraf.rest.tmp | cut -f4 | sort | uniq -c | sort -nr > $@.tmp
#----
egfbin: # Seichii's e.g.f.s
	grep -P "^\%o A3\d+ +\(PARI\) *a\(n\) *\= *" $(CAT) | cut -b4- | grep -viP "\{|my|for|vec|pol|subst|ser|mat|\Sa\(|lift|truncate|fromdigits"
#----
expr: expr_pari subst_list expr_trans expr_post expr_gen
expr_pari: # A107995 (PARI) a(n) = sum(k=0, n, (2*n+2)^k*binomial(n+1+k, 2*k+1)); \\ Seiichi Manyama,
	grep -P "^\%o" $(CAT) | cut -b4- \
	| sed -e "s/ /\tlambda\t0\t/" \
	| grep -P "^(A\d{6})\t\w+\t\S+\t *(PARI[^\)]*\))? *\{? *($$1\w*|a)\(n\) *\=" \
	| perl   expr_pari.pl -d $(D) \
	2>       $@.rest.tmp \
	>        $@.txt
	tail -n4 $@.txt $@.rest.tmp
	# grep  -P "binomial|stirling" $@.tmp >> $@.rest.tmp || :
	# grep -vP "binomial|stirling" $@.tmp >  $@.txt || :
	cut -f3  $@.rest.tmp | sort | uniq -c | sort -n | tail -32
	wc -l    $@*
subst_list: # print a sorted list of all values to be substituted
	perl $@.pl expr_pari.txt \
	| sort | uniq -c \
	>        $@.tmp
	# grep -P "Z\." $@.tmp || :
	wc -l    $@.tmp
expr_trans: # translate into jOEIS Z language; expr2.ttab with Functions.*.z
	$(JPREP) -p expr2.ttab -f expr_pari.txt -cc postrans \
	>        $@.1.tmp
	tail -n4 $@.1.tmp
	grep -P  "\<\?" $@.1.tmp > $@.rest.tmp || :
	grep -vP "\<\?" $@.1.tmp > $@.tmp || :
	tail -n4 $@.tmp $@.rest.tmp
	wc -l    $@*.tmp
expr_post: # postprocess: substitute variables in expression
	perl $@.pl -d 1 expr_trans.tmp \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
expr_gen:
	grep -E "^A[0-9]" expr_post.tmp | sort | uniq -w7 \
	>        $@.gen
	tail -n4 $@.gen
	wc -l    $@.gen
#--
expr_mma: # Mathematica; uniq -w takes first row only
	grep -P "^\%t " $(CAT) | cut -b4- | uniq -w7 \
	| grep -iP "^A\d+ +Table\[" \
	| sed -e "s/ /\tlambda\t0\t/" \
	| perl expr_mma.pl -d $(D) \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@*.tmp
	cut -f1  $@.rest.tmp | sort | uniq -c | sort -n | tail -n64
	perl expr_pari.pl $@.tmp \
	2>       expr_pari.rest.tmp \
	>        expr_pari.txt
	wc -l    expr_pari*.t*
	make expr_trans expr_post expr_gen
expr_oeis: # OEIS Formula section: A364940 a(n) = n! * Sum_{k=0..n} (n+1)^(k-1) * binomial(n+2*k-1,n-k)/k!.
	grep -P "^\%[NF]" $(CAT) | cut -b4- \
	| sed -e "s/ /\tlambda\t0\t/" \
	| perl expr_oeis.pl \
	2>       $@.rest.tmp \
	>        $@.tmp
	tail -n4 $@.tmp $@.rest.tmp
	wc -l    $@.tmp
	perl expr_pari.pl $@.tmp \
	2>       expr_pari.rest.tmp \
	>        expr_pari.txt
	tail -n4 expr_pari.txt expr_pari.rest.tmp
	wc -l    expr_pari*.t*
	make expr_trans expr_post expr_gen
#----
filter: # selects only " in ", does not work
	grep -P "([A-Z]\w+ )([^i]\w+ )*in A\d{6}" $(CAT) | grep -P "^\%[NF]" | $(NYI) $@ \
	| perl -ne 'use strict; my $$line = $$_; if ($$line =~ m{\A(A\d+)\t\w+\t\d+\t(.*)}) { my ($$an, $$name) = ($$1, $$2); '\
	' if ($$name =~ m{(A\d+)}) { my $$rn = $$1; '\
	' print        join("\t", $$an, "$@", 0, "new $$rn()", $$name) . "\n"; } else { '\
	' print STDERR join("\t", $$an, "$@", 0, "new A()"   , $$name) . "\n"; }}' \
	2>       $@.rest.tmp \
	| sort -t "	" -k5,5 > $@.gen
	head -n2 $@.gen
	wc -l    $@.gen $@.rest.tmp
#----
filtpos:
	grep -P "(The positions|Positions|Indices|Places) of |such that (\d+ ?\* ?)?(A\d{6})\(\w[^\)]*\)( *[\+\-\] *\d+)? is " $(CAT) | grep -P "^\%[NF]" | $(NYI) $@ \
	| perl filtpos.pl \
	2>       $@.rest.tmp \
	| grep -vE "A256563|A362453|A362454" \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen $@.rest.tmp
	cut -f6  $@.gen      | sort | uniq -c | sort -n | tail -n64
	cut -f6  $@.rest.tmp | sort | uniq -c | sort -n | tail -n64
filtpospri:
	grep -P "such that A\d{6}\(\w\) is prime" $(CAT) | grep -P "^\%" | $(NYI) filtpos \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/);'\
	' if ($$name =~ m{(A\d+)}) { my ($$rn1) = ($$1);'\
	' print join("\t", $$aseqno, "filtpos", $$offset, 1, "new $$rn1()", "PRIME", $$name); }'\
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#----
form_pari: # A107995 (PARI) a(n) = sum(k=0, n, (2*n+2)^k*binomial(n+1+k, 2*k+1)); \\ Seiichi Manyama,
	grep -P "^\%o" $(CAT) | cut -b4- \
	| sed -e "s/ /\tlambda\t0\t/" \
	| grep -P "^(A\d{6})\t\w+\t\S+\t *(PARI[^\)]*\))? *\{? *(\w\d{6}\w*|a)\(n\) *\=" \
	| grep -vP "\bmy\b" \
	| perl   form_pari.pl -d $(D) \
	2>       $@.rest.tmp \
	>        $@.txt
	tail -n4 $@.txt $@.rest.tmp
	wc -l    $@*.t*
#----
gcd: # gcd(A1(n), A2(n)), lcm, min, max
	perl gcd.rob.pl > $@.gen 2> $@.rest.gen
	head -n2 $@.gen
	wc -l    $@.*
#----
gex_oeis: # OEIS Formula section: A364940 a(n) = n! * Sum_{k=0..n} (n+1)^(k-1) * binomial(n+2*k-1,n-k)/k!.
	grep -P "^\%[NF] A\d+ +a\(n\) *\=" $(CAT) | cut -b4- \
	| sed -e "s/ /\tgex_oeis\t0\t/" \
	| uniq \
	| perl gex_oeis.pl -d $(D) \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n8 $@.tmp $@.rest.tmp
	wc -l    $@.tmp $@.rest.tmp
gex_parse: # parse general expressions
	perl gex_parse.pl -d $(D) gex_oeis.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n8 $@.tmp $@.rest.tmp
	wc -l    $@.tmp $@.rest.tmp
gex_code0: # without translation
	perl gex_code.pl -d $(D) -l oeis gex_parse.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n8 $@.tmp $@.rest.tmp
	wc -l    $@.tmp $@.rest.tmp
gex_code: # without translation
	perl gex_code.pl -d $(D) -l java gex_parse.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n8 $@.tmp $@.rest.tmp
	wc -l    $@.tmp $@.rest.tmp
#----
inverse:
	grep -E "^%" $(CAT) | grep -P "Inverse +(permutation +)?(of|to) +A" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{(of|to) (A\d+)}) { my $$rn = $$2; '\
	' print join("\t", $$an, inverse, 0, "new $$rn()", 1, 1, "", $$line); } else { print "# $$line"; }}'\
	| grep -vE "A112846" \
	| tee    $@.gen
rinverse:
	grep -E "^#" $(CAT) | grep -Pi "Inverse (of|is|is in|in) +€" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{Inverse (of|is|is in|in) +€(\d+)}i) { my $$rn = "A$$2"; '\
	' print join("\t", $$rn, inverse, 0, "new $$an()", 1, 1, "", $$line); } else { print "# $$line"; }}'\
	| grep -vE "A112846" \
	| tee -a $@.gen
	wc -l    $@.gen
#----
invtraf:
	grep -Pi "INVERT transform of " $(CAT) | grep -v "€" | grep -P "^%[NFC]" \
	| perl rseqnos.pl -cc "invtraf" \
	2>       $@.rest.tmp \
	| tee    $@.gen
	wc -l    $@.*
#----
# grep A-numbers of known functions
knowna: knowna0 knowna1 knowna2 knowna3 knowna4
knowna0: # grep "a(n) = [factor *] Annnnnn("
	grep -P "^\%[NF] A\d+ +(a\(n\) *\= *)?[\+\-]? *(\(?\d+(\/\d+)?\)? *[\+\-\*]?)? *A\d{6}\(" $(CAT) | $(NYI) $@ \
	| perl knowna0.pl \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
knowna1: # select rseqnos with counts >= 1
	cut -f4  knowna0.tmp | sort | uniq -c | sort -n | grep -vP "^ *[0] " \
	| perl -ne 's{ *(\w+) +(\w+)}{$$2\t$$1}; print;' \
	| tee    $@.tmp
	wc -l    $@.tmp
knowna2: # attach the names of the rseqnos
	cd $(COMMON) ; make seq2 LIST=../robot/knowna1.tmp
	$(DBAT)  "SELECT s.aseqno AS ANumber, 'knowna', CAST(s.info AS INT) AS count, '' AS lambda, n.name AS Definition FROM seq2 s, asname n WHERE s.aseqno = n.aseqno ORDER BY 3 DESC;" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
	$(DBAT)  -x "SELECT '====> total ', CAST(SUM(s.info) AS INT) FROM seq2 s"
	perl $(FISCHER)/htmlize.pl $@.tmp \
	>        $@.html
	# cmd /c $@.html
knowna3: # select "pure" applications
	grep -P "^A\d+\t\w+\t\d+\tA\d{6}\tA\d{6}\(A\d+\(n\)\)(\.|for +n *\>)" knowna0.tmp \
	| sort -k5,5 -t"	" | uniq \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
knowna4: # finally generate
	make known LIST=knowna3.tmp
	cp -v known.gen $@.gen
known4:
	perl known.pl knowna.man \
	>        $@.gen \
	2>       $@.rest.tmp
	wc -l    $@.gen $@.rest.tmp
	sort $@.rest.tmp | uniq -c | sort -n
known: # LIST= generate for SimpleTransformSequence
	perl $@.pl $(LIST) \
	>        $@.gen \
	2>       $@.rest.tmp
	head -n2 $@.gen
	wc -l    $@.*
knowna5: # select applications with expressions in n
#                                      1 (    2     2  )            1                  (                  )  3                     3 4             4
	grep -P "^A\d+\t\w+\t\d+\t[\+\-]? *(\(?\d+(\/\d+)?\)? *[\+\-\*]?)? *A\d{6}\tA\d{6}\([n0-9\+\-\*\/\^]+\) *(\/ *[n0-9\+\-\*\/\^]+)?(\.|for +n *\>)" knowna0.tmp \
	| tee    $@.tmp
knowna7a: # match with direct polynomials
	cut -f4 knowna0.tmp > $@.tmp
	cd $(COMMON) ; make seq LIST=../robot/knowna7.tmp
knowna7:
	$(DBAT) -x "SELECT s.aseqno, 'knowna7', s4.aseqno FROM seq s, seq4 s4 WHERE s.aseqno = s4.aseqno ORDER BY 1;" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
#---
knownf: knownf0 knownf1 knownf2 knownf3 # grep names of known functions
knownf0: # grep "a(n) = [factor *] Annnnnn("
	grep -P "^\%[NF] A\d+ +(a\(n\) *\= *)?[\+\-]? *(\(?\d+(\/\d+)?\)? *[\+\-\*]?)? *[a-zB-Z]\w*\(A\d{6}" $(CAT) | $(NYI) $@ \
	| perl knownf0.pl \
	>        $@.tmp \
	2>       $@.rest.tmp
	head -n2 $@.tmp
	wc -l    $@*.tmp
knownf1: # select rseqnos with counts >= 5
	cut -f4  knowna0.tmp | sort | uniq -c | sort -n | grep -vP "^ *[1-4] " \
	| perl -ne 's{ *(\w+) +(\w+)}{$$2\t$$1}; print;' \
	| tee    $@.tmp
	wc -l    $@.tmp
knownf2: # attach the names of the rseqnos
	cd $(COMMON) ; make seq2 LIST=../robot/knowna1.tmp
	$(DBAT)  "SELECT s.aseqno AS A-Number, 'knowna', CAST(s.info AS INT) AS count, 'Z.' AS lambda, n.name AS Definition FROM seq2 s, asname n WHERE s.aseqno = n.aseqno ORDER BY 3 DESC;" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
	$(DBAT)  -x "SELECT '====> total ', CAST(SUM(s.info) AS INT) FROM seq2 s"
	perl $(FISCHER)/htmlize.pl $@.tmp \
	>        $@.html
	# cmd /c $@.html
knownf3: # select "pure" applications
	grep -P "^A\d+\t\w+\t\d+\tA\d{6}\ta\(n\) *\= *A\d{6}\(A\d+\(n(\-1)?\)\)\." knownf0.tmp \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
#----
tlinrec: # grep LinearRecurrence from %t records
	grep -P "^%t A\d+ LinearRecurrence" $(CAT) \
	| perl $@.pl \
	| tee    $@.gen
	wc -l    $@.gen
tratogf: # grep CoefficientList[Series from %t records
	grep -P "^\%t (A\d+) *CoefficientList *\[ *Series *\[ *([^\]]+)\]" $(CAT) \
	| perl $@.pl \
	2>       $@.rest.tmp \
	| grep -vP "^A375" \
	| tee    $@.gen
	wc -l    $@.gen
#--------
m1pow: # a(n) = (-1)^Annnnnn  or (-1)^n * Annnnnn
	grep -P "\A\%[NF] A\d+ a\(n\) *\= *\(\-\w+\)\^A\d+\(n\)"             $(CAT) | $(NYI) m1pow \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/);'\
	' if ($$name =~ m{(A\d+)}) { my $$rn = $$1;'\
	' print join("\t", $$aseqno, $$callcode, $$offset, $$rn, $$name); }'\
	>        $@.gen
	grep -P "\A\%[NF] A\d+ a\(n\) *\= *\(\-1\)\^n *\* *A\d+\(n\)[ \.\,]" $(CAT) | $(NYI) m1mul \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/); '\
	' if ($$name =~ m{(A\d+)}) { my $$rn = $$1;'\
	' print join("\t", $$aseqno, $$callcode, $$offset, $$rn, $$name); }'\
	>>       $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#----
maindia:
	grep -P "Main diagonal of" $(CAT) | grep -v "€" | grep -P "^%[NFC]" \
	| perl rseqnos.pl -cc "trixdiag" \
	2>       $@.rest.tmp \
	| tee    $@.gen
	wc -l    $@.*
#--------
ANCHOR=anch
morfix:
	grep -iP "(\d+) *\-\> *{ *\d" $(CAT) | grep -P "^\%[NFC]" | $(NYI) $@ \
	| perl $@.pl -d $(D) -a $(ANCHOR) \
	2>       $@.rest.tmp \
	>        $@.gen
	grep morfix $@.man >> $@.gen
	head -n2 $@.gen
	wc -l    $@*
#----
multraf: multraf1 multraf2 multraf3
multraf1:
	grep -P "^%[NF] +A\d+ +a\(n\) *\=" $(CAT) \
	| perl cutuple.pl \
	| grep -vE "€" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
multraf2:
	perl multraf_prep.pl multraf1.tmp \
	| sort -k4 | uniq \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
multraf3:

#--------
nest3:
#                                                                                1              | (               )          1
	grep -P "^\%[NF] A\d+ +a\(n\) *\=" $(CAT) | grep -vP "€" | grep -P "A\d{6}\(([0-9\+\-\* n]+|\([0-9\+\-\* n]+\)[\*\+\- ]*)?A\d{6}\(n" \
	| tee    $@.tmp
	wc -l    $@.tmp
nest3a:
	grep -P "a\(n\) *\= *A\d{6}\(A\d{6}\(n\)\)\." nest3.tmp \
	| perl -ne 'm{(A\d+) *a\(n\) *\= *(A\d{6})\((A\d{6})}; my ($$ano, $$rno, $$qno) = ($$1, $$2, $$3);'\
	' print join("\t", $$ano, "nest3b", 0, $$rno, $$qno) ."\n";'\
	| sort -k4,4 -k5,5 \
	| tee    $@.tmp
	wc -l    $@.tmp
nest3b:
	grep -P "a\(n\) *\= *A\d{6}\(A\d{6}\(n\)\)\." nest3.tmp \
	| perl -ne 'm{(A\d+) *a\(n\) *\= *(A\d{6})\((A\d{6})}; my ($$ano, $$rno, $$qno) = ($$1, $$2, $$3);'\
	' print join("\t", $$ano, "dirtraf", 0, "new $$rno()", "new $$qno()") ."\n";'\
	| sort -k4,4 -k5,5 \
	| tee    $@.tmp
	wc -l    $@.tmp
nest3c:
	cut -f1,4 nest3b.tmp | sort | uniq -w7 \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
	cd ../common ; make seq2 LIST=../robot/nest3c.tmp
	$(DBAT) -x "SELECT s2.aseqno, s4.aseqno FROM seq2 s2, seq4 s4 WHERE s2.info = s4.aseqno ORDER BY 1" \
	| tee    $@.txt
	wc -l    $@.txt
nest3d:
	$(DBAT) -x "SELECT s2.aseqno, s4.aseqno FROM seq2 s2, seq4 s4 WHERE s2.info = s4.aseqno ORDER BY 1" \
	| tee    $@.txt
	wc -l    $@.txt
#--------
# Robot#1: Ordinary (rational) generating functions
ogf: ogf1 ogf2
ogf1: # extract
	grep -E "%[SOFN]" $(CAT) \
	| perl catex_gf.pl -d 0 \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
ogf2: # use JPREP to generate (num, den) tuples for rational o.g.f.s
	$(JPREP) -f ogf1.tmp \
	>        $@.tmp
	grep -E "fract1" $@.tmp | sed -e "s/fract1/lingf/" \
	| perl -ne 'my @f = split(/\t/); print if length($$f[4]) < 2048;' \
	| grep -vE "A097097" \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
	mv -v    $@.gen ogf.gen
	cp -v    ogf.gen ogf.`date +%Y-%m-%d`.gen
fract21:
	grep -E  "fract21" ogf2.tmp \
	| sed -e "s/fract21/trigf/" \
	>        $@.gen
	tail -n2 $@.gen
	wc -l    $@.gen
fract22:
	grep -E  "fract22" ogf2.tmp \
	| sed -e "s/fract22/trigf/" \
	>        $@.gen
	tail -n2 $@.gen
	wc -l    $@.gen
fract2:
	grep -P "^\%[NF]" ../../OEIS-mat/common/jcat25.txt | grep -P "[Gg]\.f\.\:? *[xy\(\)\/\*\^\+\-0-9 ]+\." | grep -vP "\.\.\." \
	| sed -e "s/Expansion of //" -e "s/O\.g/G/" -e "s/\. - .*//" \
	>        $@.gen
	tail -n2 $@.gen
	wc -l    $@.gen
#----
# postfix for PolynomialFieldSequence
polyx: polyx0 polyx1 polyx2 polyx_known polyx_ofter polyx3 polyx4
polyx0: # extract from jcat25
	grep -P "A\(x\)(\^\d+)? *\=" $(CAT) \
	| grep -P "^\%[NF]" \
	| grep -viP "€|\.\.\.|sum|prod|real\Woo\W|[B-Z]\d*\(x" \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
polyx1: # prepare for postfix generator
	cat polyx0.tmp \
	| perl polyx_prep.pl \
	2>       $@.rest.tmp \
	| sort | uniq \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@*.tmp
polyx2: # convert to standard postfix
	jprep -cc post -f polyx1.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@*.tmp
polyx_known: # get the known functions from PolynomialFieldSequence
	grep -P "^\s+case +\"[a-zA-Z0-9]+\"\:" $(LITE)/../joeis/src/irvine/oeis/PolynomialFieldSequence.java \
	| perl -ne 'm{\"([^\"]+)}; print "$$1\n";' | sort \
	| tee    $@.txt
polyx_ofter: # get offsets and a few terms
	cd $(COMMON) ; make seq LIST=../robot/polyx2.tmp
	$(DBAT) -x  "SELECT i.aseqno, i.offset1, SUBSTR(d.data, 1, 16) \
	    FROM  asinfo i, asdata d, seq s \
	    WHERE s.aseqno = i.aseqno \
	      AND i.aseqno = d.aseqno \
	    ORDER BY 1" \
	| tr -d '\r' > $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
polyx3: # postprocess into postfix for PolynomialFieldSequence
	perl polyx_post.pl -k polyx_known.txt -f polyx_ofter.tmp polyx2.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	grep -P "^\# unfct" $@.rest.tmp | sort | uniq -c | sort -nr \
	| tee    $@.unfct.tmp
	head -n8 $@.tmp
	wc -l    polyx*.tmp
polyx4: # split into a number of files with callcodes differing by "polyx.<icc>", compile and run test
	cd $(FISCHER) ;  make purge
	perl callcode_enum.pl polyx3.tmp > $@.tmp
	make polyx_sub ICC=1
	make polyx_sub ICC=2
	make polyx_sub ICC=3
	# make polyx_sub ICC=4
	# make polyx_sub ICC=5
	# make polyx_sub ICC=6
	# make polyx_sub ICC=7
	# make polyx_sub ICC=8
	# make polyx_sub ICC=9
polyx_sub:
	grep -P      "\tpolyx\.$(ICC)\t" polyx4.tmp \
	| perl -pe 's{\tpolyx\.$(ICC)\t}{\tpolyx\t};' \
	>        $(FISCHER)/aman/polyx.$(ICC)a.man
	wc -l    $(FISCHER)/aman/polyx.$(ICC)a.man
	cd $(FISCHER) ;  make CC=polyx.$(ICC)a segel addpass
	ro # read missing b-files
#----
# manually selected, feed them into the polyx chain
polyxm:
	grep -P "^\%[NFC] A" $(FISCHER)/aman/polyx0.man \
	>        polyx0.tmp
	head -n8 polyx0.tmp
	wc -l    polyx0.tmp
	make polyx1 polyx2 polyx_known polyx_ofter polyx3 polyx4
#----
# Extract (e.)g.f.s without "A(x) ="
polegf: polegf0 polegf1 polegf2
polegf0:
	grep -P "^%[NF] A\d+ *Expansion of " $(CAT) \
	| grep -viP "€|\.\.\.|sum|prod|real\Woo|powers of q" \
	| perl -ne 'if ($$_ !~ m{A\(x\) *\=}) { s/Expansion of ((e\.)?g\.f\.) *\:?/Expansion of $$1 A\(x\) \= /; } print; ' \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
polegf1:
	cat polegf0.tmp \
	| grep -P "A\(x\)(\^\d+)? *\=" \
	| grep -viP "€|\.\.\.|sum|prod|real\Woo\W|[B-Z]\d*\(x" \
	>        polyx0.tmp
	head -n8 polyx0.tmp
	wc -l    polyx0.tmp
	# | grep -P "(exp|sin|cos|tan|cot|sqrt|Lamb|lamb|log|sec|arc)"
polegf2: polyx1 polyx2 polyx_known polyx_ofter polyx3 polyx4
#----
# grep PARI equations, and feed them into polyx chain
gpoly: gpoly1 gpoly2 \
	polyx2 polyx_known polyx_ofter polyx3 \
	gpoly4 polyx4
gpoly1:
	grep  -P "^\%o A\d+ +\(PARI\) *\{ *a\(n\) *\= *local *\(A" $(CAT) \
	| grep -vP "(if|sum|binomial|floor|real|imag|norm|binary|concat|Pol|Vec|Ser)\(|\W([jkmBCGFIT])\W" \
	| perl -pe 's/^\%o //; s/ *\(PARI\) * \{ *a\(n\) *\= *local */\t/; s/ //g;' \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
gpoly2:
	cat gpoly1.tmp \
	| perl gpoly_prep.pl \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@*.tmp
	cp -v    $@.tmp polyx1.tmp
gpoly4: # move the polys to $(PARM1)
	cat polyx3.tmp \
	| perl -pe 'my @elems = split(/\t/); $$elems[3] = "\"$$elems[8]\""; print join("\t", @elems);' \
	>        $@.tmp
	cp -v    $@.tmp polyx3.tmp
#----
tritraf: tri1 tri2 tri3 # lambdan/sintraf/multraf
#--
tri1: # prepare
	grep -P "[TA]\([i-n]\, *[i-n]\) *\=" $(CAT) | grep -P "^%[NF]" \
	| perl -pe 's{€}{A}g' | endirect | cut -b 4- | grep -P "^A\d{6}" \
	| cutauth \
	| sed -e "s/ /\ttri\t0\t/" \
	| movinits 2> movinits.tmp \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
tri2: # spliteq
	cat tri1.tmp \
	| perl -pe 's{ a\(n\) *\= *}{\ttri\t0\t};' \
	| spliteq \
	| grep -vP "\.\.\." \
	| grep -vP "..A\d{6}|J\d{6}\([A_Z]\d{6}" \
#--
tri3:
	echo
	| spliteq \
	| grep -vP "\.\.\." | grep -vP "A\d{6}" \
	| sort -k2 \
	| perl $(COMMON)/poor.pl -a \
	| tee    $@.tmp
	wc -l    $@.tmp
#--------
ntraf: # lambdan/sintraf/multraf
	grep -P "^%[NF] A\d{6} *a\(n\) *\= *[\+\-\*\/\^\(\)0-9nABDEFJKMSTU]+[\.\=]" $(CAT) \
	| perl -pe 's{€}{A}g' | endirect | cut -b 5- | grep -vP "A\d{6}\(" | perl -pe 's/^/A/; s/ /\t/;'\
	| sort -k2 \
	| tee $@.1.tmp \
	| perl $(COMMON)/poor.pl -a \
	| tee    $@.tmp
	wc -l    $@.tmp
	perl ntraf.pl $@.tmp \
	2>       $@.rest.tmp \
	| grep -vP "\#|X\d{6}" \
	| grep -vf ntraf.bad.man \
	| tee    $@.gen
	grep -P  "^A\d" $(FISCHER)/aman/2024-06-24.man | cut -b1-7 | sed -e "s/\r//" > $@.grep
	echo "#----" `date +%Y-%m-%d` >> $(FISCHER)/aman/2024-06-22.man
	grep -vf $@.grep $@.gen \
	| grep -vf $@.bad.man \
	| sort >> $(FISCHER)/aman/2024-06-22.man
	wc -l    $@*.tmp $@.gen   $(FISCHER)/aman/2024-06-22.man
#--------
ordtraf: # Ordinal transform of Annnnnn
	grep -iP "Ordinal transform" $(CAT) | grep -P "^\%[NFY]" | $(NYI) $@ \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/); '\
	' if ($$name =~ m{[Oo]rdinal +transform +of[^A]+(A\d{6})}) { my $$rn1 = $$1;'\
	' print        join("\t", $$aseqno, "$@" , 1, "new $$rn1()", "", $$name); } else {'\
	' print STDERR "# $$aseqno $$name"; }' \
	2>       $@.rest.tmp \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen $@.rest.tmp
#----
parity:
	grep -iP "Parity of A\d+" $(CAT) | grep -P "^\%[NFCY]" | $(NYI) parity \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/); '\
	' if ($$name =~ m{(A\d+)}) { my $$rn1 = $$1;'\
	' print join("\t", $$aseqno, $$callcode, $$offset, "new $$rn1()", 1, $$name); }'\
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#----
partprod:
	grep -P "Partial products of " $(CAT) | grep -E "^%" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A\%\w (A\d+) *}{}) { my $$an = $$1; my $$rn = "A00____"; '\
	' if ($$line =~ m{products of (A\d+)}) { $$rn = $$1; '\
	' print        join("\t", $$an, partprod, 0, "new $$rn()", "", "", $$line); } elsif ($$line !~ m{€}) { '\
	' print STDERR join("\t", $$an, partprod, 0, "new $$rn()", "", "", $$line); }}' \
	>        $@.tmp \
	2>       $@.rest.tmp
	grep -vE "A112846" $@.tmp \
	| sort | uniq -w7 \
	| tee    $@.gen
	wc -l    $@.gen $@.rest.tmp
#----
partsum:
	grep -P "Partial sums of " $(CAT) | grep -E "^%" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A\%\w (A\d+) *}{}) { my $$an = $$1; my $$rn = "A00____"; '\
	' if ($$line =~ m{sums of (A\d+)}) { $$rn = $$1; '\
	' print        join("\t", $$an, partsun, 0, "new $$rn()", "", "", $$line); } elsif ($$line !~ m{€}) { '\
	' print STDERR join("\t", $$an, partsun, 0, "new $$rn()", "", "", $$line); }}' \
	>        $@.tmp \
	2>       $@.rest.tmp
	grep -vE "A112846" $@.tmp \
	| sort | uniq -w7 \
	| tee    $@.gen
	wc -l    $@.gen $@.rest.tmp
#----
prepend: # Simple skip/prepending
	grep -iP "^\%[NFC] +(a\(n\) *\= *)?(\{ *\-?\d+(\, *\-?\d+)* *\} *U *)?A\d+ A\d{6}( *[U\\\\] *\{ *\-?\d+(\, *\-?\d+)* *\} *)?[\.\,\;\:\!a-z]" $(CAT) | $(NYI) simtraf \
	| tee    $@.gen
	wc -l    $@.gen
#----
primpos:
	grep -P "Indices of primes " $(CAT) | grep -P "^\%" | $(NYI) filtpos \
	| perl -ne 'use strict; if (s{Indices of primes[^A]+(A\d{6}).*}{1\tnew $$1()\tPRIME}) { print; }' \
	| grep -vE "^A108853" \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#----
reconcat: # extract recurrent concatenations from asdata
	$(DBAT) -x "SELECT d.aseqno, d.termno, d.data, SUBSTR(n.name, 1, 96) FROM asdata d, asname n WHERE d.aseqno = n.aseqno \
	  AND d.aseqno NOT IN (SELECT aseqno FROM joeis) \
	  AND UPPER(n.name) LIKE '%CONCATENAT%';"\
	| perl reconcat.pl \
	| tee    $@.tmp
	wc -l    $@.tmp
#----
recval:
	grep -P                    "\ (Records|Record values|Record high values|Numbers that set new records) (in|of) (A\d{6})" $(CAT) | grep -P "^\%" | $(NYI) $@ \
	| perl -ne 'use strict; if (s{(Records|Record values|Record high values|Numbers that set new records) (in|of) (A\d{6}).*}{new $$3()\t\t}) { print; }' \
	| grep -vE "A117342|A243110|A272268|A354710" \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#----
recpos:
	#                             1            2         2       3                           3    4                                        41    5      5
	grep -P                    "\ (Where record(s| values) occur|([Pp]ositions|Indices|Places) of (records|record values|record high values)) in (A\d{6})" $(CAT) | grep -P "^\%" | $(NYI) $@ \
	| perl -ne 'use strict; if (s{(Where record(s| values) occur|([Pp]ositions|Indices|Places) of (records|record values|record high values)) in (A\d{6}).*}{new $$5()\t, 1\t}) { print; }' \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#----
rowsums:
	grep -E "^%" $(CAT) | grep -P "Row sums of [^A]* A\d{6}" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{of [^A]*(A\d+)}) { my $$rn = $$1; '\
	' print join("\t", $$an, rowsums, 0, $$rn, $$line); } else { print "# $$line"; }}'\
	| grep -vE "A253722|A266330|A287768|A308804|A325546" \
	| tee    $@.gen
	wc -l    $@.gen
#----
seqsum:
	# Sum of sequences with optional factors
	grep   -E "^%[NFC]" $(CAT) \
	| grep -P "^%[NFC] A\d+ (a\(\w\) *\=) *[\+\-]? *\(?\d+(\/\d+)?\)? *(\* *)?A\d+" \
	| perl seqsum.pl > $@.tmp 2> $@.rest.tmp
	wc -l $@*.tmp
	cat $@.tmp \
	| $(NYI) seqsum \
	| grep -vE "A133571|A134233|A134349" \
	| sort | uniq -w7 \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#----
simtraf:
	# Simple transformations
	grep -iP "^\%[NFC] +(a\(n\) *\= *)?([\-\+]? *\d+ *[\+\-\*] *)?A\d+ A\d{6}(\(n([\+\-]\d+)?\))? *([\+\-\*\/\!\^] *\d+| +mod +\d+)[\.\,\;\:\!a-z]" $(CAT) | $(NYI) simtraf \
	| tee    $@.gen
	wc -l    $@.gen
#----
sum_prog: sum_pari sum_list sum_oeis sum_maple sum_mma sum_mma0
sum_pari: # A107995 (PARI) a(n) = sum(k=0, n, (2*n+2)^k*binomial(n+1+k, 2*k+1)); \\ Seiichi Manyama,
	grep -P "^\%o" $(CAT) | cut -b4- \
	| grep -P "a\(n\) *\= *[^s]*sum\(" | grep -iP "binomial|stirling" | grep -viP "numbpart|sqrt|prime" \
	| perl sum_pari.pl -d 1 \
	2>       $@.rest.tmp \
	| sort -k4,4 -k5,5 \
	>        $@.tmp
	head -n2 $@.tmp
	cut -f2  $@.tmp | sort | uniq -c
	grep  -P "binomial" $@.tmp >> $@.rest.tmp
	grep -vP "binomial" $@.tmp >  $@.txt
	wc -l    $@*
sum_list: # get the A-numbers of sumbingp
	cut -f1  sum_pari.txt | sort | uniq -w7 \
	>        $@.tmp
	wc -l    $@.tmp
#--
sum_maple: # Maple
	grep -P "^\%p" $(CAT) | cut -b4- \
	| grep -iP "binomial|stirling" | grep -P "seq\(add\(|sum" \
	| grep -vf sum_list.tmp \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
#-----
tricolrow:
	grep -iP "(Column|Row) [a-n^Sp-z0-9\= ]*of [A-Z]\d{6}" jcat25.txt | grep -P "^%[NFCY]" | endirect | grep -P "of [HSTU]\d+" \
	| tee $@.tmp
	wc -l $@.tmp
#----
triprod:
	# Triangles that are products of 2 other triangles
	grep -E "^%[NF]" $(CAT) |  grep -P "A\d{6}(\^\(\-1\))? *\* *A\d{6}" | $(NYI) triprod \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/);'\
	' $$name =~ s{A000012(\^\(\-1\)| *\(signed)}{A097807}g;'\
	' $$name =~ s{A007318(\^\(\-1\)| *\(signed)}{A130595}g;'\
	' if ($$name =~ m{(A\d+)[^A]+(A\d+)}) { my ($$rn1, $$rn2) = ($$1, $$2);'\
	' print join("\t", $$aseqno, "triprod", $$offset, $$rn1, $$rn2, $$name); }'\
	| grep -vE "A113139" \
	| tee    $@.gen
	wc -l    $@.gen
	# tripro3: # Triangles that are products of 3 other triangles
	grep -E "^%[NF]" $(CAT) |  grep -P "A\d{6}(\^\(\-1\)| *\(signed\))? *\* A\d{6}(\^\(\-1\))? *\* *A\d{6}" | $(NYI) tripro3 \
	| perl -ne 'use strict; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/);'\
	' $$name =~ s{A000012(\^\(\-1\)| *\(signed)}{A097807}g;'\
	' $$name =~ s{A007318(\^\(\-1\)| *\(signed)}{A130595}g;'\
	' if ($$name =~ m{(A\d+)[^A]+(A\d+)[^A]+(A\d+)}) { my ($$rn1, $$rn2, $$rn3) = ($$1, $$2, $$3);'\
	' print join("\t", $$aseqno, "tripro3", $$offset, $$rn1, $$rn2, $$rn3, $$name); }'\
	| tee -a $@.gen
	wc -l    $@.gen
trisum:
	# Triangles that are sums of other triangles
	grep -E "^%[NF]" $(CAT) | grep -P "(\d+ *\* *)?(I|A\d{6}) *[-\+] *(\d+ *\* *)?(I|A\d{6})" | $(NYI) trisum \
	| perl trisum.pl \
	| grep -vE "A133571|A134233|A134349" \
	| tee    $@.gen
	wc -l    $@.gen
#----
tuptraf0:
	grep -P "^%[NF] +A\d+ +a\(n\) *\=" $(CAT) \
	| perl cutuple.pl \
	| grep -vE "€" \
	| sort -k4 \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
tuptrafd:
	grep -P "^%[NF] +A\d+ +a\(n\) *\=" $(CAT) \
	| perl cutuple.pl -d 1 | less
tuptraf:
	cat tuptraf0.tmp \
	| grep -P "^%[NF] +A\d+ +a\(n\) *\=[a-z0-9 \+\-\/\*\(\)\^]*A\d+\(n\) *([\+\-\*\/\^]|mod|and|or|xor) *A\d+\(n\)[a-z0-9 \+\-\/\*\(\)\^]*[\;\,\:\.\=]" \
	| cut -b4- \
	| sed -e "s/ *a(n) *\= */\t/" -e "s/[\;\,\:\.\=].*//" -e "s/ of //g" -e "s/numerator/num/" -e "s/denominator/den/" -e "s/ //g" \
	| sort -k2 \
	| tee $@.tmp
#----
tuptraf9: # tuple transformations
	grep -P "^%[NF] A\d+ *a\(n\) *\= *(\-)?(\d+ *[\*\+\-])? *A\d+\(n\) *([\+\-\*\/\^] *(A\d+\(n\)|n|\d+))+ *[fiw\.\:\,\=\;]" $(CAT) | grep -P "^%[NF]" | grep -vP "€" \
	| tee    $@.man
	wc       $@.man
tt2:
	grep -P "^%[NF] A\d+ *a\(n\) *\= *(\-)?" $(CAT) | cut -b4- \
	| perl tuptraf.pl \
	| tee    $@.gen
	wc       $@.gen
#----
union:
	# Union of 2 or 3 sequences (sorted, without duplicates)
	grep -E "^%[NCFY]" $(CAT) | grep -iP "Union of" | $(NYI) union2 \
	| perl union.pl \
	2>       $@.rest.tmp \
	| grep -vE "A091898|A177457|A274994|A277334|A281265|A331669|A343222|A356301" \
	| tee    $@.gen
	wc -l    $@.*
#----
primof: # Primes of (the )form ...
	grep -Pi "\A%[NF] A\d+ [Pp]rimes of (the )?form " $(CAT) | grep -P "^%[NF]" \
	| perl -pe 's/^\%\w //; s/\W[Pp]rimes of (the )?form /\tlambdan\t0\tk \-\> /;' \
	| sort -k6,6 | endirect | tee $@.tmp
