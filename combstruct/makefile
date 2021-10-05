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
HERE=../../../OEIS-mat/combstruct
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
NT=32
D=0 # debug mode
WIDTH=4

all:
	echo select specific target 
#===============================================
rhlist: # 
	$(DBAT) -x "SELECT i.aseqno, COALESCE(j.superclass, 'null'), n.name, i.keyword, b.bfimax - b.bfimin + 1 \
	  FROM asinfo i, asname n, bfinfo b LEFT JOIN joeis j ON j.aseqno = b.aseqno \
	  WHERE i.aseqno = n.aseqno \
	    AND n.aseqno = b.aseqno \
	    AND i.author LIKE '%Hardin%' \
	    AND i.aseqno NOT IN (SELECT aseqno FROM poeis) \
	  ORDER BY 1;" \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
	# still unimplemented:
	grep -P  "^A[0-9]*\tnull\t" $@.txt \
	| wc -l
#----
rhcomb: rhcomb1 rhcomb2 rhcomb3
rhcomb1:
	cut -b1-7 rhlist.txt \
	>        $@.tmp
	cd $(FISCHER) ; make seq LIST=$(HERE)/$@.tmp
rhcomb2:
	sed -e "s/^/^\%p /" rhcomb1.tmp > $@.grep.tmp
	grep "combstruct" $(COMMON)/jcat25.txt \
	| cut -b4- | sed -e "s/ /\t/" \
	| sort | uniq -w7 \
	>        $@.tmp
	cd $(FISCHER) ; make seq2 LIST=$(HERE)/$@.tmp
rhcomb3:
	$(DBAT) -x "SELECT s.aseqno FROM seq s, seq2 s2 \
	  WHERE s.aseqno = s2.aseqno \
	  ORDER BY 1;" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#================
# A126358 Number of base 4 n-digit numbers with adjacent digits differing by one or less
adjacent: adjacent1 adjacent2
adjacent1:
	grep adjacent rhlist.txt | grep digits \
	| grep -v circular \
	| perl adjacent.pl -d 0 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
adjacent2: # use Maple to generate HolonomicRecurrences
	perl $(COMMON)/callmaple.pl -t 4 -n 32 -p holtram.mpat adjacent1.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cp -v $@.tmp $(FISCHER)/$@.gen
#--------
