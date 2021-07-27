#!make

# OEIS-mat/constant: DecimalExpansion, Beatty, ContinuedFraction etc. of real constants
# @(#) $Id$
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
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
NT=32
D=0 # debug mode
HERE=../../OEIS-mat/constant

all:
	echo select specific target 
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
	$(DBAT) -x "SELECT i.aseqno, i.offset1, SUBSTR(d.data, 1, 31), j.superclass, n.name \
	  FROM asinfo i, asdata d, asname n LEFT JOIN joeis j ON j.aseqno = n.aseqno \
	  WHERE i.aseqno = d.aseqno \
	    AND d.aseqno = n.aseqno \
	    AND i.keyword LIKE '%cons%' \
	  ORDER BY 1" \
	| perl -pe 's{\,(\d)}{$$1}g;'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	zip $@.zip $@.tmp
	#    AND i.aseqno NOT IN (SELECT aseqno FROM joeis) \
	#
conjs:
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
#----
decexro0: decexro1 decexro2 # real roots of polynomials 
decexro1: # grep and merge with manuals, extract polynomial (num) and den=1
	grep -Ei  "(solution|root|zero) (of|to)" cons.tmp \
	| grep -viE "Gamma|prime|Moebius" | grep -vE "Pi|Phi|sin\(" \
	| cat - decexro.man \
	| perl decexro.pl -d 0 \
	2>       $@.rest.tmp \
	| grep -vE "A232092" \
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
#----
dechamp:
	grep -E "(ecimal|inary) expansion " $(COMMON)/joeis_names.txt \
	| grep -i concatenat \
	| perl -pe 'substr($$_, 1) =~ m{\W(A\d\d\d\d+)}; my $$rseqno = $$1 || "A000040"; '\
	' s{(\AA\d+)\t\w+\t}{$$1\tparm2\t0\tA033308\tnew $$rseqno\(\)\t\t\t}; '\
	  >      $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	