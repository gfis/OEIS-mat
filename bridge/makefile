#!make

# OEIS-mat/bridge - bridges to other Computer Algebra Systems
# @(#) $Id$
# 2022-06-10, Georg Fischer: copied from ../holrec
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar
JPREP=$(RAMATH)  org.teherba.ramath.sequence.JoeisPreparer
HOLT=$(RAMATH)   irvine.test.HolonomicRecurrenceTest
BVA=$(RAMATH)    org.teherba.ramath.linear.BigVectorArray
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
HERE=../../../OEIS-mat/holrec
MAXT=32
COMMON=../common
D=0
AINIT=0
RTLEN=256
SERVER=gfis@atair
REMDIR=~/work/gits/OEIS-mat/holrec
REMOTE=$(SERVER):$(REMDIR)

all:
	echo select specific target 
#===============================================
seq: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/seq.create.sql
	cut -b1-7 $(LIST) | grep -E "^A" | $(DBAT) -m csv -r seq
	$(DBAT) -n seq
delseq: seq # parameters: $(TAB) $(LIST)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
seq3: # parameter: $(LIST)
	$(DBAT) -f $@.create.sql
	cut -f1-3 $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
seq4: # parameter: $(LIST) with aseqno, offset, parm1, parm2, parm3, parm4, name
	$(DBAT) -f $(FISCHER)/seq4.create.sql
	cat $(LIST) | grep -E "^A" | sort | uniq > seq4.tmp
	$(DBAT) -m csv -r seq4 < seq4.tmp
	$(DBAT) -4 seq4
	$(DBAT) -n seq4
#--------
overwrite: # SRC= TAR= inserts or replaces all records in TAR by the ones in SRC, key is aseqno
	# ---- $@ SRC="(SRC) TAR=$(TAR)
	grep -E "^A[0-9]" $(SRC) | cut -b1-7 > $@.sa.tmp
	grep -vf $@.sa.tmp $(TAR) > $@.tn.tmp || :
	sort $@.tn.tmp $(SRC) > $(TAR)
	wc -l $(TAR)
#----
setofs: # LIST= ; update $(OFFSET)
	#==== $@ LIST=$(LIST)
	cd $(FISCHER) ; make seq4 LIST=$(HERE)/$(LIST)
	$(DBAT)  "UPDATE seq4 s SET offset = (SELECT i.offset1 FROM asinfo i WHERE i.aseqno = s.aseqno) \
	  , callcode = 'holos';"
#----
pari_bad_header: # select unconventional (PARI) headers (55 x)
	grep -Pi "^\%o A\d+ \(.*PARI.*\)" $(COMMON)/jcat25.txt | grep -vE "\(PARI\)"
pari_mm:
	grep -Pi "^\%o A\d+ \(PARI[^\)]*\) +\{?a\(n\)" $(COMMON)/jcat25.txt \
	| grep "Michel Marcus" \
	| perl -ne 's/^\%o //; s/ *\\\\.*/\;\tMM/; s/ *\(PARI[^\)]*\) */\tpari\t0\ta\(n\)\t/i;'\
	' s/\\/\\\\/g; s/\"/\\\"/g; s/\;\;/\;/; print;'\
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
pari_cg:
	grep -Pi "^\%o A\d+ \(PARI[^\)]*\) +\{?a\(n\)" $(COMMON)/jcat25.txt \
	| grep "Greathouse" \
	| perl -ne 's/^\%o //; s/ *\\\\.*/\;\tMM/; s/ *\(PARI[^\)]*\) */\tpari\t0\ta\(n\)\t/i;'\
	' s/\\/\\\\/g; s/\"/\\\"/g; s/\;\;/\;/; print;'\
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
pari_ah:
	grep -Pi "^\%o A\d+ \(PARI[^\)]*\) +\{?a\(n\)" $(COMMON)/jcat25.txt \
	| grep "Howroyd" \
	| perl -ne 's/^\%o //; s/ *\\\\.*/\;\tMM/; s/ *\(PARI[^\)]*\) */\tpari\t0\ta\(n\)\t/i;'\
	' s/\\/\\\\/g; s/\"/\\\"/g; s/\;\;/\;/; print;'\
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
pari_ms:
	grep -Pi "^\%o A\d+ \(PARI[^\)]*\) +\{?a\(n\)" $(COMMON)/jcat25.txt \
	| grep "Michael Somos" \
	| perl -ne 's/^\%o //; s/ *\\\\.*/\;\tMM/; s/ *\(PARI[^\)]*\) */\tpari\t0\ta\(n\)\t/i;'\
	' s/\\/\\\\/g; s/\"/\\\"/g; s/\;\;/\;/; print;'\
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
pari_other:
	grep -Pi "^\%o A\d+ \(PARI[^\)]*\) +\{?a\(n\)" $(COMMON)/jcat25.txt \
	| grep -vE "Michel Marcus|Greathouse" \
	>        $@.tmp
	wc -l    $@.tmp
	
#----
pari_an1:
	grep -Pi "^\%o A\d+ \(PARI[^\)]*\) +\{?a\(n\)" $(COMMON)/jcat25.txt \
	| perl pari_an.pl \
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
#----
pari_prep:
	grep -E "^A058" $(FISCHER)/paria.gen \
	| perl pari_prep.pl
#----
paritest:
	cat $(FISCHER)/$@.gen \
	| perl paritest.pl -d $(D) 2>&1 \
	| tee    $@.log
