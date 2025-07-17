#!make

# OEIS-mat/arti - derive jOEIS programs automatically from existing ones
# @(#) $Id$
# 2023-09-01: Georg Fischer
#---------------------------------
GITS=../..
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
CAT=$(COMMON)/jcat25.txt
D=0
G=n
# set_env_var_REMOTE
#-------------
all:
	# targets: new = prepare newseq archlist regen (in that order)
help:
	grep -E "^[a-z]" makefile
#======================
seq: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/$@.create.sql
	cut -b1-7 $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
seq2: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/$@.create.sql
	cut -b1-  $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
seq3: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/$@.create.sql
	cut -b1-  $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
delseq: seq # parameters: $(TAB) $(LIST)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
#==============================
# sort program lines in jcat25
new: sortprep evalsame endirsame
sortprep:
	grep -P "^[\%\#][optF]" $(CAT) \
	| perl sortprep.pl \
	| sort -k2,2 -k4,4 -k1,1 \
	>          $@.tmp
	head -n2   $@.tmp
	wc -l      $@.tmp
evalsame:
	cat sortprep.tmp \
	| grep -vP "€" \
	| perl evalsame.pl \
	| endirect \
	>          $@.tmp
	head -n2   $@.tmp
	wc -l      $@.tmp
endirsame:
	endirect evalsame.tmp \
	| grep -P "^\%" | cut -f3- \
	| grep -P "^A\d+\s*a\(n\) *\=" \
	| grep -P "D\d+" \
	| grep -vP "\tA\d+" \
	>          $@.tmp
	head -n2   $@.tmp
	wc -l      $@.tmp
	# | grep -P "^A\d+ *a\(n\) *\= *" \
#----
evalndir: # extract and count non-DirectSequences in evalsame
	cut -f6 evalsame.tmp | grep A \
	| perl -ne 's/\s+\Z//; foreach my $$aseqno(split(/\,/)) { print "$$aseqno\n"; } ' \
	| sort | uniq -c \
	| perl -ne 's/\s+\Z//; s/\A\s*//; my ($$a, $$b) = split(/\s+/); print "$$b\t$$a\n"; ' \
	>          $@.tmp
	head -n2   $@.tmp
	wc -l      $@.tmp
	cd ../common ; make seq2 LIST=../arti/$@.tmp
	$(DBAT) -x "SELECT s2.aseqno, CAST(s2.info AS INT) FROM seq2 s2 WHERE s2.aseqno NOT IN (SELECT aseqno FROM DIRECT) ORDER BY 2, 1 DESC ;" \
	| tee      $@.tmp
	wc -l      $@.tmp
joeis_ccan:
#----------------------------
maple_lines:
	grep -E "^\%p" jcat25.txt | grep combstruct | cut -b4- \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
xrefari: # get nyi from jcat25.#Y
	grep -P "^\#Y" $(COMMON)/jcat25.txt | grep -P "€\d{6} *\(\w+" \
	| perl   $@.pl \
	| sort -k5 -k1 \
	>        $@.tmp
	wc -l    $@.tmp
	perl $(FISCHER)/htmlize.pl $@.tmp > $@.html
	chmod 755 $@.html
	cmd /c start $@.html
xreflist: # get nyi lists from jcat25.#Y
	grep -P "#Y A\d{6}" ../common/jcat25.txt | cut -b 4- | endirect | perl -pe 's/ /\t/;' \
	| perl   $@.pl \
	>        $@.tmp
	wc -l    $@.tmp
	perl $(FISCHER)/htmlize.pl $@.tmp > $@.html
	chmod 755 $@.html
	cmd /c start $@.html
#----
xrefpair: # get nyi lists from jcat25.#Y
	grep -P "#Y A\d{6}" ../common/jcat25.txt | cut -b 4- | endirect | perl -pe 's/ /\t/;' \
	| perl   $@.pl \
	| sort \
	>        $@.tmp
	wc -l    $@.tmp
	perl $(FISCHER)/htmlize.pl $@.tmp > $@.html
	chmod 755 $@.html
	cmd /c start $@.html
xrefep2: # evaluate pairs
	cut -f2  xrefpair.tmp \
	| sort | uniq > $@.1.tmp
	make seq   LIST=$@.1.tmp
	$(DBAT) -x "SELECT aseqno, callcode, offset1, parms FROM gregen WHERE aseqno IN (SELECT aseqno FROM seq) ORDER BY 1" \
	| perl -pe 's/\^\^/\t/g;' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp 
xrefep3: # remember the gregen records, and merge them into the list
	perl     $@.pl -f xrefep2.tmp xrefpair.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp 
#----
