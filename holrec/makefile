#!make

# OEIS-mat/holrec - holonomic recurrences
# @(#) $Id$
# 2020-03-13: HOLT, seq3
# 2019-12-09, Georg Fischer: copied from ../linrec
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMJAR=$(GITS)/ramath/dist/ramath.jar 
RAMATH=java -cp  $(RAMJAR) org.teherba.ramath
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
MAXT=32
HOLT=$(RAMJAR) irvine.test.HolonomicRecurrenceTest
COMMON=../common
D=0
AINIT=0
RTLEN=256
SERVER=gfis@atair
REMDIR=~/work/gits/OEIS-mat/holrec
REMOTE=$(SERVER):$(REMDIR)

all:
	echo select specific target 
# rectab recuf
GENSEQ=('CoxeterSequence', 'GeneratingFunctionSequence', 'HolonomicRecurrence', 'LinearRecurrence')
#===============================================
runholo:
	$(HOLT) -n $(MAXT) -p "$(MATRIX)" -i "$(INIT)" -o $(OFFSET) -d $(D) -dist $(DIST)
#----------------
seq: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/seq.create.sql
	cut -b1-7 $(LIST) | grep -E "^A" | $(DBAT) -m csv -r seq
	$(DBAT) -n seq
delseq: seq # parameters: $(TAB) $(LIST)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
seq3: # parameter: $(LIST)
	$(DBAT) -f $@.create.sql
	cut -f1-3 $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
seq4: # parameter: $(LIST) with aseqno, offset, parm1, parm2, parm3, parm4, name
	$(DBAT) -f $(FISCHER)/seq4.create.sql
	cat $(LIST) | grep -E "^A" | sort | uniq > seq4.tmp
	$(DBAT) -m csv -r seq4 < seq4.tmp
	$(DBAT) -4 seq4
	$(DBAT) -n seq4
#----
holtabs:
	$(DBAT) -f holrec.create.sql
	$(DBAT) -f holatt.create.sql
#----
holjoeis: holjoeis1
	$(DBAT) -x "SELECT j.aseqno, j.superclass, a.offset1, a.offset2 \
		FROM joeis j, asinfo a\
		WHERE j.aseqno = a.aseqno \
		  AND j.superclass IN $(GENSEQ) \
		ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
holjoeis1:
	$(DBAT) -x "SELECT COUNT(superclass), superclass \
		FROM joeis \
		WHERE superclass IN $(GENSEQ) \
		GROUP BY superclass \
		ORDER BY 1" 
	$(DBAT) -x "SELECT COUNT(superclass), 'generated total' \
		FROM joeis \
		WHERE superclass IN $(GENSEQ) \
		ORDER BY 1" 
#----
jlist:
	cut -b1-7 holjoeis.tmp | xargs -l -i{} cmd /c jo {}
#----
holregen: # takes quite some time on Windows because all Java sources in the list are read
	perl holregen.pl holjoeis.tmp \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
holremote: # do it much faster on Linux
	scp holregen.pl holjoeis.tmp makefile $(REMOTE)/holrec
	ssh gfis@atair 'cd ~/work/gits/OEIS-mat/holrec ; make holregen'
	scp $(REMOTE)/holrec/holregen.tmp .
#----
holgf: holgf1 holgf2
holgf1:
	grep Gener holregen.tmp \
	| sed -e "s/holos/holgf/" \
	>        $@.tmp
	head -n4 $@.tmp
holgf2:
	$(HOLT) -d $(D) -f holgf1.tmp \
	| perl -ne "print if length($$_) < 1024;" \
	| perl holshift.pl -f holpatch1.man \
	>        $@.tmp
	wc -L    $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
hyper: hyper1 hyper2
hyper1:
	perl extract_hypergeom.pl $(COMMON)/cat25.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
hyper2:
	make seq LIST=hyper1.tmp
	$(DBAT) -x "SELECT n.aseqno, n.name \
	  FROM asname n, seq s \
	  WHERE n.aseqno = s.aseqno \
	    AND s.aseqno NOT IN (SELECT aseqno FROM joeis) \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
##--------------------------------------------------
gfsqrt: gfsqrt1 gfsqrt2 gfsqrt3 gfsqrt4 
gfsqrt1: # extract all polynomials from m/sqrt(poly)
	perl gfsqrt_grep.pl $(COMMON)/cat25.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
gfsqrt2: # convert polynomials to vectors
	sed -e "s/\tfract[0-9]\t/\tfract1\t/" gfsqrt1.tmp > x.tmp
	$(RAMATH).sequence.JoeisPreparer -f                 x.tmp \
	| grep -E "orgf" \
	| sed -e "s/orgf/gfsqrt/" \
	| cut -f1- \
	| uniq -w7 \
	| grep -v A248193 \
	| sed -e "s/A04939\([0-9]\)\tgfsqrt\t1\t1,\-1/A04939\1\tgfsqrt\t1\t1,\-25/" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
gfsqrt3: # generate matrix and initerms 	
	perl gfsqrt_holrec.pl gfsqrt2.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	grep A095776 $@.tmp
EX=xx
gfsqrt4: # store in DB table and select non-jOEIS
	$(DBAT) -f $(FISCHER)/seq4.create.sql
	cat      gfsqrt3.tmp | $(DBAT) -m csv -r seq4 
	$(DBAT) -4 seq4
	$(DBAT) -n seq4
	$(DBAT) -f gfsqrt.update.sql
	$(DBAT) -x "SELECT s.aseqno, 'holos', s.offset, s.parm1, s.parm2, s.parm3, s.parm4 \
		FROM seq4 s  \
		WHERE s.aseqno NOT IN (SELECT '$(EX)' || aseqno FROM joeis) \
		ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
gfsqrt5:
	tee    $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
gfsqrt6:
	$(HOLT) -n 16 -f gfsqrt4.tmp
#-------------------------------
homgf:    homgf0 homgf1 homgf2 homgf3-7
homgf3-7: homgf3 homgf4 homgf5 homgf6 homgf7
homgf0:
	perl extract_gf.pl -m extract $(COMMON)/cat25.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
homgf1:
	make seq4 LIST=homgf0.tmp
	$(DBAT) -v "DELETE FROM seq4 \
		WHERE  aseqno IN (SELECT aseqno FROM joeis) \
		   OR  aseqno IN (SELECT aseqno FROM poeis)"
		   OR (aseqno IN (SELECT aseqno FROM cojec) AND parm2 = 'ogf'"
	$(DBAT) -v "DELETE FROM seq4 \
		WHERE callcode LIKE 'homgfe%' \
		  AND aseqno IN (SELECT aseqno callcode FROM seq4 WHERE callcode LIKE 'homgfo%')"
	$(DBAT) -x "SELECT s.aseqno, s.callcode, s.offset, s.parm1, s.parm2 \
	    FROM seq4 s \
	    ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@*.tmp
lingf2:
	perl extract_gf.pl -m linr homgf1.tmp \
	>        $@.1.tmp
	head -n4 $@.1.tmp
	wc   -l  $@.1.tmp
	$(RAMATH).sequence.JoeisPreparer -f $@.1.tmp \
	| perl -ne 'if (length($$_) < 1024) { print; }' \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@*.tmp
#--
homgf.pow:
	#2.^nok
	grep -E "\^nok" lingf2.1.tmp | cut -b9- \
	| grep -vE "\^\^" \
	>        homgf2.tmp
	make homgf3-7
homgf.all:
	perl extract_gf.pl -m eval homgf1.tmp \
	>        homgf2.tmp
	head -n4 homgf2.tmp
	wc   -l  homgf2.tmp
	# make homgf3-7
#--
homgf3:
	head -n4 homgf2.tmp
	wc   -l  homgf2.tmp
	$(RAMATH).sequence.JoeisPreparer -f homgf2.tmp \
	| grep -vE "A239112|A245926|A32592[1-9]" \
	| grep -vE "xgf" \
	>        $@.1.tmp
	grep -E  "error|underflow" $@.1.tmp > $@.2.tmp
	grep -vE "error|underflow" $@.1.tmp \
	| sort | uniq -w 14 \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@*.tmp
homgf4:
	perl holmaple.pl                    homgf3.tmp \
	2>&1 >   $@.1.tmp
	grep -E "^A[0-9]" $@.1.tmp > $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
homgf5:
	sed -e "s/\t\([eo][^\t]*\)\t/\t0\t\1\t/"  homgf4.tmp \
	| perl -ne 'if (length($$_) < 1024) { print; }' \
	| grep -vE "A190586|A190589|A230557" \
	| sort | uniq -w 7 \
	>        $@.1.tmp
	wc -l    $@.1.tmp
	make seq4 LIST=$@.1.tmp
	#                                                   matrix   init                   gftype   gf
	$(DBAT) -x "SELECT s.aseqno, s.callcode, i.offset1, s.parm1, SUBSTR(d.data, 1, 64), s.parm2, s.parm3, s.parm4 \
	    FROM seq4 s, asdata d, asinfo i \
	    WHERE s.aseqno = d.aseqno \
	      AND d.aseqno = i.aseqno \
	    ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
homgf6:
	perl prep_homgf.pl -a 2             homgf5.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
homgf7:
	$(RAMATH).sequence.JoeisPreparer -f homgf6.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
#--------
hiter: hiter1 hiter2 hiter3 
hiter1:
	perl hiterate.pl -n 8 \
	| $(HOLT) -n 8 -f - \
	| grep -v null \
	| grep -vE "0,0,0,0," \
	| grep -vE "1,1,1,1,1,1,1,1," \
	| grep -vE "1,0,1,0,1,0,1,0," \
	| grep -vE "1,\-1,1,\-1,1,\-1,1,\-1," \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
ITER=331
hiter2:
	scp hiter1.tmp $(REMOTE)
	ssh $(SERVER) 'cd $(REMDIR); perl hiteval.pl hiter1.tmp | tee hiteval.$(ITER).txt'
	scp $(REMOTE)/hiteval.$(ITER).txt .
hiter3:
	cut -f1 hiteval.$(ITER).txt | sort | uniq > $@.tmp
	make -f $(COMMON)/makefile seq LIST=$@.tmp
	$(DBAT) -x "SELECT COUNT(aseqno) FROM seq WHERE aseqno NOT IN (SELECT aseqno FROM joeis)"
hiter4:
	perl hiteval.pl hiter1.tmp \
	| grep -v "#" \
	| tee    $@.tmp 
	wc -l    $@.tmp
#--------
hiteval1: 
	sort -V hiteval.*.txt  | uniq     > $@.sort.tmp
	cut -b1-7  $@.sort.tmp | uniq -c  > $@.uniqc.tmp
	cat        $@.sort.tmp | uniq -w7 > $@.uniq.tmp
	make -f $(COMMON)/makefile seq LIST=$@.uniq.tmp
	make hiteval
hiteval:
	$(DBAT) -x "SELECT aseqno FROM seq WHERE aseqno NOT IN (SELECT aseqno FROM joeis);" \
	| sed -e "s/\r//" \
	>        $@.notj.tmp
	wc -l    $@.notj.tmp
	
#-------------------
# too slow:
hiter2slow:
	$(DBAT) -f $(FISCHER)/seq4.create.sql
	cat      hiter1.tmp \
	| $(DBAT) -m csv -r seq4 
	$(DBAT) -4 seq4
	$(DBAT) -n seq4
hiter3slow:
	$(DBAT) "SELECT d.aseqno, s.parm2, n.name \
		FROM   asdata d, seq4 s, asname n \
		WHERE d.aseqno = n.aseqno \
		  AND d.data LIKE '%' || s.parm1 || '%' \
		" \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc       $@.tmp
#--------
satis:
	grep -Ei "satis" $(COMMON)/cat25.txt \
	| grep -vE "Decimal expansion|E\.\g\.\f\.|adic integer" \
	| perl satis.pl \
	>        $@.tmp
	grep -E  "\?\?" $@.tmp > $@.rest.tmp
	grep -vE "\?\?" $@.tmp > $@.gen
	head -n4 $@.gen
	wc -l    $@.gen $@.*tmp
#----
sq1:
	perl -ne "print if m{\A\%\w\s+(A\d+)\s+(([EO]\.)?G\.f\.\:?|Expansion of)\s*(\d+)\s*\/\s*sqrt\(1\s*[\+\-]\s*(\d*)\s*\*?\s*x\)\s*\.}i" $(COMMON)/cat25.txt \
	| tee    $@.tmp
	wc -l    $@.tmp
sq2:
	perl -ne "print if m{\A\%\w\s+(A\d+)\s+(Expansion of\s*)?(([EO]\.)?G\.f\.\:?\s*)?(\d+)\/\s*sqrt\(1\s*[\+\-]\s*(\d*)\s*\*?\s*x\s*[\+\-]\s*(\d*)\s*\*?\s*x\^2\)\s*\.}i" $(COMMON)/cat25.txt \
	| tee    $@.tmp
	wc -l    $@.tmp
sq3:
	perl -ne "print if m{\A\%\w\s+(A\d+)\s+(([EO]\.)?G\.f\.\:?|Expansion of)\s*sqrt\(1\s*[\+\-]\s*(\d*)\s*\*?\s*x(\s*[\+\-]\s*(\d*)\s*\*?\s*x\^2)?\)\s*\.}i" $(COMMON)/cat25.txt \
	| tee    $@.tmp
	wc -l    $@.tmp
sq4:
	perl -ne "print if m{\A\%\w\s+(A\d+)\s+(([EO]\.)?G\.f\.\:?|Expansion of)\s*(1\s*[\+\-]\s*(\d*)\s*\*?\s*x(\s*[\+\-]\s*(\d*)\s*\*?\s*x\^2)?\)\^\(\-?\d+\/2\))\s*\.}i" $(COMMON)/cat25.txt \
	| tee    $@.tmp
	wc -l    $@.tmp
sq5:
	perl -ne "print if m{\A\%\w\s+(A\d+)\s+(([EO]\.)?G\.f\.\:?|Expansion of)[^\^]+\^\(\-?\d+\/2\)\s*\.}i" $(COMMON)/cat25.txt \
	| grep -viE "(theta|log|exp|sin|cos|tan|satisf|series|bessel|lambert)" \
	| tee    $@.tmp
	wc -l    $@.tmp
#	perl -ne "print if m{\A\%F\s+(A\d+)\s+(([EO]\.)?G\.f\.\:?|Expansion of)\s*(\d+)\s*\/\s*sqrt\(1\s*[\+\-]\s*(\d*)\s*\*?\s*x\)\s*\.}i" $(COMMON)/cat25.txt \
#----
rectab: recma recurr rectab2 rectab3 rectab4
rectab2: recma5     recur5 
	sort recma5.tmp recur5.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
rectab3:
	grep holo rectab2.tmp \
	| grep -vE "\-256" \
	| grep -vE ",," \
	| grep -vE "=" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
rectab4:
	$(RAMATH).sequence.JoeisPreparer -d $(D) -f rectab3.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--
recma: recma1 recma2 recma3 recma4 recma5
recma1:
	grep -E "^%t A[0-9]* RecurrenceTable" $(COMMON)/cat25.txt \
	| perl -pe "\
	s/^...//; \
	s/ /\t/; \
	s/\..*//; \
	" \
	| perl -ne 'if (length($$_) < $(RTLEN)) { print; }' \
	| uniq -w 7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recma2:
	make -f $(COMMON)/makefile seq2 LIST=recma1.tmp
recma3:
	$(DBAT) -x "SELECT s.aseqno, 'recma', i.offset1, s.info \
		FROM seq2 s, asinfo i \
		WHERE s.aseqno = i.aseqno \
		  AND s.aseqno NOT IN (SELECT aseqno FROM joeis) \
		ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recma4: 
recma5:
	perl rectab.pl -d $(D) recma3.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--
recurr: recur1 recur2 recur3 recur4 recur5
recur1:
	grep -E "^%F A[0-9]* Recurrence\:" $(COMMON)/cat25.txt \
	| perl -pe "\
	s/^...//; \
	s/ /\t/; \
	" \
	| perl -ne 'if (length($$_) < $(RTLEN)) { print; }' \
	| uniq -w 7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recur2:
	make seq3 LIST=recur1.tmp
recur3:
	$(DBAT) -x "SELECT s.aseqno, 'recur', i.offset1, s.info, d.data, d.termno, s.number \
		FROM seq3 s, asdata d, asinfo i \
		WHERE s.aseqno = d.aseqno \
		  AND s.aseqno = i.aseqno \
		  AND s.aseqno NOT IN (SELECT aseqno FROM joeis) \
		ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recur4:
	perl pre_rectab.pl -a $(AINIT) recur3.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recur5:
	perl rectab.pl -d $(D) recur4.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
recform: recform1 recform2 recform3 recform4
recform1:
	perl recform.pl $(COMMON)/cat25.txt \
	| uniq -w 7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recform2:
	make seq3 LIST=recform1.tmp
recform3: recur3 recur4 recur5
recform4:
	grep holo recur5.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	$(RAMATH).sequence.JoeisPreparer -d $(D) -f $@.tmp \
	>        rectab4.tmp
	head -n4 rectab4.tmp
	wc -l    rectab4.tmp
#----
matfin: matfin1 recuf_rest matfin2
matfin0: # on the server
	find $(COMMON)/ajson -iname "*.json" | sort | xargs -l grep -iHE "([CDP]\-finite|[Rr]ecurrence\:)" \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
matfin_scp:
	scp gfis@atair:~/work/gits/OEIS-mat/holrec/matfin0.tmp .
matfin1:
	cat matfin0.tmp \
	| perl -ne 'if (! m {a[\(\]][2-9]\d*\*?n}) { print; }' \
	| grep -vE "A160149" \
	| perl -ne 'print if m{json\:\s*.(D\-finite|[Rr]ecurrence\:)};' \
	| perl -ne 's{^\.\.\/common\/ajson\/(A\d+)\.json\:\s+\"(D\-finite( with recurrence)?( of order \d+)?\:?|[Rr]ecurrence\:)\s*([^\.\[\"\_]+)}{$$1\t$$5}; my $$recur = $$5;'\
	's{\..*}{}; s{ \- \_.*}{}; s{\"}{}g; s{\(?(for |if |with |)\s*n\s*\\u003e\=?\s*\d+\)?}{}i;'\
	's{ }{}g; s{a\(\d+\)\=\-?\d+[\;\,]}{}g; s{\+\-}{\-}g; s{(\(End\))?\,}{}g;'\
	'print if (length($$recur) < 256 and ($$recur !~ m{\d{5}}));' \
	| grep -vE "[\\\!\/]" | grep -vE "[b-lp-zB-Z]" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	mv       $@.tmp recuf1.tmp
matfin2:
	grep -vE "^#" matfin.man > $@.tmp || :
	cut -b1-7 $@.tmp \
	| grep -vE "^ *$$" > grep.tmp || :
	grep -vf grep.tmp recuf7.tmp \
	>             $(FISCHER)/holos.gen   || :
	cat $@.tmp >> $(FISCHER)/holos.gen
	wc -l         $(FISCHER)/holos.gen
#--------
# from http://www.mpia.de/~mathar/public/fischer20200119.pdf
matpap: matpap1 recuf_rest
matpap1:
	EX=ex
	cat mathar-pap.man \
	| grep -vE "	\-" \
	| sed -e "s/\.//" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	mv       $@.tmp recuf1.tmp
matpap2:
	$(RAMATH).sequence.JoeisPreparer -d $(D) -f matpap1.tmp \
	| sed -e "s/\t/\tbva\t0\t/" -e "s/\.//" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
recuf:  recuf1  recuf_rest
recuf_rest: recuf2 recuf3 recuf4 recuf5 recuf6 recuf7
recuf1:
	perl grep_rectab.pl $(COMMON)/cat25.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recuf2:
	uniq -w7 recuf1.tmp \
	| cut -b1-1024 \
	>        $@.tmp
	make -f $(COMMON)/makefile seq2 LIST=$@.tmp
EXT=
recuf3:
	$(DBAT) -x "SELECT s.aseqno, 'recuf', i.offset1, s.info, d.data, d.termno \
		FROM seq2 s, asdata d, asinfo i \
		WHERE s.aseqno = d.aseqno \
		  AND s.aseqno = i.aseqno \
		  AND s.aseqno NOT IN (SELECT '$(EX)' || aseqno FROM joeis) \
		ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recuf4:
	perl pre_rectab.pl  -a $(AINIT) recuf3.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recuf5:
	perl rectab.pl -d $(D) recuf4.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recuf6:
	grep holo recuf5.tmp \
	| grep -vE "\-256" \
	| grep -vE ",," \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recuf7:
	$(RAMATH).sequence.JoeisPreparer -d $(D) -f recuf6.tmp \
	| sed -e "s/\r//" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
njoeis: # LIST
	make -f $(COMMON)/makefile seq 
	$(DBAT) -x "SELECT COUNT(aseqno) FROM seq \
	WHERE aseqno NOT IN (SELECT aseqno FROM joeis)"
#======================================================
