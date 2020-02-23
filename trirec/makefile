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
rio2:
	grep -vE "\?" rio1.tmp \
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
	perl extract_trigen1.pl trigen.tmp > $@.tmp  
	head -n 4 $@.tmp
	wc -l     $@.tmp  
#--------
# Triangle recurrences
trec:
	perl -ne \
	's{with |where |when |for |if }{ }g;'\
	'if  ((! m{[\!\|]|\.\.\.|ceil|floor|min|max|[Nn]umber|Pi|[Ss]um|[ATa]\d{6}\S}) '\
	' and (m{^\%\w (A\d+)\s+(T\([i-n]\,\s*[i-n]\)\s*\=[^\.]*)\.}))'\
	'{ print join("\t", $$1, "$@", 0, $$2) . "\n" }' \
	$(COMMON)/cat25.txt \
	| tee     $@.tmp
	# head -n4 $@.tmp
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
	perl trimore.pl trimore1.tmp \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
trimore3:
	$(DBAT) -x -f trimore2.tmp \
	| tee     $@.tmp
	wc -l     $@.tmp

	less      $@.tmp
#----------------------------	