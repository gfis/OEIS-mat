#!make

# OEIS-mat/constant: DecimalExpansion, Beatty, ContinuedFraction etc. of real constants
# @(#) $Id$
# 2023-05-08: offset -> offset1
# 2021-07-13: moved from ./real
# 2021-07-01, Georg Fischer: copied from ../weidis
#---------------------------------
GITS=../..
COMMON=../common
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar
JPREP=$(RAMATH) org.teherba.ramath.sequence.JoeisPreparer
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
HERE=../../../OEIS-mat/constant
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
NT=32
D=0 # debug mode
WIDTH=4

all:
	echo select specific target 
#-------
overwrite: # SRC= TAR= inserts or replaces all records in TAR by the ones in SRC, key is aseqno
	grep -E "^A[0-9]" $(SRC) | cut -b1-7 > $@.sa.tmp
	grep -vf $@.sa.tmp $(TAR) > $@.tn.tmp || :
	sort $@.tn.tmp $(SRC) > $(TAR)
	wc -l $(TAR)
#===============================================
check:
	$(DBAT) "SELECT COUNT(*) FROM asinfo WHERE keyword LIKE '%cons%'"
	$(DBAT) "SELECT COUNT(*) FROM asinfo WHERE keyword LIKE '%cons%' AND aseqno NOT IN (SELECT aseqno FROM joeis)"
	$(DBAT) "SELECT COUNT(*) FROM asinfo WHERE keyword LIKE '%cofr%'"
	$(DBAT) "SELECT COUNT(*) FROM asinfo WHERE keyword LIKE '%cofr%' AND aseqno NOT IN (SELECT aseqno FROM joeis)"
#--------
equals: equals_grep equals_pack equals_super equals_classify equals_split equals_prepare equals_post
equals_grep:
	grep -P "Equals[^A]+A\d{6}" $(COMMON)/jcat25.txt | grep -P "^%[NF]" \
	| grep -vPi "€|lim|sum|intersect|integral|product|triang|union|matri" \
	| grep -vP  "A\d+\(n" \
	| perl -pe 's/^\%. //; s/ +Equals +/\t/; s/\..*//; s/ //g; s/(\,)?where.*//;' \
	| tee   $@.tmp
	wc -l   $@.tmp
GREP=DecimalExpansionSequence
equals_pack: # GREP= pack all extending $(GREP)
	grep -P "\t$(GREP)\t" $(COMMON)/joeis_names.txt \
	| cut -f1-2 \
	>        $@.tmp
	tail -n2 $@.tmp
	wc -l    $@.tmp
	cp -v    $@.tmp $(FISCHER)/reflect
	cd $(FISCHER)/reflect ; perl queue.pl -p $@.tmp > $@.pack
	cp -v    $(FISCHER)/reflect/$@.pack .
equals_super: # extract lines with "public class" or "super("
	grep -P "^(public class |    super\()" equals_pack.pack \
	| perl equals_super.pl \
	2>       $@.rest.tmp \
	>        $@.tmp
	tail -n2 $@.tmp
	wc -l    $@.*tmp
equals_classify: # mark known A-numbers
	perl classify.pl -m X -f equals_super.tmp equals_grep.tmp \
	>        $@.tmp
	tail -n2 $@.tmp
	wc -l    $@.*tmp
equals_split: # split equations; keep only formulas with "Xnnnnnn"; make seq4 format
	perl split_equations.pl equals_classify.tmp \
	| grep -P "X\d+" | grep -P "\AA\d+[^A]+\Z" \
	| sed -e "s/X001620/gamma/" \
	| grep -vi "inthesense|Coffey|Catalan" \
	| sed -e "s/\t/\tdecexp\t0\t() -> /" \
	>        $@.tmp
	tail -n2 $@.tmp
	wc -l    $@.*tmp
equals_prepare: # extract X-numbers from parm1 into parm2
	perl equals_prepare.pl equals_split.tmp \
	| sort -k4,4 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.*tmp
equals_post: # split equations; keep only formulas with "Xnnnnnn"; make seq4 format
	cp equals_prepare.tmp $@.tmp
	grep -v "€" $@.tmp \
	| $(JPREP) -cc post  -f - | sed -e "s/\r//" \
	>        $@.1.tmp \
	2>       $@.1.rest.tmp
	head -n8 $@.1.tmp
	wc -l    $@.1*.tmp
	$(JPREP) -d 2 -cc infix -p $(FISCHER)/CR.xpat -f $@.1.tmp | sed -e "s/\r//" \
	>        $@.2.tmp \
	2>       $@.2.rest.tmp
	head -n8 $@.2.tmp
	perl $(FISCHER)/cr_polish.pl $@.2.tmp \
	>        $@.3.tmp \
	2>       $@.3.rest.tmp
	head -n8 $@.3.tmp
	wc -l    $@.*
equals9: equals_merge equals_replace equals_polish
equals_merge: # replace the placeholders again
	perl merge.pl -c 4 equals_prepare.man \
	| tee    $@.tmp
	wc -l    $@.*tmp
equals_replace: # replace the X-numbers by their formulas
	perl replace_known.pl -d $(D) -f equals_super.man equals_merge.tmp \
	2> $@.rest.tmp \
	| tee    $@.tmp
	wc -l    $@*
equals_polish: # CC=decexpr when m{REALS}
	cat equals_replace.tmp \
	| perl -pe 'if (m{REALS}) { s/\tdecexp/\tdecexpr/; } s/\_?\w+\=[^\t]+/\t/; ' \
	| grep -vP "new (MyFunction|Unary)" \
	>        equals.gen
	tail -n4 equals.gen
	wc -l    equals.gen
#--------
exact: exact1 exact2 exact3
exact1:
	$(DBAT) -x "SELECT i.aseqno, i.keyword, n.name \
	  FROM  asinfo i, asname n \
	  WHERE i.aseqno = n.aseqno \
	    AND i.keyword LIKE '%cons%' \
	    AND i.aseqno NOT IN (SELECT aseqno FROM joeis) \
	    ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
exact2:
	cut -b1-7 exact1.tmp \
	| perl -ne 'm{\A(A\d+)}; my $$aseqno = $$1; print "../common/ajson/$$aseqno.json\n"; '\
	| xargs -l grep -iHE "Exact value|Equals" \
	>        $@.tmp || :
	head -n4 $@.tmp
	wc -l    $@.tmp
exact3:
	cat exact2.tmp \
	| perl -ne 's/^\.\.\/common\/ajson\///; s/\.json\:\t\t\t\t/\tpost\t0\t/; s/\"Equals //; s/\. \- .*//; s/\.\"\,?\Z//; '\
	' if (! m{sum|prod|lim|integr|..A\d\d\d\d+|lambert|theta|hypergeom|polygamma|\.\.\.}i) { '\
	' print; } else { print STDERR; } '\
	  2>     $@.rest.tmp \
	| sort -k4,4 -k1,1 > $@.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
#================
cons: # all with keyword "cons"
	$(DBAT) -x "SELECT i.aseqno, i.offset1, SUBSTR(d.data, 1, 31), COALESCE(j.superclass, 'null'), n.name \
	  FROM asinfo i, asdata d, asname n LEFT JOIN joeis j ON j.aseqno = n.aseqno \
	  WHERE i.aseqno = d.aseqno \
	    AND d.aseqno = n.aseqno \
	    AND i.keyword LIKE '%cons%' \
	  ORDER BY 1" \
	| perl -ne 's/\s+\Z//; my ($$aseqno, $$offset1, $$terms, $$superclass, $$name) = split(/\t/);'\
	' $$terms =~ s{\,(\d)}{$$1}g;'\
	' print join("\t", $$aseqno, $$offset1, $$terms, $$superclass, $$name) . "\n";'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
conjs:
	grep -P '\tnull\t' cons.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cut -f1,3,5 $@.tmp > $@.txt
	perl $(COMMON)/html_checks.pl -m makefile $@.txt > $@.html
old_conjs: 
	$(DBAT) "SELECT i.aseqno, SUBSTR(d.data, 1, 31) AS terms, n.name \
	  FROM asinfo i, asdata d, asname n LEFT JOIN joeis j ON j.aseqno = n.aseqno \
	  WHERE i.aseqno = d.aseqno \
	    AND d.aseqno = n.aseqno \
	    AND i.keyword LIKE '%cons%' \
	    AND i.aseqno NOT IN (SELECT aseqno FROM joeis) \
	  ORDER BY 1" \
	| perl -pe 's{\,(\d)}{$$1}g;'\
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
	perl $(COMMON)/html_checks.pl -m makefile $@.txt > $@.html
#--------
decfini:
	$(DBAT) -x "SELECT i.aseqno, j.superclass, b.bfimin, b.bfimax, n.name \
	  FROM asinfo i, bfinfo b, asname n LEFT JOIN joeis j ON j.aseqno = n.aseqno \
	  WHERE i.aseqno = n.aseqno \
	    AND n.aseqno = b.aseqno \
	    AND i.keyword LIKE '%cons%' \
	    AND i.keyword LIKE '%fini%' \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#================
cofr0: cofr1 cofr2 cofr3 cofr4 # prepare for ContinuedFraction
cofr1: # grep names
	grep -E "Continued fraction " $(COMMON)/joeis_names.txt \
	| grep -P "\tnull\t" \
	  >      $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
cofr2: # cut expressions
	cat      cofr1.tmp \
	| perl -ne 'if (s{\tContinued fraction (expansion )?of ([^\.]*)}{\t$$2}) { '\
	' s{\tnull\t}{\t$@\t0\t}; print; } else { print STDERR; }'\
	>        $@.tmp \
	2>       $@.rest.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
cofr3: # -> seq4
	cd $(FISCHER) ; make seq4 LIST=../../../OEIS-mat/constant/cofr2.tmp
cofr4: # search for Dec.Exp.Seq. with corresponding expressions
	$(DBAT) -x "SELECT s.aseqno, 'cofr', s.offset1 \
	  , COALESCE((SELECT j.aseqno FROM joeis j, asname n \
	      WHERE j.aseqno = n.aseqno \
	        AND n.name LIKE '% of ' || parm1 || '%'\
	        AND j.superclass = 'DecimalExpansionSequence' \
	      ), 'nyi') \
	  FROM seq4 s ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
	cp -v    $@.tmp  $(COMMON)/cofr4.txt
	cd $(COMMON) ; make -f checks.make -s html_check1 FILE=cofr4
cofr5: # Continued fraction of aseqno
	cat cofr2.tmp \
	| perl -ne 'if (s{cofr2\t(\d+)\t(A[0-9]+)\.?\t.*}{cofr\t$$1\t$$2\t}) { print; }'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#================
deseq0: deseq1 deseq2 deseq3 deseq4 # extract "de[" from sequencedb
deseq1:
	grep -P "\tde\[" ../sequencedb/decex1.tmp \
	| cut -f1,2,3,7,9 \
	| grep -P "\t(01|02)\t" \
	| perl -pe 's{\]}{}g; s{de\[}{}g; s{π}{Pi}g; s{²}{\^2}; s{γ}{gamma}g; s{ϕ}{phi}g'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
deseq2:
	cat deseq1.tmp \
	| perl -pe 's{\A(A\d+)\t(\w+)\t(\-?\d+)\t(\S+)}{$$1\tpost\t$$3\t\~\~$$4\t$$4}; '\
	>        $@.tmp
deseq3: # convert -> postfix 
	$(JPREP) -f deseq2.tmp | sed -e "s/\r//" \
	| perl -pe 's{\A(A\d+)\t(\w+)\t(\-?\d+)\t\~\~\;?}{$$1\tinfix\t$$3\t}; '\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
deseq4: # convert -> postfix 
	$(JPREP) -p $(FISCHER)/CR.xpat -f deseq3.tmp | sed -e "s/\r//" \
	| perl -pe 's{\.pow\(CR\.ONE\.divide\(CR\.TWO\)\)}{\.sqrt\(\)}g; '\
	'          s{\.root\(([^\)]+)\)}{\.pow\($$1\.inverse\(\)\)}g; ' \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp 
#================
root: root_of not_real_root
root_of:
	grep -Ei "(solution|root|zero) (of|to)" cons.tmp \
	| grep -P "\tnull\t" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
not_real_root:
	grep -vEi "real (solution|root)" root_of.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
mersenne_tab0: mersenne_tab1  # evaluate sqrt formulae from A195284
mersenne_tab1:
	grep "Decimal expans" $(COMMON)/joeis_names.txt | grep "Mersenne prime " \
	| perl mersenne_tab.pl -d 0 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
decofs: # search for Dec.Exp.Seq. with high offsets and "fini"
	$(DBAT) -x "SELECT i.aseqno, j.superclass, i.offset1, n.name \
	  FROM asinfo i, asname n LEFT JOIN joeis j ON j.aseqno = n.aseqno \
	  WHERE i.aseqno = n.aseqno \
	    AND i.keyword LIKE '%cons%' AND i.keyword LIKE '%fini%' \
	    AND LENGTH(i.offset1) >= 2 \
	  ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
#--------
philo_tab0: philo_tab1 philo_tab2 philo_tab3 philo_tab4 # evaluate sqrt formulae from A195284
philo_tab1: # generate the formulae inside the Perl program
	perl philo_tab.pl -d 0 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
philo_tab2: # simplify with Maple
	perl $(COMMON)/callmaple.pl -t 2 -n 32 -p $(FISCHER)/simplify.mpat philo_tab1.tmp \
	| perl -pe 's{\A(A\d+)\t(\w+)\t(\-?\d+)\t([\S ]*)(.*)}{$$1\tpost\t$$3\t\~\~$$4\t$$4}; '\
	  >      $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
philo_tab3: # convert -> postfix 
	$(JPREP) -f philo_tab2.tmp | sed -e "s/\r//" \
	| perl -pe 's{\A(A\d+)\t(\w+)\t(\-?\d+)\t\~\~\;?}{$$1\tinfix\t$$3\t}; '\
	  >      $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
philo_tab4: # convert -> postfix 
	$(JPREP) -p $(FISCHER)/CR.xpat -f philo_tab3.tmp | sed -e "s/\r//" \
	| perl -pe 's{\.pow\(CR\.ONE\.divide\(CR\.TWO\)\)}{\.sqrt\(\)}g; '\
	>        $@.tmp \
	2>       $@.rest.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
#========
HTML=-h
correct: # CC= ; generate term list for manual correction
	perl correct.pl $(HTML) -f $(CC)4.txt -l $(FISCHER)/$(CC).fail.log -o $(CC).corr.tmp
	wc -l    $(CC).corr.tmp
#-------
# post_cr came here, now below under decexp
#--
load: # LIST= ; update $(OFFSET1)
	#==== $@ LIST=$(LIST)
	cd $(FISCHER) ; make seq4 LIST=$(HERE)/$(LIST)
	# $(DBAT)  "UPDATE seq4 s SET offset1 = (SELECT COALESCE(i.offset1, -1) FROM asinfo i WHERE i.aseqno = s.aseqno)\
	#    , parm3 = (SELECT COALESCE(SUBSTR(d.data, 1, 17), '0,0,0,0')      FROM asdata d WHERE d.aseqno = s.aseqno)";
#--
interval: # LIST= WIDTH= ; unload and set low, high into $(PARM3), $(PARm4)
	#==== $@ LIST=$(LIST)
	$(DBAT) -x -44444 seq4 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	perl signify.pl -d 0 $@.tmp \
	| perl interval.pl -w $(WIDTH) \
	>        $(LIST)
	wc -l    $(LIST)
#========
floor: floor0 floor1 floor2 floor3
	cp floor3.tmp floor.gen
floor0: # generate from guides
	perl solvetab.pl -a ABC \
	| cut -f1-4 \
	| perl -ne 's{\t~~(.*)\Z}{\tfloor\($$1\)}g; print; '\
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
floor1: # simplify with Maple
	cat floor0.tmp \
	| perl $(COMMON)/callmaple.pl -t 2 -n 64 -p $(FISCHER)/simplify.mpat \
	| perl -ne 's/\s+\Z//; my ($$aseqno, $$callcode, $$ofs, $$expr) = split(/\t/); '\
	' $$expr =~ s{\(\-}{\(0\-}g; $$expr =~ s{\A\-}{0\-}; '\
	' print join("\t", $$aseqno, $$callcode, $$ofs, "~~;$$expr", "", $$expr) . "\n"; ' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
floor2: # convert $(PARM1) -> postfix -> CR
	cp -v floor1.tmp $@.tmp
	make post_cr LIST=$@.tmp
floor3: # weird patches for leading "CR.mN" and "null."
	cat floor2.tmp \
	| perl -ne 's{(\.floor\(\)\.)(add|subtract)\(CR\.(\w+)\)\t}{$$1$$2\(Z\.$$3\)\t}; '\
	' print; '\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
floorn: floorn0 floorn1 floorn2 floorn3
floorn0:
	grep -Pi "^A\d+\tnull\t([abc]\(n\) *\=)?[0-9n\+\-\*\^ ]*(floor|ceil|round|frac|[\[\]])" $(COMMON)/joeis_names.txt \
	| cut -f1-3 \
	| grep -vPhi "mod|sum|\.\.|prod|binom|acci|lucas|digit|reverse|radius|Rounded|fractionalpart|Fractalization|elevator|concat|prime|power|number|integer|\-\>|\!|A[0-9]+\(|pi\(|\[x\^" \
	| perl -ne 's{\t[abc]\(n\) *\= *(.*)}{\t$$1}; s{\.\Z}{}; s{ and }{\,}g; s{[\,\;]? *where}{\,}; s{ }{}g; print; ' \
	| perl floorn_polish.pl \
	2>       $@.rest.tmp \
	| sort \
	>        $@.tmp
	perl -ne 'if (s{\t\t}{\tfloor\t0\t}) { print; }' floorn.man > $@.1.tmp
	make overwrite SRC=$@.1.tmp TAR=$@.tmp
	head -n4 $@.tmp
	wc -l    $@.*tmp
floorn1: # simplify with Maple
	cat floorn0.tmp \
	| perl expr_split.pl \
	| perl -ne 's/\s+\Z//; my ($$aseqno, $$callcode, $$ofs, $$expr) = split(/\t/); '\
	' print join("\t", $$aseqno, $$callcode, $$ofs, "~~;$$expr", "", $$expr) . "\n"; ' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
	# | perl $(COMMON)/callmaple.pl -t 2 -n 64 -p $(FISCHER)/simplify.mpat 
floorn2: # convert $(PARM1) -> postfix -> CR
	cp -v floorn1.tmp $@.tmp
	make post_cr LIST=$@.tmp
floorn3: # weird patches for leading "CR.mN" and "null."
	sort floorn2.tmp \
	| perl expr_join.pl \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cp -v    $@.tmp floorn.gen
#---------------------------------
floorD: floorD1 floorD2 floorD3
MODE=new
floorD1:
	grep -E "\[\{|floor|ceil|round|frac" $(COMMON)/joeis_names.txt 
	| grep -P "\tnull\t" \
	| perl ck_guide_D.pl -a D -m $(MODE) \
	2>       $@.rest.tmp \
	| perl -ne 's{\(n}{\(n\+1} if m{^A184116}; s{\t1\t}{\t0\t} if m{^A166477}; print; ' \
	| sort \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.*tmp
	cp -v    $@.tmp floor0.tmp
floorD2:
	make floor1 floor2 floor3
floorD3:
	perl expr_join.pl floor3.tmp \
	| perl -ne 's{\tCR\.valueOf\(mN}{\tZ\.valueOf\(mN}; print; '\
	>        floorD.gen
	head -n4 floorD.gen
	wc -l    floorD.gen
#========
decsolv: decsolv0 decsolv1 decsolv2 decsolv3 decsolv4 # solve()
	cp -v decsolv3.tmp $@.gen
	head -n4 $@.gen
	cut -f2  $@.gen | sort | uniq -c
decsolv0:
	grep -P "Decimal expansion of " $(COMMON)/joeis_names.txt \
	| grep -P "\AA\d+\tnull\t" \
	| grep -vP "continued fraction|Khinchin|Glaisher|Fibonacci|prime|Riemann|Dedekind" \
	| perl decsolv.pl \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
decsolv1:
	cp -v decsolv0.tmp $@.tmp
	make overwrite SRC=decsolv.man TAR=$@.tmp
	grep -E "\A[0-9]" $@.tmp \
	| sort | uniq -w7 \
	| gawk -e '{print $$1 "\t" $$2 "\t" $$3 "\t" $$4 "\t\t0\t0\t" substr($$4, 3) }' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
decsolv2:
	cp -v decsolv1.tmp $@.tmp
	make post_cr    LIST=$@.tmp
decsolv3:
	make load       LIST=decsolv2.tmp
	$(DBAT) "DELETE FROM seq4 WHERE aseqno IN (SELECT aseqno FROM joeis);"
	$(DBAT) -f decsolv3.sql
	make interval   LIST=$@.tmp
decsolv4: # Check with Maple's fsolve
	perl -e 'print join("\t", qw(aseqno cc ofs Maple OEIS low high formula)), "\n";' > $@.txt
	perl -pe 's{agm\(}{GaussAGM\(}g; s{(\W|\A)e(\W|\Z)}{$$1exp\(1\)$$2}g; s{Gamma\(}{GAMMA\(}ig;' \
	  decsolv3.tmp      > $@.tmp
	perl $(COMMON)/callmaple.pl -t 8 -n 64 -p fsolve.mpat $@.tmp \
	| grep -E "^A[0-9]" \
	>>       $@.txt || :
	wc -l    $@.txt
	perl $(COMMON)/html_checks.pl -m makefile $@.txt > $@.html
#--------
TAB=0-9a-z
solvetab: solvetab1 solvetab2 solvetab3 solvetab4 # generate for CK's tables in 
	# A197133(1), A197476(2), A336043(3), A198414(4), A198866(5)
	mv -v solvetab3.tmp $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
solvetab1: # creates solve() parameters from Perl <DATA>, and writes $@.sql.tmp
	perl solvetab.pl -a $(TAB) \
	2>       $@.1.tmp \
	| sort | uniq -w7 \
	| perl -pe 's{(\D)1\*}{$$1}g;' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
	grep -E "^  " $@.1.tmp > $@.sql.tmp
solvetab2: # convert to CR infix
	cp -v solvetab1.tmp $@.tmp
	make post_cr    LIST=$@.tmp
EX=
solvetab3: # load into seq4, and expand intervals
	make load       LIST=solvetab2.tmp
	$(DBAT) "DELETE FROM seq4 WHERE '$(EX)' || aseqno IN (SELECT aseqno FROM joeis);"
	$(DBAT) -f solvetab3.sql
	$(DBAT) -f solvetab1.sql.tmp
	$(DBAT) -n seq4
	make interval   LIST=$@.tmp
solvetab4: # check with Maple's fsolve
	#---- $@ 
	perl -e 'print join("\t", qw(aseqno cc ofs Maple OEIS low high formula)), "\n";' > $@.txt
	perl -pe 's{agm\(}{GaussAGM\(}g;' \
	  solvetab3.tmp  > $@.tmp
	perl $(COMMON)/callmaple.pl -t 8 -n 64 -p fsolve.mpat $@.tmp \
	| grep -E "^A[0-9]" \
	>>       $@.txt || :
	wc -l    $@.txt
	gawk -e '{ print $$1 "\t" $$2 "\t" $$3 "\t" substr($$4, 0, 20) "\t" $$5 "\t" $$6 "\t" $$7 "\t" $$8 }' $@.txt \
	>        $@.1.tmp 
	perl $(COMMON)/html_checks.pl -m makefile $@.1.tmp > $@.html
	grep -E fsolve $@.txt || :
#----
solvepari: # intervals from GP/PARI solve() 
	grep -E "^\%o" $(COMMON)/jcat25.txt | grep -E " solve\(" \
	  >      $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
post_cr: # LIST=; convert $(PARM1) -> postfix -> CR
	#==== $@ LIST=$(LIST)
	grep -v "€" $(LIST) \
	| $(JPREP) -cc post  -f - | sed -e "s/\r//" \
	| perl -pe 's{\~\~\;?}{}g; '\
	>        $@.1.tmp \
	2>       $@.1.rest.tmp
	wc -l    $@.1*.tmp
	$(JPREP) -d 2 -cc infix -p $(FISCHER)/CR.xpat -f $@.1.tmp | sed -e "s/\r//" \
	>        $@.2.tmp \
	2>       $@.2.rest.tmp
	perl $(FISCHER)/cr_polish.pl $@.2.tmp \
	>        $(LIST) \
	2>       $@.3.rest.tmp
	wc -l    $@*.tmp $(LIST)
#----------------
decexp: decexp1 decexp2 decexp3 decexp4 # Decimal expansion of expr.
	cp -v decexp4.tmp $@.gen
	head -n4 $@.gen
	cut -f2  $@.gen | sort | uniq -c
decexp1:
	grep -P "^\%[NFC] A\d+\s+Decimal expansion" $(COMMON)/jcat25.txt \
	| cut -b4- | grep -vP '\, *where' \
	| perl -ne 's/ Decimal expansion (for|of) /\tdecexp\t0\t~~/; '\
	' s{([\.\;\,\:\=]|\(gamma is|where ).*}{}; s{ }{}g; s{(.)A001620}{$$1}g; s{goldenratio}{phi}; '\
	' if (! m{sum|prod|_|.A|\!|.\w{8}}) { print; }'\
	| grep -E "^A[0-9]" \
	>        $@.1.tmp
	wc -l    $@.1.tmp
	grep -E "^A[0-9]" decexp1.man \
	| sed -e "s/ //g" \
	| sort | uniq -w7 \
	>        $@.2.tmp
	wc -l    $@.2.tmp
	make overwrite SRC=$@.2.tmp TAR=$@.1.tmp
	gawk -e '{print $$1 "\tdecexp\t" $$3 "\t" $$4 "\t" $$4 }' $@.1.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
decexp_check: # on duplicates in .man
	grep -E "^A[0-9]" decexp1.man | cut -b1-7 | sort | uniq -c | grep -v " 1 "
decexp2:
	# cp -v zetaddx.man decexp1.tmp
	cp -v    decexp1.tmp $@.tmp
	make post_cr    LIST=$@.tmp
decexp3:
	make load       LIST=decexp2.tmp
	# $(DBAT) "UPDATE seq4 SET callcode='decexp';"
	$(DBAT) -x -44444 seq4 \
	>        $@.tmp
decexp4:
	cat decexp3.tmp \
	| perl -ne 'my ($$aseqno, $$callcode, $$offset1, $$parm1, @rest) = split(/\t/); '\
	' if ((length($$offset1) <= 4) && ($$parm1 =~ m{\A[A-Z]})) { print; } '\
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
decexro0: decexro1 decexro2 # real roots of polynomials 
decexro1: # grep and merge with manuals, extract polynomial (num) and den=1
	grep -Ei  "(solution|root|zero) (of|to)" conjs.tmp \
	| grep -viE "Gamma|prime|Moebius" | grep -vE "Pi|Phi|sin\(" \
	| cat - decexro.man \
	| grep -vE "A102912" \
	| perl decexro.pl -w 1 \
	2>       $@.rest.tmp \
	>        $@.tmp 
	head -n4 $@.tmp
	wc -l    $@*.tmp
decexro2: # convert to vector
	$(JPREP) -f decexro1.tmp \
	| grep -E "fract1" \
	| sed -e "s/fract1/decexro/" \
	| sort | uniq -w7 \
	| cut -f1-4,7-9 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
dechamp:
	grep -E "(ecimal|inary) expansion " $(COMMON)/joeis_names.txt \
	| grep -i concatenat \
	| perl -pe 'substr($$_, 1) =~ m{\W(A\d\d\d\d+)}; my $$rseqno = $$1 || "A000040"; '\
	' s{(\AA\d+)\t\w+\t}{$$1\tparm2\t0\tA033308\tnew $$rseqno\(\)\t\t\t}; '\
	  >      $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
decneg_check: # check for negative constants
	$(DBAT) -x "SELECT i.aseqno, j.superclass, i.offset1, d.data, n.name \
	  FROM asinfo i, asdata d, asname n LEFT JOIN joeis j ON j.aseqno = n.aseqno \
	  WHERE i.aseqno = d.aseqno \
	    AND d.aseqno = n.aseqno \
	    AND i.keyword LIKE '%cons%' \
	    AND SUBSTR(d.data, 1, 1) = '-' \
	  ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
#----
grep_example1: # extract filenames from cons
	perl -pe 's{^([A0-9]+).*}{\.\.\/common\/ajson\/$$1\.json}' cons.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
grep_example2: # grep through all in cons - much faster on Linux
	rm -f $@.tmp
	head -n88888 grep_example1.tmp | xargs -l -innn grep -A1 -HE "\"data|\"example|\"offset" nnn >> $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
exalist: # generate a list with data, example in seq4 format
	perl exalist.pl grep_example2.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
exacheck: # check the exalist, and generate HTML worksheet
	perl exacheck.pl exalist.tmp \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
	perl $(COMMON)/html_checks.pl -m makefile $@.txt > $@.html
#-----
alcover:
	grep -E "^\%t" $(COMMON)/jcat25.txt | grep -E "RealDigits" | grep Alcover \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#-----
solvpari:
	grep -E "^\%o" $(COMMON)/jcat25.txt | grep -E "solve\(" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
base60:
	grep -Ei "base[ \-]60|Babylonian|sexagesimal" $(COMMON)/joeis_names.txt
#----
bindec_check: # apply BinaryToDecimalExpansionSequence
	echo aseqno name > $@.txt
	grep -Ei "binary" conjs.txt \
	>>       $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
	perl $(COMMON)/html_checks.pl -m makefile $@.txt > $@.html
#================
# ck_guides

