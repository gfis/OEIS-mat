#!make

# Makefile in gits/OEIS-mat/sequencedb
# @(#) $Id$
# 2021-06-22, Georg Fischer: copied from ../makefile
#
GITS=../..
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
HERE=OEIS-mat/sequencedb
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
JPREP=java -cp $(GITS)/ramath/dist/ramath.jar org.teherba.ramath.sequence.JoeisPreparer 
ifeq ($(OS),Windows_NT)
    CPS=;
else
    CPS=:
endif
JAVA=java $(JOPT) -cp "$(LITE)/dist/joeis-lite.jar$(CPS)$(JOEIS)/build.tmp/joeis.jar"
JSON=compiled_entities_correct.json 
#----------------
all:
	# Possible targets:
	grep -E "^[a-z]" makefile | sort
#----------------------------------
# preliminary: bring any A-number on 1 line
unzip:
	unzip $(JSON)
flatten:
	perl sdb_flat.pl $(JSON) \
	>        $@.json
	head -n4 $@.json
	wc -l    $@.json
#----------------------------------
# parse into seq4 format
seqdb: # -s takes subset (nyi in jOEIS)
	perl seqdb_parse.pl $(JSON) \
	| sort -k1,1 -k2,2 \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
seqdb_test:
	perl seqdb_parse.pl -s $(JSON) \
	| less
seqdb_load:
	$(DBAT) -f seqdb.create.sql
	$(DBAT) -r seqdb < seqdb.txt
	$(DBAT) -4 seqdb
	$(DBAT) -n seqdb
seqdb_a4:
	cut -f4 seqdb.txt \
	| perl -ne 's{(\d+)}{\#}g; print;' \
	| cut -b1-3 | sort | uniq -c
#----
seqdb4: # order by ix and join with offsets, names
	$(DBAT) -x "SELECT s.aseqno, s.si, b.bfimin, b.bfimax, LENGTH(s.px), s.px, s.ix, s.mt, n.name \
	  FROM seqdb s, asinfo i, asname n, bfinfo b \
	  WHERE s.aseqno = i.aseqno \
	    AND i.aseqno = n.aseqno \
	    AND n.aseqno = b.aseqno \
	    AND n.aseqno NOT IN (SELECT aseqno FROM joeis) \
	    ORDER BY s.aseqno, LENGTH(s.px), s.si DESC"\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
count: # Count the number of sequences in sdb that are not in joeis
	# was 30830 on 2021-06-25
	$(DBAT) -x "SELECT COUNT(DISTINCT s.aseqno) FROM seqdb s;"
#----------------------------------
load_an:
	cut -b2- flatten.json \
	| cut -f1,2 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cd .. ; make seq2 LIST=sequencedb/$@.tmp
#----
notjoeis:
	$(DBAT) -x "SELECT s.aseqno, s.info, n.name \
	  FROM seq2 s, asname n \
	  WHERE s.aseqno = n.aseqno \
	    AND s.aseqno NOT IN (SELECT aseqno FROM joeis) \
	    ORDER BY 1"\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
affine: affine1 affine2 affine3 # extract affine mappings
affine1:
	perl affine.pl seqdb.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
affine2:
	cd $(FISCHER) ; make seq4 LIST=../../../$(HERE)/affine1.tmp
affine3:
	$(DBAT) -x "SELECT s.aseqno, s.callcode, i.offset1, s.parm1, s.parm2, s.parm3, s.parm4, n.name \
	  FROM  seq4 s, asinfo i, asname n, asxref x \
	  WHERE s.aseqno = i.aseqno \
	    AND i.aseqno = n.aseqno \
	    AND n.aseqno = x.aseqno \
	    AND x.rseqno = s.parm1  \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
# Continued fractions
contfrac1:
	grep -P "\tcontfrac\[" seqdb.txt \
	| grep -P "^A\d+\t0[123]\t" \
	| sort \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
contfrac4:
	grep -P "\tcontfrac\[" seqdb4.tmp \
	| grep -i "Continued fract" \
	| sort \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
# Decimal expansions
de1:
	grep -P "\tde\[" seqdb.txt \
	| grep -P "^A\d+\t0[123]\t" \
	| sort \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
decex: decex1 
decex1:
	grep -P "\tde\[" seqdb4.tmp \
	| grep "Decimal expansion" \
	| sort \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
contfrac_de: de1 contfrac1
	sort -k5,5 -k1,1 -k2,2 contfrac1.tmp de1.tmp \
	| perl $@.pl \
	| sort | uniq -w15 \
	| sed -e "s/\t/\tcofr\t0\t/" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp	
#--------
# floor()
floor: floor1
floor1:
	grep -P "^A\d+\t\d+\t\d+\tfloor" seqdb4.tmp \
	| sort \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
simple: simple1 simple2
simple1:
	perl grepx.pl -l 'n;\+;sub;neg;\*;\/;\^;\d+' seqdb4.tmp \
	| uniq -w7 \
	| perl -ne 's/\t[0-9]*\t([0-9]+)\t[0-9]*\t[0-9]*\t/\tinfix\t$$1\t/; print;' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
simple2:
	$(JPREP) -p Z.xpat -f simple1.tmp \
	| perl -ne 's/\tinfix\t/\tsdb_simple\t/; print;' \
	| grep -vE "\<\?" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
