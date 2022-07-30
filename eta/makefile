#!make

# OEIS-mat/eta: eta, theta, psi & al. Ramanujan functions
# @(#) $Id$
# 2020-10-31, Georg Fischer: copied from ../weidis
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMJAR=$(GITS)/ramath/dist/ramath.jar 
RAMATH=java -cp  $(RAMJAR) org.teherba.ramath
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
NT=32
COMMON=../common
D=0 # debug mode
HERE=../../OEIS-mat/eta

all:
	echo select specific target 
#===============================================
somos_download:
	rm rama37.gp*
	wget http://grail.eecs.csuohio.edu/~somos/rama37.gp
	rm monster3.gp*
	wget http://grail.eecs.csuohio.edu/~somos/monster3.gp
rama37: rama37a rama37b
rama37a:
	perl -ne 'if (m{\\\\ *(A\d+)}) { print "$$1\n" }; ' rama37.gp \
	| sort | uniq -c \
	| tee    $@.tmp
	wc       $@.tmp
rama37b:
	cut -b9-15 rama37a.tmp > $@.tmp
	cd $(COMMON) ; make seq LIST=$(HERE)/$@.tmp
	$(DBAT) -x "SELECT s.aseqno, j.superclass FROM seq s LEFT JOIN joeis j ON s.aseqno = j.aseqno ORDER BY 1" \
	>        $@.tmp
	grep -E null $@.tmp
#----
monster3: monster3a monster3b
monster3a:
	perl -ne 'if (m{\A(\S+)\s*\\\\ *(A\d+)}) { print join("\t", $$2, $$1) . "\n" }; ' monster3.gp \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
monster3b:
	cd $(COMMON) ; make seq2 LIST=$(HERE)/monster3a.tmp
	$(DBAT) -x "SELECT s.aseqno, j.superclass, '', s.info FROM seq2 s LEFT JOIN joeis j ON s.aseqno = j.aseqno ORDER BY 1" \
	| sed -e "s/\r//" \
	>        $@.tmp
	grep -E null $@.tmp
#----
allmonst:
	grep -E "\\\\" monster3.gp
#----
ecalc: ein1sk # with spread
	perl ecalc.pl -d $(D) -s monster3.gp \
	| sort \
	>        $@.tmp 
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
# chk("T1a==in1([1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],2)");
ein1sk:
	cat monster3.gp \
	| perl -ne 'if (m{chk\(\"(\w+)\=\=in1\(\[[^\]]+\]\,(\d+)}) { print join("\t", $$1, $$2) . "\n"; }' \
	| grep -vE "_" \
	| sort | uniq -w5 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------------------------------
mckaylc:
	grep -E "McKay" $(COMMON)/asname.txt \
	| perl -ne 'if (m{(\d+[a-z])}) { print join("\t", substr($$_, 0, 7), "mckaylc", 0, $$1, substr($$_, 8)); }' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----	
gather: gather1 gather3
gather1: # select from joeis_names
	grep -E "Weight distribution of" $(COMMON)/joeis_names.txt \
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
	$(DBAT) -x "SELECT s.aseqno, d.termno, b.bfimax - b.bfimin + 1, i.offset2, i.keyword, n.name, j.superclass \
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
unfull: # determine the ones which havbe no "full"
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
examples: # primitive, better get all atext on on Linux
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
diffbf: # compare the generated b-file with the downloaded ones
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
multest: multest0 multest1
multest0:
	$(DBAT) -x "SELECT d.aseqno, i.offset1, d.termno, b.bfimax, d.data \
	    FROM asinfo i, bfdata d, bfinfo b \
	    WHERE i.aseqno = d.aseqno \
	      AND d.aseqno = b.aseqno \
	    ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
multest1:
	perl multest.pl multest0.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cut -f5  $@.tmp | sort -r | uniq -c
multest2:
	grep "mult30" multest1.tmp > $@.tmp
	cd $(COMMON) ; make seq2 LIST=../eta/$@.tmp
multest3:
	$(DBAT) -x "SELECT i.aseqno, i.terms, i.author FROM asinfo i, seq2 s, bfinfo b \
	WHERE i.aseqno = s.aseqno \
	  AND s.aseqno = b.aseqno \
	  AND i.keyword NOT LIKE '%mult%' \
	  AND i.keyword NOT LIKE '%tab%' \
	  AND b.maxlen >= 3 \
	ORDER BY 1" \
	| tee    $@.tmp
	wc -l    $@.tmp
#----	

