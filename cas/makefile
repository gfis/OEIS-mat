#!make

# OEIS-mat/cas - programs for various Computer Algebra Systems
# @(#) $Id$
# 2022-06-10, Georg Fischer: copied from ../holrec
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
HERE=../../../OEIS-mat/cas
COMMON=../common
D=0
TO=4
A=A000000
MANY=999999

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
