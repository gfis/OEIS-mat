#!make

# OEIS-mat/weidis - weight distributions
# @(#) $Id$
# 2020-07-14: restart
# 2020-04-14, Georg Fischer: copied from ../holrec
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
COMMON=../common
D=0 # debug mode
WEIDIS= weidis

all:
	echo select specific target 
#===============================================
gather: gather1 gather3
gather1: # select from joeis_names
	grep -Ei "Weight (distribution|enumerator) of" $(COMMON)/joeis_names.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	grep -v "full" $@.tmp | wc -l
	cd $(COMMON) ; make seq LIST=../$(WEIDIS)/$@.tmp
gather2:
	$(DBAT) -x "SELECT SUBSTR(s.aseqno, 2, 6) FROM seq s ORDER BY 1" \
	| sed -e "s/\r//" \
	| xargs -l -inn perl weight_dist.pl -s Ann -o Ann.wd.tmp $(COMMON)/bfile/bnn.txt 
gather3: # determine all weidis with their main attributes
	$(DBAT) -x "SELECT s.aseqno, j.superclass, d.termno, b.bfimax - b.bfimin + 1, i.offset2, i.keyword, n.name \
	  FROM seq s, asdata d, bfinfo b, asinfo i, asname n LEFT JOIN joeis j ON n.aseqno = j.aseqno \
	  WHERE s.aseqno = d.aseqno \
	    AND d.aseqno = b.aseqno \
	    AND b.aseqno = i.aseqno \
	    AND i.aseqno = n.aseqno \
	    ORDER BY 1" \
	| sed -e "s/\tnonn,/\t/" -e "s/,changed//" -e "s/fini,//" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
weiseqdb:
	$(DBAT) -x "SELECT s.aseqno, j.superclass, d.termno, b.bfimax - b.bfimin + 1, q.mt, q.ix, i.keyword, n.name \
	  FROM seq s, asdata d, bfinfo b, asinfo i, seqdb q, asname n LEFT JOIN joeis j ON n.aseqno = j.aseqno \
	  WHERE s.aseqno = d.aseqno \
	    AND d.aseqno = b.aseqno \
	    AND b.aseqno = i.aseqno \
	    AND q.aseqno = i.aseqno \
	    AND i.aseqno = n.aseqno \
	    ORDER BY 1" \
	| sed -e "s/\tnonn,/\t/" -e "s/,changed//" -e "s/fini,//" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp

dummy1:
	$(DBAT) -x "SELECT s.aseqno, '$@', d.mt, d.ix, j.superclass, s.parm1, s.parm2, s.parm3, s.parm4 \
	    FROM seq4 s, seqdb d LEFT JOIN joeis j ON j.aseqno = s.aseqno \
	    WHERE s.aseqno = d.aseqno \
	    ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
unfull: # determine the ones which have no "full"
	$(DBAT) -x "SELECT s.aseqno, d.termno, b.bfimax - b.bfimin + 1, i.keyword, n.name, j.superclass \
	  FROM seq s, asdata d, bfinfo b, asinfo i, asname n LEFT JOIN joeis j ON n.aseqno = j.aseqno \
	  WHERE s.aseqno = d.aseqno \
	    AND d.aseqno = b.aseqno \
	    AND b.aseqno = i.aseqno \
	    AND i.aseqno = n.aseqno \
	    AND i.keyword NOT LIKE '%,full%' \
	    ORDER BY 1" \
	| sed -e "s/\tnonn,/\t/" -e "s/,changed//" -e "s/fini,//" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
grepix: # extract the A-number from the wiki list
	perl -ne 'if (m{\A(A\d{6})\t}) { print "$$1\n"; }' \
	oeis-index.wiki \
	| sort | uniq \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cd $(COMMON) ; make seq2 LIST=../$(WEIDIS)/$@.tmp
	$(DBAT) "SELECT aseqno FROM seq2 WHERE aseqno NOT IN (SELECT aseqno FROM seq)"
#--------
examples: # primitive, better get all atext on Linux
	rm -f $@.tmp
	$(DBAT) -x "SELECT aseqno FROM seq s ORDER BY 1" \
	| sed -e "s/\r//" \
	| xargs -l -innn grep -E "^%e nnn" ../common/cat25.txt >> $@.tmp
#--------
extract: # extract the w.d. from the example sections
	rm -rf bfilext
	mkdir  bfilext
	cut -b1-7 gather1.tmp \
	| sed -e "s/\r//" \
	| xargs -l -innn perl extract_weidis.pl -o bfilext atext/nnn.txt 
	ls -al bfilext
extrm: # remove generated b-file with 1 line only
	wc -l bfilext/* | grep -E " 1 " \
	| sed -e "s/^  *1 //" \
	| xargs -l rm -v || :
	cp -v bfilext/* bfile
#--------
diffbf: # compare the generated b-files with the downloaded ones
	cut -b2-7 gather1.tmp \
	| xargs -l -innn diff -wy --width=64 --suppress-common-lines bfilext/bnnn.txt bfile \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
diffman: # extract the manually selected with differences
	perl -ne 'if (m{\#\s*(A\d+)}) { print "$$1\n"; }' diffbf.man \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
copybf: # get the downloaded b-files
	cut -b2-7 gather1.tmp \
	| xargs -l -innn cp -v ../common/bfile/bnnn.txt bfile
#--------
wroot0:
	grep -Ei "weight (distribution|enumerator)" $(COMMON)/joeis_names.txt \
	| grep -Ei "sqrt|(square|th|2nd|1st) root" | sed -e "s/square/2th/" -e "s/fourth/4th/" -e "s/ = /: /" \
	| perl -ne 'm{\: *(\d+)[^A]+(A\d\d\d+)?}; my $$root = $$1; my $$rseqno = $$2 || "";'\
	' s{\tnull\t}{\twroot\t0\t$$rseqno\t$$root\t}; print; '\
	| tee $@.tmp
wroot:
	cd $(FISCHER) ; make seq4 LIST=../../../OEIS-mat/weidis/wroot.man
	$(DBAT) -x "SELECT s.aseqno, s.callcode, s.offset, s.parm1, s.parm2, s.parm3, a.keyword, s.parm5 \
	    FROM seq4 s, asinfo a, bfinfo b \
	    WHERE s.parm1  = a.aseqno \
	      AND a.aseqno = b.aseqno \
	    ORDER BY 1"\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
wroex1: # A= extract coefficients from example 
	perl -e 'print "$(A)\tfinifull\t0\t";' > $(A).tmp
	grep -E "^\%e $(A)" $(COMMON)/cat25.txt | cut -b12- \
	| perl -ne 's/\s//g; s/\*?y\^\d+//g; s/\*?x\^\d+/\,/g; s/[\+\-]//g; print "$$_";' \
	| tee -a $(A).tmp
wroex:
	make wroex1 A=A109479
	make wroex1 A=A109481
	make wroex1 A=A109483
#--------
same: same1
same1: # throw all terms on a big pile and sort them
	grep -EH "." bfile/* \
	| grep -vE "\:#" \
	| sed -e "s/bfile\///" -e "s/\.txt\:[0-9][0-9]* / /" \
	| grep -vE " (0|1)$$" \
	| sort -k2 | uniq \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
fini10:
	$(DBAT) -x "SELECT i.aseqno, SUBSTR(d.data,1,20), i.keyword, j.superclass, n.name \
	  FROM asdata d, asinfo i, asname n LEFT JOIN joeis j ON n.aseqno = j.aseqno \
	  WHERE d.aseqno = i.aseqno \
	    AND i.aseqno = n.aseqno \
	    AND i.keyword LIKE '%fini%' \
	    AND d.data LIKE '1,0%' \
	    AND n.name NOT LIKE 'Weight distribution%' \
	    ORDER BY 1" \
	| sed -e "s/\tnonn,/\t/" -e "s/,changed//" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
test1:
	# wget -N "https://oeis.org/b151939.txt"
	head -n1600 b151939.txt \
	| perl weight_dist.pl -s A151939 \
	| tee    $@.tmp
	grep -vE " 17" test1.tmp
#================

