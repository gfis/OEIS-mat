#!make

# OEIS-mat/word: sequences with keyword "word"
# @(#) $Id$
# 2021-08-08, Georg Fischer: copied from ../cosntant; FF=114
#---------------------------------
GITS=../..
COMMON=../common
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar
JPREP=$(RAMATH) org.teherba.ramath.sequence.JoeisPreparer
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
HERE=../../../OEIS-mat/word
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
#================
word: # all with keyword "word"
	$(DBAT) -x "SELECT i.aseqno, COALESCE(j.superclass, 'null'), i.offset1, n.name \
	  FROM asinfo i, asname n LEFT JOIN joeis j ON j.aseqno = n.aseqno \
	  WHERE i.aseqno = n.aseqno \
	    AND i.keyword LIKE '%word%' \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--
njword: # keyword "word" and not in jOEIS
	grep -P '\tnull\t' word.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cut -f1-4 $@.tmp > $@.txt
	perl $(COMMON)/html_checks.pl -m makefile $@.txt > $@.html
#--
aronson: # Aronson word sequences
	grep -P 'Aronson' word.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cut -f1-4 $@.tmp > $@.txt
	perl $(COMMON)/html_checks.pl -m makefile $@.txt > $@.html
#--------
A247750: # n has digits with increasing names in some language
	grep -E "^.C A247[78]" $(COMMON)/jcat25.txt \
	| perl -ne 'my $$line = $$_; $$line =~ m{\A.C (A\d+)}; my $$aseqno = $$1; '\
	' if (($$line =~ m{ _ }) and $$aseqno ge "A247750" and $$aseqno le "A247814") { '\
	' my @digs = map { s{ _ }{}; $$_ } ($$line =~ m{(\d _ )}g); '\
	' print join("\t", $$aseqno, "parm3", 0, "A247750", ($$aseqno lt "A247800" ? "0" : "1"), "\"" . join("", @digs)) . "\"\n"; } '\
	| tee    $@.gen
	wc -l    $@.gen
#===============================================
check:
	$(DBAT) "SELECT COUNT(*) FROM asinfo WHERE keyword LIKE '%cons%'"
	$(DBAT) "SELECT COUNT(*) FROM asinfo WHERE keyword LIKE '%cons%' AND aseqno NOT IN (SELECT aseqno FROM joeis)"
	$(DBAT) "SELECT COUNT(*) FROM asinfo WHERE keyword LIKE '%cofr%'"
	$(DBAT) "SELECT COUNT(*) FROM asinfo WHERE keyword LIKE '%cofr%' AND aseqno NOT IN (SELECT aseqno FROM joeis)"
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
cons:
	$(DBAT) -x "SELECT i.aseqno, i.offset1, SUBSTR(d.data, 1, 31), COALESCE(j.superclass, 'null'), n.name \
	  FROM asinfo i, asdata d, asname n LEFT JOIN joeis j ON j.aseqno = n.aseqno \
	  WHERE i.aseqno = d.aseqno \
	    AND d.aseqno = n.aseqno \
	    AND i.keyword LIKE '%cons%' \
	  ORDER BY 1" \
	| perl -ne 's/\s+\Z//; my ($$aseqno, $$offset, $$terms, $$superclass, $$name) = split(/\t/);'\
	' $$terms =~ s{\,(\d)}{$$1}g;'\
	' print join("\t", $$aseqno, $$offset, $$terms, $$superclass, $$name) . "\n";'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	zip $@.zip $@.tmp
	#    AND i.aseqno NOT IN (SELECT aseqno FROM joeis) \
	#
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
	$(DBAT) -x "SELECT s.aseqno, 'cofr', s.offset \
	  , COALESCE((SELECT j.aseqno FROM joeis j, asname n \
	      WHERE j.aseqno = n.aseqno \
	        AND n.name LIKE '% of ' || parm1 || '%'\
	        AND j.superclass = 'DecimalExpansionSequence' \
	      ), 'nyi') \
	  FROM seq4 s ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
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
correct: # CC= ; generate term list for manual correction
	perl correct.pl -f $(CC)4.txt -l $(FISCHER)/$(CC).fail.log -o $(CC).corr.tmp
	wc -l    $(CC).corr.tmp
#-------
post_cr: # LIST=; convert $(PARM1) -> postfix -> CR
	#==== $@ LIST=$(LIST)
	$(JPREP) -cc post  -f $(LIST) \
	| sed -e "s/\r//" \
	| perl -pe 's{\~\~\;?}{}g; '\
	>        $@.tmp
	wc -l    $@.tmp
	$(JPREP) -cc infix -p $(FISCHER)/CR.xpat -f $@.tmp \
	| sed -e "s/\r//" \
	| perl $(FISCHER)/cr_polish.pl \
	>        $(LIST)
	wc -l    $(LIST)
#--
load: # LIST= ; update $(OFFSET)
	#==== $@ LIST=$(LIST)
	cd $(FISCHER) ; make seq4 LIST=$(HERE)/$(LIST)
	$(DBAT)  "UPDATE seq4 s SET offset = (SELECT i.offset1 FROM asinfo i WHERE i.aseqno = s.aseqno)\
	    , parm3 = (SELECT SUBSTR(d.data, 1, 17)            FROM asdata d WHERE d.aseqno = s.aseqno)";
#--
interval: # LIST= WIDTH= ; unload and set low, high into $(PARM3), $(PARm4)
	#==== $@ LIST=$(LIST)
	$(DBAT) -x -44444 seq4 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	perl interval.pl -w $(WIDTH) $@.tmp \
	>        $(LIST)
	wc -l    $(LIST)
#========
decexp: decexp1 decexp2 decexp3 decexp4 # Decimal expansion of expr.
	cp -v decexp4.tmp $@.gen
	head -n4 $@.gen
	cut -f2  $@.gen | sort | uniq -c
decexp1:
	grep -E "^[\%][N] A[0-9][0-9]* Decimal expansion" $(COMMON)/jcat25.txt \
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
	gawk -e '{print $$1 "\t" $$2 "\t" $$3 "\t" $$4 "\t" $$4 }' $@.1.tmp \
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
	make interval   LIST=$@.tmp
decexp4:
	cat decexp3.tmp \
	| perl -ne 'my ($$aseqno, $$callcode, $$offset, $$parm1, @rest) = split(/\t/); '\
	' if ((length($$offset) <= 4) && ($$parm1 =~ m{\A[A-Z]})) { print; } '\
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
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
	make interval   LIST=$@.tmp
decsolv4: # Check with Maple's fsolve
	perl -e 'print join("\t", qw(aseqno cc ofs Maple OEIS low high formula)), "\n";' > $@.txt
	perl -pe 's{agm\(}{GaussAGM\(}g; s{(\W|\A)e(\W|\Z)}{$$1exp\(1\)$$2}g; s{Gamma\(}{GAMMA\(}ig;' \
	  decsolv3.tmp      > $@.tmp
	perl $(COMMON)/callmaple.pl -t 8 -n 64 -p fsolve.mpat $@.tmp \
	| grep -E "^A[0-9]" \
	>>       $@.txt
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
	2>       $@.sql.tmp \
	| sort | uniq -w7 \
	| perl -pe 's{(\D)1\*}{$$1}g;' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
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
	>>       $@.txt
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

