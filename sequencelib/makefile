#!make

# Makefile in gits/OEIS-mat/sequencelib
# @(#) $Id$
# 2026-04-14: presentation at Rutgers
# 2026-01-25, Georg Fischer: copied from ../sequencedb/makefile
#
GITS=../..
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
LEAN=$(GITS)/sequencelib/Sequencelib/Synthetic
HERE=OEIS-mat/sequencelib
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
njoeis: lean0 in_lean njoeis2 njoeis3 njoeis4 njoeis5  # determine those that are not in jOEIS

lean0: # list of lean sequences -> seq
	find $(LEAN) -type f -name "*.lean" \
	| perl -ne 'if (m/(A\d{6})/) { print "$$1\n";}' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	make -f ../common/makefile seq LIST=$@.tmp
in_lean: # those that are in sequencelib
	$(DBAT) -x "SELECT s.aseqno, n.name, i.keyword, i.termno, i.author FROM seq s, asname n, asinfo i \
	  WHERE s.aseqno = n.aseqno \
	    AND n.aseqno = i.aseqno \
	  ORDER BY 1" \
	| endirect > $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	e        $@.tmp
changed: # load the list of GFis' changes
	sed -e "s/ /\t/" changes.lst | sort | uniq -w7 > $@.lst
	wc -l    $@.lst
	make -f ../common/makefile seq2 LIST=$@.lst
	$(DBAT) -x "SELECT s.aseqno, n.name, i.keyword, i.termno, s2.info FROM seq s, seq2 s2, asname n, asinfo i \
	  WHERE s.aseqno = n.aseqno \
	    AND n.aseqno = i.aseqno \
	    AND i.aseqno = s2.aseqno \
	    AND s2.info > '2022-02-20' \
	  ORDER BY 1" \
	| endirect > $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	e        $@.tmp

corrected: # load the list of GFis' term corrections
	grep -P "^.E" $(COMMON)/jcat25.txt | grep -P "corrected by _Georg Fischer_" \
	| grep -P "\d\d 202[2-6]" | cut -b4- | sed -e "s/ /\t/" | tee $@.lst
	wc -l    $@.lst
	make -f ../common/makefile seq2 LIST=$@.lst
	$(DBAT) -x "SELECT s.aseqno, n.name, i.keyword, i.termno, s2.info FROM seq s, seq2 s2, asname n, asinfo i \
	  WHERE s.aseqno = n.aseqno \
	    AND n.aseqno = i.aseqno \
	    AND i.aseqno = s2.aseqno \
	  ORDER BY 1" \
	| endirect > $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	e        $@.tmp
#----
offset0: # get the offsets from sequencelib sources - about 20 min on Windows
	find $(LEAN) -type f -name "*.lean" \
	| xargs -innn grep -P "(A\d{6})\,\s*offset\s*\:\=\s*(\-?\d+)" nnn \
	| tee    $@.tmp
	head -n4 $@.tmp
offset1: # load offsets into db table seq2
	cat offset0.tmp \
	| perl -ne 'if (m/(A\d{6})\,\s*offset\s*\:\=\s*(\-?\d+)/) { print "$$1\t$$2\n";}' \
	>        $@.tmp
	wc -l    $@.tmp
	make -f ../common/makefile seq2 LIST=$@.tmp
offset2: # compare with offsets in asinfo
	$(DBAT) -x "SELECT s.aseqno, n.name, i.keyword, i.termno, i.offset1, '<>', s2.info FROM seq s, seq2 s2, asname n, asinfo i \
	  WHERE s.aseqno = n.aseqno \
	    AND n.aseqno = i.aseqno \
	    AND i.aseqno = s2.aseqno \
	    AND s2.info <> i.offset1 \
	  ORDER BY 1" \
	| endirect > $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	e        $@.tmp
#----

njoeis2: # those that are not implemented in jOEIS
	$(DBAT) -x "SELECT s.aseqno, n.name, i.keyword, i.termno FROM seq s, asname n, asinfo i \
	  WHERE s.aseqno NOT IN (SELECT j.aseqno FROM joeis j) \
	    AND s.aseqno = n.aseqno \
	    AND n.aseqno = i.aseqno \
	  ORDER BY 1" \
	| endirect > $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	e        $@.tmp
njoeis3: # those that are implemented in jOEIS
	$(DBAT) -x "SELECT s.aseqno, n.name, i.keyword, i.termno, j.superclass FROM seq s, joeis j, asname n, asinfo i \
	  WHERE s.aseqno = j.aseqno \
	    AND j.aseqno = n.aseqno \
	    AND n.aseqno = i.aseqno \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	e        $@.tmp
njoeis4: # those that are in holref
	$(DBAT) -x "SELECT s.aseqno, n.name, i.keyword, i.termno, h.matrix FROM seq s, holref h, asname n, asinfo i \
	  WHERE s.aseqno = h.aseqno \
	    AND h.aseqno = n.aseqno \
	    AND n.aseqno = i.aseqno \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	e        $@.tmp
#----
recur: # those that are in lrindx or in holref
	$(DBAT) -x "\
	  ( SELECT s.aseqno, n.name, i.keyword, i.termno FROM seq s, lrindx l, asname n, asinfo i \
	      WHERE s.aseqno = 'A' || l.seqno \
	        AND 'A' || l.seqno = n.aseqno \
	        AND n.aseqno = i.aseqno \
	  ) UNION \
	  ( SELECT s.aseqno, n.name, i.keyword, i.termno FROM seq s, holref h, asname n, asinfo i \
	      WHERE s.aseqno = h.aseqno \
	        AND h.aseqno = n.aseqno \
	        AND n.aseqno = i.aseqno \
	  ) \
	  ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	e        $@.tmp
#----
rest0: # load not in lean.recur -> seq3
	cut -f1,3 recur.tmp \
	>        $@.tmp
	make -f ../common/makefile seq2 LIST=$@.tmp 
	$(DBAT) "DELETE FROM seq3;"
	$(DBAT) "INSERT INTO seq3 (SELECT s.aseqno, i.keyword, i.termno FROM seq s, asinfo i WHERE s.aseqno = i.aseqno AND s.aseqno NOT IN (SELECT s2.aseqno FROM seq2 s2));" 
	$(DBAT) -n seq3
rest:
	rm -f rest.tmp
	$(DBAT) -x "SELECT 'dead', count(s.aseqno)           FROM seq3 s WHERE s.pattern LIKE '%dead%'" | tee -a rest.tmp
	$(DBAT) -x "SELECT 'unkn,uned,obsc', count(s.aseqno) FROM seq3 s \
	  WHERE s.pattern LIKE '%unkn%' \
	     OR s.pattern LIKE '%uned%' \
	     OR s.pattern LIKE '%obsc%' \
	  " | tee -a  rest.tmp
	$(DBAT) -x "SELECT '<= 10 terms', count(s.aseqno)      FROM seq3 s \
	  WHERE s.info <= 10 \
	  " | tee -a  rest.tmp
	#     OR s.pattern LIKE '%fini%' \
	#     OR s.pattern LIKE '%less%' \
	#
	cat rest.tmp
#----
