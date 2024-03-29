#!make

# OEIS-mat/ca - cellular automata 
# @(#) $Id$
# 2021-11-29, Georg Fischer: copied from ../weidis
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
JOPT=-Doeis.big-factor-limit=1000000000 -Ddebug=$(D) -Dfile.encoding=UTF8 -Xmx3g -Xss2g
ifeq ($(OS),Windows_NT)
    CPS=;
else
    CPS=:
endif
JAVA=java $(JOPT) -cp "$(LITE)/dist/joeis-lite.jar$(CPS)$(JOEIS)/build.tmp/joeis.jar"
#========
all:
	echo select specific target 
#========
ari:
	grep -Pv "\tnull\t" calist.txt \
	| sed -e "s/\t/\t$@\t0\t/" \
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
#---
calist:
	grep -Ei "cellular automat" $(COMMON)/joeis_names.txt \
	| grep -P "\tnull\t" \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
#----
ca1elem: ca1elem1 ca1elem2
ca1elem0:
	rm -f $@.raw
	wget "https://oeis.org/wiki/Index_to_Elementary_Cellular_Automata?action=raw" -O $@.raw
ca1elem1:
	rm -f starred.tmp # it is appended
	perl cawiki.pl -dim 1 ca1elem0.raw \
	>        $@.tmp
	sort starred.tmp | uniq > $@.star.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
ca1elem2:
	grep -E "^A[0-9]" ca1elem1.tmp | sort | uniq -w7 \
	>        ca1elem.gen
	head -n4 ca1elem.gen
	wc -l    ca1elem.gen
#----
ca2elem: ca2elem1 ca2elem2
ca2wget: ca2a ca2b ca2c
ca2ax:
	rm -f $@.raw
	wget 'https://oeis.org/wiki/Index_to_2D_5-Neighbor_Cellular_Automata#Sequences_in_the_OEIS_Related_to_2D_5-Neighbor_Outer_Totalistic_Cellular_Automata_Describing_the_Total_Number_of_ON_Cells?action=raw' \
	    -O $@.raw
ca2bx:
	rm -f $@.raw
	wget 'https://oeis.org/wiki/Index_to_2D_5-Neighbor_Cellular_Automata#Sequences_in_the_OEIS_Related_to_2D_5-Neighbor_Outer_Totalistic_Cellular_Automata_Related_to_the_Position_of_ON_Cells_Along_the_X-Axis?action=raw' \
	    -O $@.raw
ca2cx:
	rm -f $@.raw
	wget 'https://oeis.org/wiki/Index_to_2D_5-Neighbor_Cellular_Automata#Sequences_in_the_OEIS_Related_to_2D_5-Neighbor_Outer_Totalistic_Cellular_Automata_Related_to_the_Position_of_ON_Cells_Along_the_Diagonal?action=raw' \
	    -O $@.raw
#----
c2diag:
	grep -E "representation of the diagonal" $(COMMON)/joeis_names.txt \
	| grep -E "two\-dimensional" \
	| perl -ne 'use strict; my $$line = $$_; $$line =~ m{(Binary|Decimal)}; my $$bindec = lc(substr($$1, 0, 1)); '\
	' $$line =~ m{(corner to the origin|origin to the corner)}; my $$dir = substr($$1, 0, 6); $$dir =~ s{corner}{in}; $$dir =~ s{origin}{out}; '\
	' $$line =~ m{Rule (\d+)}i; my $$rule = $$1; '\
	' print join("\t", substr($$line, 0, 7), "ca2$$dir$$bindec", 0, $$rule, "") . "\n";' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
ca2elem1: c2diag
	rm -f starred.tmp # it is appended
	cp c2diag.tmp                       $@.tmp
	perl cawiki.pl -dim 2a ca2a.raw  >> $@.tmp
	perl cawiki.pl -dim 2b ca2b.raw  >> $@.tmp
	perl cawiki.pl -dim 2c ca2c.raw  >> $@.tmp
	sort starred.tmp | uniq > $@.star.tmp
	head -n4 $@.tmp
	wc -l    $@*.tmp
ca2elem2:
	grep -E "^A[0-9]" ca2elem1.tmp | sort | uniq -w7 \
	>        ca2elem.gen
	head -n4 ca2elem.gen
	wc -l    ca2elem.gen
#----
jpats: # generated all ca1*.jpat
	perl cawiki.pl -m jpat
	ls -1 ca*.jpat \
	| grep -v "ca2on.jpat" \
	| xargs -l -innn cp -v nnn $(FISCHER)
	# ca2on, partsum.jpat and diffseq.jpat may not be copied!
#----
dist:
	cd $(LITE) ; ant -silent dist 2>&1
#----
CC=triangle
MODE=2
NT=8
R=614
BF=
test1:
	$(JAVA) irvine.oeis.ca.Cellular1DAutomaton         -d $(D) $(BF) -cc $(CC) -n $(NT) -m $(MODE) -r $(R)
test2:
	$(JAVA) irvine.oeis.ca.FiveNeighbor2DAutomaton     -d $(D) $(BF) -cc $(CC) -n $(NT) -m $(MODE) -r $(R)
test_A074890:
	$(JAVA) irvine.oeis.ca.A074890
#----
old_gather3: # determine all weidis with their main attributes
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
#================

