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
JPREP=java -cp  $(RAMATH).sequence.JoeisPreparer
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
HERE=../../../OEIS-mat/trirec
CAT=$(COMMON)/jcat25.txt
D=0
#========
all: # all possible targets:
	grep -P "^\w[^\:]*\:" makefile | sort 
	# the wiki index page for lin.rec.s is regenerated with 'make linrec'
#--------
trepl:
	$(DBAT) -f $@.create.sql
	grep -E "^A[0-9]+" $@.man |	cut -f1-2 \
	| $(DBAT) -r $@
	$(DBAT) -4   $@
	$(DBAT) -n   $@
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
tabl:
	$(DBAT) -x "SELECT i.aseqno, SUBSTR(COALESCE(j.superclass, "null"), 1, 7), i.offset1, n.name, b. bfimin || '..' || b.bfimax, i.keyword, i.author \
	  FROM asinfo i, bfinfo b, asname n LEFT JOIN joeis j ON n.aseqno = j.aseqno \
	  WHERE i.aseqno = b.aseqno \
	    AND b.aseqno = n.aseqno \
	    AND i.keyword LIKE '%tabl%' \
	  ORDER BY n.name, i.aseqno;" \
	| perl $(COMMON)/nyi.pl -p \
	>         $@.tmp
	head -n 4 $@.tmp
	wc -l     $@.tmp
cktabl:
	grep "Kimberling" tabl.tmp \
	>         $@.tmp
	head -n 4 $@.tmp
	wc -l     $@.tmp
#====================================
A144562: # A144562 Triangle read by rows: T(n, k) = 2*n*k + n + k - 1.
	cat tabl.tmp \
	| perl -ne 'use strict; s/\s//g; my $$line = $$_; '\
	' if ($$line =~ m{\=((\d+)\*?[a-z]\*?[a-z]\+[a-z]\+[a-z]([\+\-]\d+))(.*)}) {'\
	' my ($$d1, $$d2, $$expr) = ($$2, $$3, $$1); '\
	' print join("\t", substr($$line, 0, 7), "parm3", 0, "A144562", $$d1, $$d2, $$expr, $$line) ."\n"; } '\
	| sort \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	# ' if ($$line =~ m{\= *(\d+) *\* *n *\* *k *\+ *n *\+ *k *([\+\-] *\d+)(.*)}) {'\
	#
#----
A176627:
	grep -P "\= *\d+\^\(k *\* *\(n *[\-\+]k *\)\)" tabl.tmp
	# grep -P "\= *\d+\^\([nk]" tabl.tmp

#----
tasin: # "array T as in A-number"
	cat $(COMMON)/joeis_names.txt \
	| perl -ne 'my ($$aseqno, $$superclass, $$name, @rest) = split(/\t/);'\
	'if ($$name =~ m{[A-Z](\([^\)]*\))? (as in|given by) *(A\d+)}) { my $$rseqno = $$3;'\
	' print join("\t", $$aseqno, "$@", 0, $$rseqno, $$superclass, $$name) . "\n"; }'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
cdrof: # (column|diagonal|row) of"
	cat $(COMMON)/joeis_names.txt \
	| perl -ne 'my ($$aseqno, $$superclass, $$name, @rest) = split(/\t/);'\
	'if ($$name =~ m{(column|diagonal|row) of *(A\d+)}i) { my $$rseqno = $$2;'\
	' print join("\t", $$aseqno, "$@", 0, $$rseqno, $$superclass, $$name) . "\n"; }'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
tablof: # "Table T(n,k) by antidiagonals of ..."
	grep -E "^\%[NF] A" $(CAT) \
	| cut -b4- | sed -e "s/ /\tnull\t/" \
	| perl -ne 'my ($$aseqno, $$superclass, $$name) = split(/\t/);'\
	' if ($$name =~ m{\A(Table|Array) +\w\(\w\, *\w\) +(read )?by +antidiagonals +(of )?(.*)}) { my $$expr = $$4; s{\..*}{}; '\
	' my $$dummy = "    1-----------1                  2-----2                    3---3 4--4"; '\
	' print join("\t", $$aseqno, "$@", 0, $$expr, $$name) . "\n"; }'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#====================================
# Deléham's DELTA operator
#
dhd: dhd1 dhd2 dhd_joeis dhd_cf dhd_gf
dhd1: # raw extract of word "DELTA" 
	grep DELTA $(CAT) \
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
dhd_joeis: # subset: nyi in jOEIS
	make -f $(COMMON)/makefile seq2 LIST=dhd2_fini.tmp
	$(DBAT) "SELECT s.aseqno, 'null', s.info \
	FROM seq2 s, joeis j WHERE s.aseqno = j.aseqno \
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
	$(JPREP) -f dhd_cf.tmp \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
deleham: 
	grep Delé tabl.tmp | grep null > $@.tmp
	grep DELTA $@.tmp | wc -l
#--------------------
fract2:
	grep -vE "^#" $(LINREC)/catgf1.tmp \
	| grep -E "fract2" \
	| grep -vE "A134552" \
	| sed -e "s/$$/\t0\t0/" \
	| $(JPREP) -f - \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
fract2man:
	grep -vE "^#" fract2.man \
	| grep -E "fract2" \
	| grep -vE "A134552" \
	| sed -e "s/$$/\t0\t0/" \
	| $(JPREP) -f - \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------------------
invbinom:
	cat $(COMMON)/joeis_names.txt \
	| grep -iE "binomial transform" \
	| perl invbinom.pl \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------------------
transpose: transpose1 transpose2 transpose3
transpose1:
	$(DBAT) -x "SELECT i.aseqno, d.termno, d.data  \
	  FROM asinfo i, bfdata d \
	  WHERE i.aseqno = d.aseqno \
	    AND i.keyword LIKE '%tabl%' \
	  ORDER BY i.aseqno;" \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
transpose2:
	perl transpose.pl -s 3   transpose1.tmp \
	| sort -k5,5 -k2,2 \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
transpose3:
	perl transpose_detect.pl transpose2.tmp \
	| sort | uniq -w7 \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
	mv -v     $@.tmp transpose.tmp
#--------------------
trimirror:
	grep -Ei "mirror|transpose|revers" tabl.tmp \
	| perl -ne 'use strict; s/\s+\Z//; my $$line = $$_; my ($$aseqno, $$callcode, $$offset, $$name) = split(/\t/, $$line, 4); '\
	' if ($$callcode eq "null" && ($$name =~ m{([Mm]irror|[Tt]ranspose|[Rr]evers)[^A]*(A\d+)})) { '\
	' print join("\t", $$aseqno, "$@", 0, $$2, $$name) ."\n"; } '\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------------------
trirecur:
	grep -P "\tnull\t" tabl.tmp | grep -vE "\,tar[ad]" \
	| grep -iE "T\(" \
	| perl trirecur.pl \
	| sort -k4,4 \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------------------
# Riordan arrays
rio: rio0 rio1 rio2 rio3
rio0:
	grep -iE "Riordan *array" $(CAT) \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
rio1:
	perl extract_rio.pl $(CAT) \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
LIST=rio1.tmp
rio2: # LIST=
	grep -vE "[\?\#]" $(LIST) \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
rio3:
	cat rio2.tmp \
	| sed -e "s/$$/\t0\t0\t0/" -e "s/rioarr/fract2/"\
	| $(JPREP) -f - \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
riordan:
	grep -iE "Riordan" $(CAT) \
	| grep -E "^\%[NCF]" \
	>        $@.tmp
	head -n4 $@.tmp
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
	| tee    $@.tmp
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
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp  
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
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
trecolk: # (column|diagonal|row) of"
	cat $(COMMON)/joeis_names.txt \
	| perl -ne 'my ($$aseqno, $$superclass, $$name, @rest) = split(/\t/);'\
	'if ($$name =~ m{(column|diagonal|row) of *(A\d+)}i) { my $$rseqno = $$2;'\
	' print join("\t", $$aseqno, "$@", 0, $$rseqno, $$superclass, $$name) . "\n"; }'\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp

#--------
tricolk:
	grep -E "^[\%\?][NCFY]" $(CAT) \
	| grep -iE "column" \
	| perl rowsums.pl -c \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.*tmp
#--------
rowsums:
	grep -E "^[\%\?][NCFY]" $(CAT) \
	| grep -iE "row sum" \
	| perl rowsums.pl -r \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.*tmp
#--------
# Triangles
trigen:
	$(DBAT) -x "SELECT i.aseqno, d.data FROM asinfo i, asdata d \
		WHERE i.aseqno = d.aseqno \
		  AND i.keyword LIKE '%tabl%' \
	    ORDER BY i.aseqno;" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp  
trigen1:
	perl extract_trigen1.pl   trigen.tmp > $@.tmp  
	head -n4 $@.tmp
	wc -l    $@.tmp  
triknoll:
	perl tricheck.pl -b ../common/bfile -m knoll trigen.tmp > $@.tmp 
	# 2> $@.viol.tmp 
	head -n4 $@.tmp
	wc -l    $@.*tmp  
#========
trixam0: # prepare a text file in seq4 format with all 'tabl' sequences fulfilling some condition
	# all tables are (n,k) = (0,0) based
	#                                                 parm1   2  3  4  5  6  7  8=nyi, 9=name
	$(DBAT) -x "SELECT i.aseqno, 'trixam', i.offset1, d.data, 'parm2','parm3','parm4','parm5','parm6','parm7' \
	    , SUBSTR(COALESCE(j.superclass, 'nyi____x'), 1, 8) AS parm8, SUBSTR(n.name, 1, 128) \
	    FROM asinfo i, asdata d, asname n LEFT JOIN joeis j ON n.aseqno = j.aseqno \
	    WHERE i.aseqno = d.aseqno \
	      AND d.aseqno = n.aseqno \
	      AND i.keyword LIKE '%tabl%' \
	    ORDER BY 1;" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp  
trixam1: # CC= S= ; evaluate a single condition
	sed -e "s/\ttrixam\w*\t/\t$(CC)\t/" trixam0.tmp \
	| perl -w trixamine.pl -r 6 -s $(S) \
	>        $(CC).tmp 
	head -n2 $(CC).tmp
	wc -l    $(CC).tmp
	cut -f1,2,3,11,12 $(CC).tmp \
	| tee    $(CC).short.tmp
	wc -l    $(CC).short.tmp
trixall: trixam0 trixcut1 trixdiag trixinter0 trixthin # evaluate all conditions
trixy:       # cf. trixamine.pl
	make trixam1 CC=$@
#----
trixcut: trixcut1 trixcut2 trixcut3 # determine triangles that were cut from other triangles
trixcut1:    # remove the first column from all triangles
	sed -e "s/\ttrixam\w*\t/\t$@\t/" trixam0.tmp \
	| perl -w trixamine.pl -r 6 -s $(S) \
	>        $@.tmp 
	head -n2 $@.tmp
	wc -l    $@.tmp
trixcut2:    # load the truncated versions in seq4
	$(DBAT) -f $(FISCHER)/sql/seq4.create.sql
	$(DBAT) -r seq4 < trixcut1.tmp
	$(DBAT) -n seq4
	# load the original triangles in seq2
	$(DBAT) -f $(COMMON)/seq2.create.sql
	cut -f1,4 trixam0.tmp \
	| $(DBAT) -r seq2
trixcut3: # determine which truncated match originals
	$(DBAT) -x "SELECT s2.aseqno, 'tricut1' \
	  || (CASE WHEN s2.aseqno NOT IN (SELECT aseqno from joeis) THEN 'n' ELSE 'y' END) \
	  || (CASE WHEN s4.aseqno NOT IN (SELECT aseqno from joeis) THEN 'n' ELSE 'y' END) \
	  , i.offset1 \
	  , s4.aseqno, s4.parm2 \
	  FROM seq4 s4, seq2 s2, asinfo i \
	  WHERE s2.aseqno <> s4.aseqno \
	    AND s4.aseqno = i.aseqno \
	    AND s2.info LIKE s4.parm1 || '%' \
	    ORDER BY 1,2" \
	>        $@.tmp 
	head -n2 $@.tmp
	wc -l    $@.tmp
trixcut4:
	$(DBAT) -x "\
	    (SELECT s.aseqno, '->', s.parm1 FROM seq4 s WHERE (s.aseqno, s.parm1) IN (SELECT aseqno, rseqno FROM asxref)) \
	    UNION \
	    (SELECT s.aseqno, '<-', s.parm1 FROM seq4 s WHERE (s.aseqno, s.parm1) IN (SELECT rseqno, aseqno FROM asxref)) \
	    ORDER BY 1,2" \
	>        $@.tmp 
	head -n2 $@.tmp
	wc -l    $@.tmp
trixcut5:
	cut -f4 trixcut4.tmp | cut -b1-64 | sort | uniq -c | sort -r \
	> $@.tmp
#----
trixdiag:    # triangles with non-zero elements in the diagonal only
	make trixam1 CC=$@
	grep -P "^A\d+" trixdiag.short.tmp \
	| perl -ne 's{^(A\d+)}{lc(substr($$1, 0, 4)) . "/$$1"}e; m{(\S+)}; print "$$1\n"; '\
	| xargs -innn cp -pv $(JOEIS)/src/irvine/oeis/nnn.java $(LITE)/internal/fischer/manual/ || :
	grep -iHP "super\(" $(LITE)/internal/fischer/manual/*.java \
	>        $@.tmp
	perl $@.pl $@.tmp 2> $@.rest.tmp \
	| tee    $@.gen
	wc -l    $@.gen
	cat      $@.rest.tmp || :
#----
trixint0:  # triangles where columns are interleaved with k+1 zeros
	make trixam1 CC=$@ S=0
#----
trixmirr: trixmirr1 trixmirr2 trixmirr3 trimirr4 trimirr5 # determine the mirror (transpose) of all triangles
trixmirr1:    # determine the column
	sed -e "s/\ttrixam\w*\t/\t$@\t/" trixam0.tmp \
	| perl -w trixamine.pl -s trixmirr \
	>        $@.tmp 
	head -n2 $@.tmp
	wc -l    $@.tmp
trixmirr2:    # load the truncated versions in seq4
	grep -vP "\AA000000" trixmirr1.tmp \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
	$(DBAT) -f $(FISCHER)/sql/seq4.create.sql
	cat $@.tmp | $(DBAT) -r seq4
	$(DBAT) -n seq4
trixmirr3:
	# load the original triangles in seq2
	$(DBAT) -f $(COMMON)/seq2.create.sql
	cut -f1,4 trixam0.tmp \
	| $(DBAT) -r seq2
trimirr4:
	# determine which truncated match originals
	$(DBAT) -x "SELECT s2.aseqno, 'trimirror' \
	  || (CASE WHEN s2.aseqno NOT IN (SELECT aseqno from joeis) THEN 'n' ELSE 'y' END) \
	  || (CASE WHEN s4.aseqno NOT IN (SELECT aseqno from joeis) THEN 'n' ELSE 'y' END) \
	  , i.offset1 \
	  , s4.aseqno, s4.parm2, n.name \
	  FROM seq4 s4, seq2 s2, asinfo i, asname n \
	  WHERE s2.aseqno <> s4.aseqno \
	    AND s4.aseqno = i.aseqno \
	    AND s4.aseqno = n.aseqno \
	    AND s2.info LIKE s4.parm1 || '%' \
	    ORDER BY 1,2" \
	>        $@.tmp 
	head -n2 $@.tmp
	wc -l    $@.tmp
	cut -f2  $@.tmp | sort | uniq -c
trimirr5: # select names of the ones that are both nyi
	$(DBAT) -f $(COMMON)/seq.create.sql
	grep "trimirrornn" trimirr4.tmp | cut -f1 | sort | uniq \
	| $(DBAT) -r seq
	$(DBAT) -x "SELECT s.aseqno, n.name FROM seq s, asname n WHERE s.aseqno = n.aseqno ORDER BY 1" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
#----
# # base sequence in column k=1; for k >= 2: T(n,k) = T(n/k, 1)
trixndivk: trixndivk1 trixndivk2 trixndivk3 
trixndivk1: # determine the column
	sed -e "s/\ttrixam\w*\t/\t$@\t/" trixam0.tmp \
	| perl -w trixamine.pl -s trixndivk \
	>        $@.tmp 
	head -n2 $@.tmp
	wc -l    $@.tmp
trixndivk2:    # load the truncated versions in seq4
	grep -vP "\AA0[0-2]" trixndivk1.tmp \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
	$(DBAT) -f $(FISCHER)/sql/seq4.create.sql
	cat $@.tmp | $(DBAT) -r seq4
	# $(DBAT) "DELETE FROM seq4 WHERE aseqno IN (SELECT aseqno FROM joeis);"
	$(DBAT) -n seq4
trixndivk3:
	# merge with data of referenced sequences
	$(DBAT) -x " \
	  (SELECT s.aseqno, '--------', 0        , '-------------', '-----', '----' FROM seq4 s \
	  ) UNION \
	  (SELECT s.aseqno, 'trindivk_', i.offset1, 'new A0_____()', '', s.parm1 FROM seq4 s, asinfo i \
	    WHERE s.aseqno = i.aseqno \
	  ) UNION \
	  (SELECT s.aseqno, 'trindivk_', i.offset1, 'new ' || x.rseqno || '()', '', d.data  FROM seq4 s, asinfo i, asxref x, asdata d \
	    WHERE s.aseqno = x.aseqno AND s.aseqno = i.aseqno AND x.rseqno = d.aseqno \
	  ) ORDER BY 1,2,6" > $@.txt
	head -n8 $@.txt
	wc -l    $@.txt
#----
# "recluctant" triangles: all rows start with the first n members of an underlying sequence; all diagonals are constant
trixrelu: trixrelu1 trixrelu2 trixrelu3
trixrelu1: # determine the column
	sed -e "s/\ttrixam\w*\t/\t$@\t/" trixam0.tmp \
	| perl -w trixamine.pl -s trixrelu \
	>        $@.tmp 
	head -n2 $@.tmp
	wc -l    $@.tmp
trixrelu2:    # load the truncated versions in seq4
	grep -vP "\AA0[0-2]" trixrelu1.tmp \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
	$(DBAT) -f $(FISCHER)/sql/seq4.create.sql
	cat $@.tmp | $(DBAT) -r seq4
	$(DBAT) "DELETE FROM seq4 WHERE aseqno IN (SELECT aseqno FROM joeis);"
	$(DBAT) -n seq4
trixrelu3:
	# merge with data of referenced sequences
	$(DBAT) -x " \
	  (SELECT s.aseqno, '--------', 0        , '-------------', '-----', '----' FROM seq4 s \
	  ) UNION \
	  (SELECT s.aseqno, 'trirelu_', i.offset1, 'new A0_____()', '', s.parm1 FROM seq4 s, asinfo i \
	    WHERE s.aseqno = i.aseqno \
	  ) UNION \
	  (SELECT s.aseqno, 'trirelu_', i.offset1, 'new ' || x.rseqno || '()', '', d.data  FROM seq4 s, asinfo i, asxref x, asdata d \
	    WHERE s.aseqno = x.aseqno AND s.aseqno = i.aseqno AND x.rseqno = d.aseqno \
	  ) ORDER BY 1,2,6" > $@.txt
	head -n8 $@.txt
	wc -l    $@.txt
#----
# "thin" triangles: only the members of an underlying sequence do occur
trixthin: trixthin1 trixthin2 trixthin3 # determine triangles that have identical columns
trixthin1:    # determine the column
	sed -e "s/\ttrixam\w*\t/\t$@\t/" trixam0.tmp \
	| perl -w trixamine.pl -s trixthin \
	>        $@.tmp 
	head -n2 $@.tmp
	wc -l    $@.tmp
trixthin2:    # load the truncated versions in seq4
	grep -P "\AA" trixthin1.tmp \
	| sed -e "s/ /_/g" -e "s/\t\t/\tx\t/g" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
	$(DBAT) -f $(FISCHER)/sql/seq4.create.sql
	cat $@.tmp | $(DBAT) -s "\t" -r seq4
	$(DBAT) -v "DELETE FROM seq4 WHERE aseqno IN (SELECT aseqno FROM joeis);"
	$(DBAT) -4 seq4
	$(DBAT) -n seq4
trixthin3:
	# merge with data of referenced sequences
	$(DBAT) -x " \
	  (SELECT s.aseqno, '-------', 0        , '-------', parm8, name FROM seq4 s \
	  ) UNION \
	  (SELECT s.aseqno, 'trithi_', i.offset1, 'A0_____', '', s.parm1 FROM seq4 s, asinfo i \
	    WHERE s.aseqno = i.aseqno \
	  ) UNION \
	  (SELECT s.aseqno, 'trithi_', i.offset1, x.rseqno , '', d.data  FROM seq4 s, asinfo i, asxref x, asdata d \
	    WHERE s.aseqno = x.aseqno AND s.aseqno = i.aseqno AND x.rseqno = d.aseqno \
	  ) ORDER BY 1,2,6" > $@.txt
	head -n8 $@.txt
	wc -l    $@.txt
#----
# Toeplitz form: all diagonals are constant
trixtoep: trixtoep1 trixtoep2 trixtoep3 # determine triangles that have identical columns
trixtoep1:    # determine the column
	sed -e "s/\ttrixam\w*\t/\t$@\t/" trixam0.tmp \
	| perl -w trixamine.pl -s trixtoep \
	>        $@.tmp 
	head -n2 $@.tmp
	wc -l    $@.tmp
trixtoep2:    # load the truncated versions in seq4
	grep -vP "\AA0[0-2]" trixtoep1.tmp \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
	$(DBAT) -f $(FISCHER)/sql/seq4.create.sql
	cat $@.tmp | $(DBAT) -r seq4
	$(DBAT) -n seq4
trixtoep3:
	# merge with data of referenced sequences
	$(DBAT) -x " \
	  (SELECT s.aseqno, '-------', 0        , '-------', '-----', '----' FROM seq4 s \
	  ) UNION \
	  (SELECT s.aseqno, 'tritoe_', i.offset1, 'A0_____', '', s.parm1 FROM seq4 s, asinfo i \
	    WHERE s.aseqno = i.aseqno \
	  ) UNION \
	  (SELECT s.aseqno, 'tritoe_', i.offset1, x.rseqno , '', d.data  FROM seq4 s, asinfo i, asxref x, asdata d \
	    WHERE s.aseqno = x.aseqno AND s.aseqno = i.aseqno AND x.rseqno = d.aseqno \
	  ) ORDER BY 1,2,6" > $@.txt
	head -n8 $@.txt
	wc -l    $@.txt
#========
# Triangle recurrences
trec:
	grep -E "^\%[NF]" $(CAT) \
	| perl -ne \
	's{with |where |when |for |if }{for }g;'\
	'if  ((! m{[\!\|]|\.\.\.|ceil|floor|min|max|[Nn]umber|Pi|[Ss]um|[ATa]\d{6}\S}) '\
	' and (m{^\%[NFopt] (A\d+) [^T]*(T\([hi-n]\,\s*[hi-n]\)\s*\=[^\.]*)\.}))'\
	'{ print join("\t", $$1, "$@", 0, $$2) . "\n" }' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
trecpas:
	grep   -P "T\([i-n] *\- *1\, *[i-n] *\- *1\)" trec.tmp \
	| grep -P "T\([i-n] *\- *1\, *[i-n]\)" \
	| grep -vP "T\([i-n] *\- *[2-9k]" \
	| grep -vP "T\([^\,]+\, *[i-n] *(\- *[2-9k]|\+)" \
	| grep -vP "T\([i-n]\, *[i-n] *\- *1" \
	| perl trecpas.pl \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	# cp -v    $@.tmp $(FISCHER)/$@.tmp
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
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
trimore2:
	# with skipping in trimore.pl
	perl trimore.pl -s trimore1.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
trimore3:
	$(DBAT) -x -f trimore2.tmp \
	| tee    $@.tmp
	wc -l    $@.tmp
	less     $@.tmp
trimore4:
	grep symmetric trimore2.tmp \
	| cut -f2- \
	>         ../../joeis-lite/internal/fischer/trimore4.fail.log
	cd $(COMMON) ; make -f checks.make joeis_check LOG=trimore4
#-------------------------------
traits: traits1 traits2 traits_ff
traits_ff: traits3 traits4 traits5 traits7
traits1: # EX= select those with keyword tabl
	$(DBAT) -x "SELECT a.aseqno \
	  FROM asinfo a \
	  WHERE a.keyword LIKE '%tabl%' \
	    AND a.offset1 >= 0 \
	    AND a.aseqno NOT IN (SELECT '$(EX)' || aseqno FROM joeis) \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
traits2: # compute the TraitCard
	$(RAMATH).sequence.Triangle -d 0 -trait -b ../common/bfile -f traits1.tmp -m 528 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
traits3: # Process triangle sequences with "more" and generate SQL SELECT statements
	# no skipping in trimore.pl
	perl trimore.pl -l 1 -t traits2.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
traits4:
	$(DBAT) -x -f traits3.tmp \
	| grep -vE "A000041|A00004|A00007" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
traits5_depr:
	perl prep_traits.pl -d 0 traits4.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
traits5:
	perl html_traits.pl -d 0 traits4.tmp \
	>        traits_check.html
	wc -l    traits_check.html
traits6_depr:
	cd ../common; perl html_checks.pl -m checks.make ../trirec/traits5.tmp > traits_check.html
traits7_depr:
	cd ../common; scp traits_check.html gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/common
traits7:
	scp traits_check.html gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/common
#----
pascal: pascal1 pascal2 pascal3 pascal4 pascal5
pascal1:
	$(RAMATH).sequence.Triangle -d 0 -pascal -b ../common/bfile -f traits1.tmp -m 528 \
	| tee    $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
pascal2:
	cd $(FISCHER) ; make seq4 LIST=$(HERE)/pascal1.tmp
pascal3: # Process triangle and generate SQL SELECT statements
	perl trimore.pl -l 1 -p -t pascal1.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
pascal4: # SELECT/determine the sequences for Left Righ Pasc traits
	$(DBAT) -x -f pascal3.tmp \
	| sed -e "s/A062292/A000578_1/g" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	# | grep -vE "A000041|A00004|A00007" \
	# | sort \ grep -vE "A000041|A00004|A00007" \
	#
pascal5: # assemble groups into seq4 parameters
	perl prep_pascal.pl -l 6 pascal4.tmp \
	>        pascal.tmp \
	2>       $@.rest.tmp
	head -n4 pascal.tmp
	wc -l    pascal*.tmp
pascal_add: # Which nonzero Pascal traits do occur?
	grep Pasc pascal4.tmp \
	| grep -vP "Pasc\t\d+\tA000004" \
	| sort -k4,4 
	| tee    $@.tmp
	wc -l    $@.tmp
#----
binomialx:
	grep BinomialTransform $(COMMON)/joeis_names.txt \
	>        $@.1.tmp
	head -n4 $@.1.tmp
	wc -l    $@.1.tmp
	cut -f1  $@.1.tmp \
	| perl -ne 's/\s+\Z//; print lc(substr($$_, 0,4)) . "/$$_\n"; ' \
	| xargs -l -innn grep -iH super ../../joeis/src/irvine/oeis/nnn.java \
	| tee    $@.tmp
	cat      $@.tmp \
	| perl -ne 'if (m{(A\d\d\d+)[^\(]+\(new (A\d\d\d+)}) { print "$$1\tbinomialx\t0\t$$2\n"; }'\
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
#----
# Modified constant and Pascal triangles 
border: traits1 border1 border2 # EX=
border1: # 528 = 32 rows
	$(RAMATH).sequence.Triangle -border -b ../common/bfile -f traits1.tmp -m 528 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
border2:
	$(DBAT) -x "SELECT i.aseqno, 'Name', i.offset1, n.name, b. bfimin || '..' || b.bfimax, i.keyword, i.author \
	  FROM asinfo i, bfinfo b, asname n LEFT JOIN joeis j ON n.aseqno = j.aseqno \
	  WHERE i.aseqno = b.aseqno \
	    AND b.aseqno = n.aseqno \
	    AND i.keyword LIKE '%tabl%' \
	    AND i.offset1 >= 0 \
	    AND i.aseqno NOT IN (SELECT '$(EX)' || aseqno FROM joeis) \
	    ORDER BY i.aseqno;" \
	>        $@.tmp
	wc -l    $@.tmp
	sort $@.tmp border1.tmp >      border.tmp
#--------
trait_match: trait_match0 trait_match1 trait_match2 trait_match3 trait_match4
trait_match0:
	$(DBAT) -x "SELECT aseqno \
	  FROM asinfo \
	  WHERE keyword LIKE '%tabl%' \
	    AND offset1 >= 0 \
	    AND aseqno IN (SELECT aseqno FROM joeis) \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
trait_match1:
	$(RAMATH).sequence.Triangle -trait -b ../common/bfile -f trait_match0.tmp -m 528 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
trait_match2:
	grep -vE "Sequence" trait_match1.tmp > $@.1.tmp
	sort -k4,4 $(COMMON)/bfdata_uniq.tmp   $@.1.tmp > $@.tmp
trait_match3:
	cat trait_match2.tmp \
	| perl trait_match.pl -m 16 \
	2>       $@.rest.tmp \
	| grep -E "bf" \
	| cut -b1-100 \
	>        $@.tmp
	head -n4 $@*.tmp
	wc -l    $@*.tmp
trait_match4:
	cd $(FISCHER) ; make seq4 LIST=$(HERE)/trait_match3.tmp
	$(DBAT) "DELETE FROM seq4 \
	  WHERE parm1 NOT IN (SELECT aseqno FROM joeis) \
	     OR aseqno = parm1"
	$(DBAT) -x -44444 seq4 \
	| tee trait_match.tmp
	wc -l trait_match.tmp
#--
modtri: modpa modip modco modic
modlr:
	perl traitsel2.pl -d $(D) -lr -s "ls,rs" border.tmp \
	>         $@.tmp
	head -n12 $@.tmp
	grep -E "^\#" $@.tmp | wc -l
modrl:
	perl traitsel2.pl -d $(D) -rl -s "ls,rs" border.tmp \
	>         $@.tmp
	head -n12 $@.tmp
	grep -E "^\#" $@.tmp | wc -l
modpa:
	perl traitsel.pl -s "ls,rs,pa" border.tmp \
	| sed -e "s/Pascal/modpas/" \
	>         $@.tmp
	head -n12 $@.tmp
	grep -E "^\#" $@.tmp | wc -l
modip:
	perl traitsel.pl -s "ls,rs,ip" border.tmp \
	| sed -e "s/InnerPascal/modipas/" \
	>         $@.tmp
	head -n12 $@.tmp
	grep -E "^\#" $@.tmp | wc -l
modco:
	perl traitsel.pl -s "ls,rs,co" border.tmp \
	| sed -e "s/Constant/modcon/" \
	>         $@.tmp
	head -n12 $@.tmp
	grep -E "^\#" $@.tmp | wc -l
moddi:
	perl traitsel.pl -s "ls,di"    border.tmp \
	| sed -e "s/Diff/moddi/" \
	>         $@.tmp
	head -n12 $@.tmp
	grep -E "^\#" $@.tmp | wc -l
moddi2:
	perl $(FISCHER)/find_period.pl -d 0 -g -n 3 moddi.tmp \
	>         $@.tmp
	head -n12 $@.tmp
	grep -E "^\#" $@.tmp | wc -l
modic:
	perl traitsel.pl -s "ls,rs,ic" border.tmp \
	>         $@.tmp
	head -n12 $@.tmp
	grep -E "^\#" $@.tmp | wc -l
modid: # Whether the inner elements have a constant difference
	perl traitsel.pl -s "ls,rs,ic,id" border.tmp \
	>         $@.tmp
	head -n12 $@.tmp
	grep -E "^\#" $@.tmp | wc -l
modic2:
	perl $(FISCHER)/find_period.pl -d 0 -g -n 3 modic.tmp \
	>         $@.tmp
	head -n12 $@.tmp
	grep -E "^\#" $@.tmp | wc -l
#----
sortsides: # sort and count the LeftSide and RightSide traits
	grep -E "LeftSide|RightSide"   border.tmp \
	| cut -f4 \
	| perl -ne 'my @terms = split(/\,/); '\
	' splice(@terms, 0, 3); print join(",", @terms) . "\n"; '\
	| sort | uniq -c \
	>   x.tmp
	cat x.tmp \
	| perl accumulate_sides.pl \
	| sort -nr \
	>         $@.tmp
	head -n32 $@.tmp
#---------
triuple: # Kimberling's triangles
	perl tri_guides.pl -a C \
	>         $@.1.tmp
	grep $@   $@.1.tmp \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
triupcp: triuple
	grep -P "\tparm" triuple.1.tmp \
	| grep -vP "new A00" \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
# triuple_man:
	# cp -v triuple.tmp triuple.man
#---------
fusion: # "correlation triangle"
	grep -E "^%[NCF]" $(CAT) \
	| grep -Pi "self[\- ]fusion" \
	| tee     $@.tmp
	wc -l     $@.tmp
trigB:
	perl tri_guides.pl -a B \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
#---------
# Square array T, read by antidiagonals
trideleh:
	grep -P "Square array T,? read by antidiagonals" tabl.tmp \
	| sort \
	| tee     $@.tmp
#---------
triprod2:
	cat $(COMMON)/joeis_names.txt \
	| perl -ne 'if (m{[\t\,]tabl[\t\,]} and m{\A(A\d+)\t\w+\t(A\d+) *\* *(A\d+)\.}) { my ($$aseqno, $$rseqno, $$sseqno) = ($$1, $$2, $$3);'\
	' print join("\t", $$aseqno, "triprod", 0, $$rseqno, $$sseqno). "\n"; }'\
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
#---------
trisimple:
	cat $(COMMON)/joeis_names.txt \
	| perl trisimple.pl \
	>         $@.tmp
	head -n6  $@.tmp
	wc -l     $@.tmp
#--------
wraptr:
	perl wraptr_prepare.pl $@.man \
	| grep wraptr \
	| sort | uniq -w7 \
	>         $(FISCHER)/$@.gen
#--------
sumpown: # Sums of two powers of m
	grep -P "\t2\," $(COMMON)/bfdata.txt \
	| perl sumpown_guess.pl \
	| tee     $@.tmp
	wc -l     $@.tmp
#--------
triconst:
	cd $(FISCHER) ; make seq4 LIST=$(HERE)/$@.man
	$(DBAT) "DELETE FROM seq4 \
	  WHERE SUBSTR(parm1, 1, 7) LIKE 'A%' AND SUBSTR(parm1, 1, 7) NOT IN (SELECT aseqno FROM joeis) \
	     OR SUBSTR(parm2, 1, 7) LIKE 'A%' AND SUBSTR(parm2, 1, 7) NOT IN (SELECT aseqno FROM joeis) \
	     OR SUBSTR(parm3, 1, 7) LIKE 'A%' AND SUBSTR(parm3, 1, 7) NOT IN (SELECT aseqno FROM joeis); "
	$(DBAT) -x -44444 seq4 > $@.tmp
	wc -l     $@.tmp
	perl wraptr_prepare.pl -2 $@.tmp \
	| perl -pe 's/\twraptr\d\t/\ttriconst\t/' \
	| sort | uniq -w7 \
	>         $(FISCHER)/$@.gen
#--------
tricodiff:
	cd $(FISCHER) ; make seq4 LIST=$(HERE)/$@.man
	$(DBAT) "DELETE FROM seq4 \
	  WHERE SUBSTR(parm1, 1, 7) LIKE 'A%' AND SUBSTR(parm1, 1, 7) NOT IN (SELECT aseqno FROM joeis) \
	     OR SUBSTR(parm2, 1, 7) LIKE 'A%' AND SUBSTR(parm2, 1, 7) NOT IN (SELECT aseqno FROM joeis) \
	     OR SUBSTR(parm3, 1, 7) LIKE 'A%' AND SUBSTR(parm3, 1, 7) NOT IN (SELECT aseqno FROM joeis); "
	$(DBAT) -x -44444 seq4 > $@.tmp
	wc -l     $@.tmp
	perl wraptr_prepare.pl -2 $@.tmp \
	| perl -pe 's/\twraptr(\d)\t/\ttricodiff\t/;' \
	| sort | uniq -w7 \
	>         $(FISCHER)/$@.gen
#--------
const: const1 const2 const3 const4 const5
const1:
	$(RAMATH).sequence.Triangle -d 0 -const -b ../common/bfile -f traits1.tmp -m 136 \
	| tee     $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
const2:
	cd $(FISCHER) ; make seq4 LIST=$(HERE)/const1.tmp
const3: # Process triangle and generate SQL SELECT statements
	perl trimore.pl -l 1 -p -t const1.tmp \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
const4: # SELECT/determine the sequences for Left Righ Constant traits
	$(DBAT) -x -f const3.tmp \
	| sed -e "s/A062292/A000578_1/g" \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
	# | grep -vE "A000041|A00004|A00007" \
	# | sort \ grep -vE "A000041|A00004|A00007" \
	#
const5: # assemble groups into seq4 parameters
	perl prep_pascal.pl -l 6 -t Cons const4.tmp \
	>         const.tmp \
	2>        $@.rest.tmp
	head -n4  const.tmp
	wc -l     const*.tmp
const_add: # Which nonzero Pasc traits do occur?
	grep Pasc const4.tmp \
	| grep -vP "Constant\t\d+\tA000004" \
	| sort -k4,4 
	| tee     $@.tmp
	wc -l     $@.tmp
#--------
tnrec1:
	grep -E "^\%[N] " $(CAT) \
	| grep -P "T[\(\)\[\][i-n\)\]\, ]+\= *[\, Ti-n\+\-\*\/\^\d\(\)\[\]]*" \
	| grep -vEi "number of" \
	| tee $@.tmp
	wc -l     $@.tmp
#---------
trialt3: # 3 triangles constructed by the same rule (alternating)
	grep -E "A202692" tabl.tmp 
	grep -E "constructed by the same rule" tabl.tmp 
#--------
power_sides: # Determine triangles where the LeftSide and RightSide traits are some n^k
	perl power_sides.pl traits2.tmp \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
#--------
# Weight array of ...
weightar:
	grep -E "^[\%\#][NCF]" $(CAT) \
	| grep -E "Weight array" \
	| tee     $@.tmp
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
#----
# copied from ../contrib/ga/makefile
trigft: trigft1 trigft2 trigft3 # guess generating functions
trigft1: # select all nyi triangles from ga
	grep -P "\tnull\t" tabl.tmp \
	>        $@.tmp
	wc -l    $@.tmp
	cd $(COMMON) ; make seq LIST=../trirec/$@.tmp
trigft2: # attach offset and terms if first term is 1
	$(DBAT) -x "SELECT s.aseqno, 'trigf', i.offset1, 10, '[1]', d.data FROM seq s, asdata d, asinfo i \
	  WHERE d.data LIKE '1,%' \
	    AND s.aseqno = d.aseqno \
	    AND d.aseqno = i.aseqno \
	  ORDER BY 1"\
	>        $@.txt
	head -n2 $@.txt
	wc -l    $@.txt
trigft3: # call ordinaryTriangle
	$(JPREP) -f trigft2.txt \
	| tee    $@.gen
	wc -l    $@.gen
	#-------------------------------
trimpl: # sequences that are implemented with triangle.Triangle
	$(DBAT) -x "SELECT j.aseqno, LOWER(SUBSTR(superclass, 1, 6)), 0, n.name \
	  FROM joeis j, asname n \
	WHERE j.superclass IN ('Triangle', 'UpperLeftTriangle') \
	  AND j.aseqno = n.aseqno \
	ORDER BY 1" \
	>         $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
trimpl2:
	cut -f1 trimpl.tmp | perl -ne 's{^(A\d+)}{"\.\.\/\.\.\/joeis\/src\/irvine\/oeis\/" . lc(substr($$1, 0, 4)) . "/$$1\.java"}eg; print;' \
	| xargs -l -innn grep -P "compute|matrixElement| \* A\d\d+|get\(" nnn \
	| tee     $@.tmp
	head -n4  $@.tmp
	wc -l     $@.tmp
#-------------------------------
