#!make

# OEIS-mat/trirec - triangle recurrences and generating functions
# @(#) $Id$
# 2020-02-17, Georg Fischer: copied from ../linrec
#---------------------------------
GITS=../..
COMMON=../common
LINREC=../linrec
TRIREC=../trirec
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMATH=java -cp  $(GITS)/ramath/dist/ramath.jar org.teherba.ramath
PFRACT=java -cp  $(RAMATH).symbolic.PolyFraction
JOEISPREP=java -cp  $(RAMATH).sequence.JoeisPreparer
D=0
all:
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
	# the wiki index page for lin.rec.s is regenerated with 'make linrec'
#--------
njoeis: # LIST
	make -f $(COMMON)/makefile seq 
	$(DBAT) -x "SELECT COUNT(aseqno) FROM seq \
	WHERE aseqno NOT IN (SELECT aseqno FROM joeis)"
#----
html_checks:
	perl ../bfcheck/tsv_html.pl -m init eval_checks.lst >  check_index.html
	ls -1 *_check.txt | sed -e "s/.txt//" \
	| xargs -l -i{} make -s html_check1 FILE={}
	perl ../bfcheck/tsv_html.pl -m term eval_checks.lst >> check_index.html
html_check1:
	perl ../bfcheck/tsv_html.pl -m var $(FILE).txt > $(FILE).html
deploy_checks:
	scp *check*.html gfis@teherba.org:/var/www/html/teherba.org/OEIS-mat/common/
#----------------
seq: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/seq.create.sql
	cut -b1-7 $(LIST) | grep -E "^A" | $(DBAT) -m csv -r seq
	$(DBAT) -n seq
#====================================
tasin: # "array T as in A-number"
	cat $(COMMON)/joeis_names.txt \
	| perl -ne 'my ($$aseqno, $$superclass, $$name, @rest) = split(/\t/);'\
	'if ($$name =~ m{[A-Z](\([^\)]*\))? (as in|given by) *(A\d+)}) { my $$rseqno = $$3;'\
	' print join("\t", $$aseqno, "$@", 0, $$rseqno, $$superclass, $$name) . "\n"; }'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
cdrof: # (column|diagonal|row) of"
	cat $(COMMON)/joeis_names.txt \
	| perl -ne 'my ($$aseqno, $$superclass, $$name, @rest) = split(/\t/);'\
	'if ($$name =~ m{(column|diagonal|row) of *(A\d+)}) { my $$rseqno = $$2;'\
	' print join("\t", $$aseqno, "$@", 0, $$rseqno, $$superclass, $$name) . "\n"; }'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
tablof: # "Table T(n,k) by antidiagonals of ..."
	cat $(COMMON)/joeis_names.txt \
	| perl -ne 'my ($$aseqno, $$superclass, $$name, @rest) = split(/\t/);'\
	'if ($$name =~ m{\ATable T\(n\, *k\) by antidiagonals of (.*)}) { my $$expr = $$1;'\
	' print join("\t", $$aseqno, "$@", 0, $$expr, $$superclass, $$name) . "\n"; }'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#====================================
# Deléham's DELTA operator
#
dhd: dhd1 dhd2 dhd_joeis dhd_cf dhd_gf
dhd1: # raw extract of word "DELTA" 
	grep DELTA $(COMMON)/cat25.txt \
	| perl dhd_extract.pl \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
dhd2: # separate finite and continued fractions
	grep -v "#" dhd1.tmp > dhd2.tmp
	grep    "#" dhd1.tmp > dhd_bad.tmp
	grep -E  "\.\.\." dhd2.tmp | uniq > dhd2_cont.tmp
	grep -vE "\.\.\." dhd2.tmp | uniq > dhd2_fini.tmp
	grep "seq" dhd2_fini.tmp || :
	wc -l    dhd*.tmp
dhd_joeis: # join with any JOEIS superclass
	make -f $(COMMON)/makefile seq2 LIST=dhd2_fini.tmp
	$(DBAT) "SELECT s.aseqno, j.superclass, s.info \
	FROM seq2 s LEFT JOIN joeis j ON s.aseqno = j.aseqno \
	ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
dhd_cf: # continued fraction
	perl dhd_pfract.pl dhd_joeis.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
dhd_gf: # generating function
	$(JOEISPREP) -f dhd_cf.tmp \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------------------
fract2:
	grep -vE "^#" $(LINREC)/catgf1.tmp \
	| grep -E "fract2" \
	| grep -vE "A134552" \
	| sed -e "s/$$/\t0\t0/" \
	| $(JOEISPREP) -f - \
	>        $@.tmp
	head -4  $@.tmp
	wc -l    $@.tmp
fract2man:
	grep -vE "^#" fract2.man \
	| grep -E "fract2" \
	| grep -vE "A134552" \
	| sed -e "s/$$/\t0\t0/" \
	| $(JOEISPREP) -f - \
	>        $@.tmp
	head -4  $@.tmp
	wc -l    $@.tmp
#--------------------
# Riordan arrays
rio: rio0 rio1 rio2 rio3
rio0:
	grep -iE "Riordan *array" $(COMMON)/cat25.txt \
	>       $@.tmp
	head -4 $@.tmp
	wc -l   $@.tmp
rio1:
	perl extract_rio.pl $(COMMON)/cat25.txt \
	>       $@.tmp
	head -4 $@.tmp
	wc -l   $@.tmp
LIST=rio1.tmp
rio2: # LIST=
	grep -vE "[\?\#]" $(LIST) \
	>       $@.tmp
	head -4 $@.tmp
	wc -l   $@.tmp
rio3:
	cat rio2.tmp \
	| sed -e "s/$$/\t0\t0\t0/" -e "s/rioarr/fract2/"\
	| $(JOEISPREP) -f - \
	>        $@.tmp
	head -4  $@.tmp
	wc -l    $@.tmp
#--------
rsrio: rsrio1 rsrio2
rsrio1:
	grep -E "^A[0-9]" ralf*-riordan.lst \
	| sed -e "s/^/\%r /" \
	| perl extract_rio.pl -d 0 \
	| sort | uniq -w7 \
	>        $@.rest.tmp
	grep rioarr $@.rest.tmp > $@.tmp
	head -4  $@.tmp
	wc -l    $@.rest.tmp $@.tmp
rsrio2:
	make rio2 LIST=rsrio1.tmp
	make rio3
rsrio3:
	make -f ../common/makefile seq2 LIST=rsrio1.tmp
	$(DBAT) -x "SELECT s.aseqno, 'rioarr', 0, '(' || s.info || ')' FROM seq2 s \
	  WHERE s.aseqno NOT IN (SELECT aseqno FROM joeis) \
	  ORDER BY 1" \
	| tee $@.tmp
	wc -l $@.tmp
#--------
# Tables with factorial elements
factabl: factabl1 factabl2
factabl1:
	$(DBAT) -x "SELECT i.aseqno, d.data FROM asinfo i, asdata d \
		WHERE i.aseqno = d.aseqno \
		  AND i.keyword LIKE '%tabl%' \
		  AND d.data LIKE '1,2,1,%' \
		  AND d.data LIKE '%,120,%' \
		  AND d.data LIKE '%,720,%' \
	    ORDER BY i.aseqno;" \
	| perl factabl.pl \
	>         $@.tmp
	head -n 4 $@.tmp
	wc -l     $@.tmp  
	$(DBAT) -f $(COMMON)/seq.create.sql
	cut -d "	" -f 1 $@.tmp | sort | uniq \
	| $(DBAT) -r seq
	$(DBAT)   -n seq
	perl $(COMMON)/html_checks.pl $@.tmp > $@.html
factabl2:
	$(DBAT) -f $(COMMON)/seq2.create.sql
	cut -d "	" -f 1,4 $(COMMON)/catgf3.tmp \
	| grep y \
	| $(DBAT) -r seq2
	$(DBAT)   -n seq2
	$(DBAT) -x "SELECT s.aseqno, s2.info FROM seq s, seq2 s2 \
		WHERE s.aseqno = s2.aseqno \
	    ORDER BY s.aseqno;" \
	>         $@.tmp
	head -n 4 $@.tmp
	wc -l     $@.tmp  
#--------
# Triangles
trigen:
	$(DBAT) -x "SELECT i.aseqno, d.data FROM asinfo i, asdata d \
		WHERE i.aseqno = d.aseqno \
		  AND i.keyword LIKE '%tabl%' \
	    ORDER BY i.aseqno;" \
	>         $@.tmp
	head -n 4 $@.tmp
	wc -l     $@.tmp  
trigen1:
	perl extract_trigen1.pl   trigen.tmp > $@.tmp  
	head -n 4 $@.tmp
	wc -l     $@.tmp  
triknoll:
	perl tricheck.pl -b ../common/bfile -m knoll trigen.tmp > $@.tmp 
	# 2> $@.viol.tmp 
	head -n 4 $@.tmp
	wc -l     $@.*tmp  
#--------
# Triangle recurrences
trec:
	grep -E "^\%[NF]" $(COMMON)/jcat25.txt \
	| perl -ne \
	's{with |where |when |for |if }{for }g;'\
	'if  ((! m{[\!\|]|\.\.\.|ceil|floor|min|max|[Nn]umber|Pi|[Ss]um|[ATa]\d{6}\S}) '\
	' and (m{^\%\w (A\d+)\s+(T\([hi-n]\,\s*[hi-n]\)\s*\=[^\.]*)\.}))'\
	'{ print join("\t", $$1, "$@", 0, $$2) . "\n" }' \
	>         $@.tmp
	head -n 4 $@.tmp
	wc -l     $@.tmp  
#---------------------------
# "more" triangles
trimore: trimore1 trimore2 trimore3
trimore1:
	$(DBAT) -x "SELECT a.aseqno, '0trimore', a.offset1, d.data \
	FROM asinfo a, asdata d \
	WHERE a.aseqno = d.aseqno \
	  AND a.keyword LIKE '%more%' \
	  AND a.keyword LIKE '%tabl%' \
	  AND LENGTH(a.program) = 0 \
	  AND a.aseqno NOT IN (SELECT aseqno FROM joeis) \
	  ORDER BY 1" \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
trimore2:
	# with skipping in trimore.pl
	perl trimore.pl -s trimore1.tmp \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
trimore3:
	$(DBAT) -x -f trimore2.tmp \
	| tee     $@.tmp
	wc -l     $@.tmp
	less      $@.tmp
trimore4:
	grep symmetric trimore2.tmp \
	| cut -f2- \
	>         ../../joeis-lite/internal/fischer/trimore4.fail.log
	cd $(COMMON) ; make -f checks.make joeis_check LOG=trimore4
#-------------------------------
traits: traits1 traits2 traits_ff
traits_ff: traits3 traits4 traits5 traits7
traits1:
	$(DBAT) -x "SELECT a.aseqno \
	FROM asinfo a \
	WHERE a.keyword LIKE '%tabl%' \
	  AND a.offset1 >= 0 \
	  ORDER BY 1" \
	>         $@.tmp
	head -n2  $@.tmp
	wc -l     $@.tmp
traits2:
	$(RAMATH).sequence.Triangle -d 0 -trait -b ../common/bfile -f traits1.tmp -m 528 \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
traits3: 
	# no skipping in trimore.pl
	perl trimore.pl -l 1 -t traits2.tmp \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
traits4:
	$(DBAT) -x -f traits3.tmp \
	| grep -vE "A000041|A00004|A00007" \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
traits5_depr:
	perl prep_traits.pl -d 0 traits4.tmp \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
traits5:
	perl html_traits.pl -d 0 traits4.tmp \
	>         traits_check.html
	wc -l     traits_check.html
traits6_depr:
	cd ../common; perl html_checks.pl -m checks.make ../trirec/traits5.tmp > traits_check.html
traits7_depr:
	cd ../common; scp traits_check.html gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/common
traits7:
	scp traits_check.html gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/common
#--------
power_sides:
	perl power_sides.pl traits2.tmp \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
#-------------------------------	
joeismore:
	$(DBAT) -x "SELECT a.aseqno, 'joeismore', SUBSTR(j.superclass, 1, 16), a.offset1, d.data \
	FROM asinfo a, asdata d, joeis j \
	WHERE a.aseqno = d.aseqno \
	  AND d.aseqno = j.aseqno \
	  AND a.keyword LIKE '%more%' \
	  ORDER BY 1" \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
	# They all run too slow, or are Colin's conjectures.
