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
WEIDIS= weidis

all:
	echo select specific target 
#===============================================
calist:
	grep -Ei "cellular automat" $(COMMON)/joeis_names.txt \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
#----
caelem: caelem1 caelem2
caelem0:
	rm -f $@.raw
	wget "https://oeis.org/wiki/Index_to_Elementary_Cellular_Automata?action=raw" -O $@.raw
caelem1:
	perl cawiki.pl caelem0.raw \
	>        $@.tmp \
	2>       $@.rest.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
caelem2:
	grep -E "^A[0-9]" caelem1.tmp | sort | uniq -w7 \
	>        caelem.gen
	head -n4 caelem.gen
	wc -l    caelem.gen
ca1jpats: # generated all *.jpat
	perl wiki_eval1.pl -m jpat
jpatdeploy:
	cp -v ca1*.jpat $(FISCHER)
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

