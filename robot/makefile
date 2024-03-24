#!make

# OEIS-mat/robot - automatic preparation of parameters for the generation of Java programs for jOEIS
# @(#) $Id$
# 2023-08-20: sumbin & co.
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
	' print join("\t", $$an, binomx, 0, "$$rn", ",0", (($$line =~ m{Inverse binomial}i) ? ", true" : ", false"), $$line); } else { print "# $$line"; }}'\
	| tee    $@.gen
	wc -l    $@.gen
#----
charfun:
	grep -E "^%" $(CAT) | grep -P "Characteristic function (for|of) A" \
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
	grep -E "^%" $(CAT) | grep -P "(First |Second |Third |)[Dd]ifferences of [^A]* A\d{6}" \
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
expr_trans: # translate into jOEIS Z language
	$(JPREP) -p expr.ttab -f expr_pari.txt -cc postrans \
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
tuptraf: # tuple transformations
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