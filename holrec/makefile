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
runbva:
	$(RAMATH).linear.BigVectorArray -recur "$(REC)"
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
bincoef: bincoef1 bincoef2
	mv -v bincoef2.gen $@.gen
bincoef1:
	grep -E "^.[N] A...... Binomial coe" $(COMMON)/jcat25.txt \
	| perl bincoef.pl \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.*tmp
	make seq4 LIST=$@.tmp
	$(DBAT) "UPDATE seq4 s SET OFFSET = (SELECT offset1          FROM asinfo i WHERE i.aseqno = s.aseqno)\
	  , parm2 = '[' || (SELECT SUBSTR(data,1,LOCATE(',',data)-1) FROM asdata d WHERE d.aseqno = s.aseqno) || ']';"
	$(DBAT) -x "SELECT * FROM seq4 ORDER BY 1" \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
bincoef2:
	perl $(COMMON)/callmaple.pl -t 4 -n 32 -p bincoef.mpat bincoef1.tmp \
	>        $@.tmp
	grep -P "^A[0-9]" $@.tmp | sort | uniq -w7\
	| perl -ne 's/\[\]/\[0\]/g; print; '\
	>        $@.gen
	tail -n4 $@.gen
	wc -l    $@.gen	
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
A1630:
	grep -E "$@" $(COMMON)/bfdata.txt > $@.tmp
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
#--------------------------------
greprec0:
	grep -E "^%[NF]" $(COMMON)/jcat25.txt \
	| perl greprec.pl \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
greprec1:
	perl greprecn.pl greprec0.tmp \
	2>       $@.rest.tmp \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.*tmp
greprec2:
	grep -E "^A[0-9]" greprec1.tmp \
	| perl -ne 's/\s+\Z//; my ($$aseqno, $$cc, $$offset, $$rec, @rest) = split(/\t/, $$_); $$rec =~ s{ }{}g; '\
	' if ($$rec =~ m{a\(n\)\=[n\d\+\-\*\/\^\!\(\)]+\Z}) {'\
	' print join("\t", $$aseqno, "holos", $$offset, substr($$rec, 5), @rest) . "\n"; }' \
	| grep -vE "A051155|A061640|A122743|A152689|A178722|A217238|A231190|A244056|A309675" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.*tmp
greprec3: # convert the formualae into P-finite recurrences
	perl $(COMMON)/callmaple.pl -t 4 -n 64 -p $(FISCHER)/binomin.mpat greprec2.tmp \
	>        $@.tmp
	grep -P "^A[0-9]" $@.tmp | sort | uniq -w7\
	| perl -ne 's/\[\]/\[0\]/g; print; '\
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen	
#--------------------------------
holex:
	grep -P "^(\w+)\t(\w+)\t(a\(n\) *\= *)?[n\d\+\-\*\/\!\(\)\^ ]+\." $(COMMON)/joeis_names.txt \
	| grep null \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----------------
holfind: # LIST=, pure aseqnos
	make seq4 # expects LIST=
	perl $(COMMON)/callmaple.pl -t 4 -n 64 -p holfind.mpat LIST 
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
ADD=4
holminit: # LIST=,ADD=... ; replace initial terms for a holonomic matrix; MATRIX=parm1, INIT=parm2, DIST=parm3, GFTYPE=parm4, rest ... unchanged
	make seq4 # LIST=
	$(DBAT) -x "SELECT s.aseqno, s.callcode, s.offset, s.parm1, d.data, s.parm3, s.parm4, s.parm5, s.parm6, s.parm7, s.parm8, s.name \
	  FROM seq4 s, bfdata d \
	  WHERE s.aseqno = d.aseqno \
	  ORDER BY 1" \
	| perl holminit.pl -a $(ADD) \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp	
#----------------
holfsig:
	grep -iE "^%H" $(COMMON)/jcat25.txt | grep "Index entries for linear recurrences with constant coefficients" \
	| perl holfsig.pl \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	make holminit LIST=$@.tmp ADD=4
	cp -v holminit.tmp $@.gen
#----------------
holgrep: holgrep1 holgrep2
	make holminit LIST=holdfing.tmp ADD=4
	cp -v holminit.tmp $@.gen
holgrep1:
	grep -vE "\!" greprec1.tmp \
	| sed -e "s/^/\%F /" -e "s/\tholos\t0\t/ finite with recurrence\: /" -e "s/\t0//g" -e "s/\t//g" \
	>        $@.1.tmp
	head -n4 $@.1.tmp
	wc -l    $@.1.tmp
	perl holdfin.pl $@.1.tmp \
	2>       $@.rest.tmp \
	| sort | uniq -w7 \
	| grep -vE "A098704|A178722" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.*tmp
holgrep2:
	make holdfing LIST=holgrep1.tmp
#----------------
holdfin: holdfin1 holdfin2
	make holminit LIST=holdfing.tmp ADD=4
	cp -v holminit.tmp $@.gen
holdfin1:
	grep -iE "^%F" $(COMMON)/jcat25.txt | grep -iE "finite with recurrence[ \:]+" \
	| perl holdfin.pl \
	2>       $@.rest.tmp \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.*tmp
holdfin2: 
	make holdfing LIST=holdfin1.tmp
#--
holdfing: # generally useable
	make seq4 
	$(DBAT) -x "SELECT s.aseqno, s.callcode, i.offset1, s.parm1, s.parm2, s.parm3, s.parm4, s.parm5 \
	  FROM seq4 s, asinfo i \
	  WHERE s.aseqno = i.aseqno \
	  ORDER BY 1" \
	| perl $(COMMON)/callmaple.pl -t 4 -n 4 -p holdfinite.mpat \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------

#----------------
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
	grep -E "^[\%]" $(COMMON)/cat25.txt \
	| perl gfsqrt_grep.pl \
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
gfsqrt4: # store in DB table and select non-jOEIS
	make seq4 LIST=gfsqrt3.tmp
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
hermite: # A158811 HolonomicRecurrence     Numerator of Hermite(n, 1/3).
	grep -E "Numerator of Hermite" $(COMMON)/joeis_names.txt \
	| perl gen_hermite.
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
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
homegf: homegf1 homegf2 # extract e.g.f.s and convert them into recurrences
homegf1:
	grep -E "^\%[NF] A[0-9][0-9]* (Expansion of )?([Ee]\.)?[Gg]\.f\." $(COMMON)/jcat25.txt \
	| cut -b4- \
	| perl homegf.pl \
	>        $@.hr.tmp \
	2>       $@.lr.tmp
	head -n4 $@.hr.tmp
	wc -l    $@*.tmp 
homegf2:
	cat homegf1.hr.tmp \
	| grep -vE "A094036|A049214|A055887|A089277|A114584|A132885|A133886|A134424|A174193|A181331|A182015|A187260|A202081|A271940|A273347|A323988" \
	| grep -vE "A049215|A089741|A176287|A273351" \
	| grep -vE "A049216|A184362|A184363|A184365|A184366|A275385" \
	| perl holmaple.pl -n 16 -t 8 \
	  2>&1 > $@.1.tmp
	grep -E "^A[0-9]" $@.1.tmp > $@.tmp
	head -n4 $@.tmp
	wc   -l  $@.tmp
#--
homerr:
	grep -A3 syntax homegf2.1.tmp | grep timelimit | cut -d" " -f2 | sed -e "s/\,/\|/" | perl -e 'undef $$/; $$_ = <>; s/\r?\n//g; print;'
#
# A094036	egf	0	(exp(31*x)-20*exp(23*x)+60*exp(19*x)+20*exp(17*x)+5*exp(16*x)-105*exp(15*x)-120*exp(14*x)+150*exp(13*x)+180*exp(12*x)-300*exp(11*x)-110*exp(10*x)+380*exp(9*x)+160*exp(8*x)-575*exp(7*x)+570*exp(6*x)-186*exp(5*x)-975*exp(4*x)+1645*exp(3*x)-1030*exp(2*x)+274*exp(x)-24)/120
#--
GREP="A049214|A055887|A089277|A114584|A132885|A133886|A134424|A174193|A181331|A182015|A187260|A202081|A271940|A273347|A323988"
hometest:
	grep -E $(GREP) ../common/jcat25.txt | cut -b4- | perl homegf.pl
homexx:
	| grep -vE "A071213|A094036|A097591|A117437|A123125|A144186|A145880|A162508|A174846|A176118|A186363|A193542|A202081|A200560|A242240|A240559|A253282|A275385|A307419" \
	| grep -vE "A097592|A124498|A145881|A242817|A247075|A295794|A302200|A302201" \
	| sort | uniq -w7 \
	# 
homegf3:
	cat homegf2.tmp \
	| perl -ne 'use strict; my @parms = split(/\t/); if ($$parms[3] !~ m{[^ak0-9\(\)\+\-\*]}) { '\
	' $$parms[1] = "bva"; $$parms[3] .= "\t[1]\t0"; print join("\t", @parms); } ' \
	| $(RAMATH).sequence.JoeisPreparer -f - \
	| perl -ne 'use strict; my @parms = split(/\t/); '\
	' $$parms[1] = "holos" . $$parms[6]; $$parms[6] .= "gf"; print join("\t", @parms);' \
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
unsure4:
	make holminit LIST=hiteval.uniqw.tmp
	cp -v $(HOLREC)/hiteval.gen $@.gen
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
maplass:
	grep "assisted" $(COMMON)/jcat25.txt | grep Israel | cut -b4-10 \
	| tee    $@.tmp
	wc -l    $@.tmp
	make seq LIST=$@.tmp
	$(DBAT) -x "SELECT s.aseqno, j.superclass, h.matrix FROM seq s, joeis j, holref h \
	  WHERE s.aseqno = j.aseqno \
	    AND h.aseqno = j.aseqno \
	  ORDER BY 1;" \
	| tee    $@.1.tmp
maplass1:
	$(DBAT) -x "SELECT a.callcode, 'maplas', 0, n.name FROM seq4 a, asname n \
	  WHERE a.callcode = n.aseqno \
	  AND   a.aseqno IN (SELECT a2.aseqno FROm seq4 a2, seq s WHERE s.aseqno = a2.callcode) ORDER BY 1;" \
	>        $@.tmp
	head -n24 $@.tmp
	wc       $@.tmp
maplass2:
	make seq4 LIST=maplass1.tmp
	$(DBAT) -x "SELECT s.aseqno, 'holos', 0, 0, d.data, 0, 0 FROM seq4 s, bfdata d \
	  WHERE s.aseqno = d.aseqno \
	  ORDER BY 1;" \
	>        $@.tmp
	head -n4 $@.tmp
	wc       $@.tmp
maplass3:
	perl holminit.pl -n 128 maplass2.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc       $@.tmp
maplass4:
	perl $(COMMON)/callmaple.pl -t 10 -n 16 -p holfind.mpat maplass2.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc       $@.tmp
#--------
satis:
	grep -Ei "satis" $(COMMON)/jcat25.txt \
	| grep -E "^\%" \
	| grep -vE "Decimal expansion|E\.\g\.\f\.|adic integer" \
	| perl satis.pl \
	>        $@.tmp
	grep -E  "\?\?" $@.tmp > $@.rest.tmp
	grep -vE "\?\?" $@.tmp \
	| sort | uniq -w7 \
	> $@.gen
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
	| perl -ne 'if (! m{a[\(\]][2-9]\d*\*?n}) { print; }' \
	| grep -vE "A160149" \
	| perl -ne 'print if m{json\:\s*.(D\-finite|[Rr]ecurrence\:)};' \
	| perl -ne 's{^\.\.\/common\/ajson\/(A\d+)\.json\:\s+\"(D\-finite( with recurrence)?( of order \d+)?\:?|[Rr]ecurrence\:)\s*([^\.\[\"\_]+)}{$$1\t$$5}; my $$recur = $$5;'\
	's{\..*}{}; s{ \- \_.*}{}; s{\"}{}g; s{\(?(for |if |with |)\s*n\s*\\u003e\=?\s*\d+\)?}{}i;'\
	's{ }{}g; s{a\(\d+\)\=\-?\d+[\;\,]}{}g; s{\+\-}{\-}g; s{(\(End\))?\,}{}g;'\
	'print if (length($$recur) < 2000 and ($$recur !~ m{\d{5}}));' \
	| grep -vE "[\\\!\/]" | grep -vE "[b-lp-zB-Z]" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cp       $@.tmp recuf1.tmp
matfin2:
	grep -vE "^#" matfin.man > $@.tmp || :
	cut -b1-7 $@.tmp \
	| grep -vE "^ *$$" > grep.tmp || :
	echo A000000 > grep.tmp 
	echo > $@.tmp
	  # Caution, 2 lines before invalidate matfin.man
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
	| cut -b1-40000 \
	>        $@.tmp
	make -f $(COMMON)/makefile seq2 LIST=$@.tmp
EXT=
recuf3:
	$(DBAT) -x "SELECT s.aseqno, 'recuf', i.offset1, s.info, d.data, d.termno \
		FROM seq2 s, asdata d, asinfo i \
		WHERE s.aseqno = d.aseqno \
		  AND d.aseqno = i.aseqno \
		  AND i.aseqno NOT IN (SELECT '$(EX)' || aseqno FROM joeis) \
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
