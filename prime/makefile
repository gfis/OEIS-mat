#!make

# OEIS-mat/prime - peimes, binary quadratic forms
# @(#) $Id$
# 2023-08-12, Georg Fischer: copied from ../holrec
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar
JPREP=$(RAMATH)  org.teherba.ramath.sequence.JoeisPreparer
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
HERE=../../../OEIS-mat/holrec
MAXT=32
COMMON=../common
D=0
CAT=$(COMMON)/jcat25.txt

all:
	echo select specific target
#===============================================
seq: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/seq.create.sql
	cut -b1-7 $(LIST) | grep -E "^A" | $(DBAT) -m csv -r seq
	$(DBAT) -n seq
delseq: seq # parameters: $(TAB) $(LIST)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
seq2: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/$@.create.sql
	cut -f1-2 $(LIST) | grep -E "^A" | sort | uniq -w7 > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
seq3: # parameter: $(LIST)
	$(DBAT) -f $@.create.sql
	cut -f1-3 $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
seq4: # parameter: $(LIST) with aseqno, offset, parm1, parm2, parm3, parm4, name
	$(DBAT) -f $(FISCHER)/sql/seq4.create.sql
	cat $(LIST) | grep -E "^A" | sort | uniq > seq4.tmp
	$(DBAT) -m csv -r seq4 < seq4.tmp
	$(DBAT) -4 seq4
	$(DBAT) -n seq4
#----
biquf_list: # list of sequences related to binary quadratic forms
	grep -E "^%[NCFHopt]" $(CAT) | grep -iP "binary quadratic form|binaryQF|QuadPrime" | cut -b4-11 | sort | uniq \
	| sed -e "s/^/\^\%[A-Za-z] /" \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
cat_extract: # make a jcat25 extract with the relevant sequences
	grep -E -f biquf_list.tmp $(COMMON)/jcat25.txt \
	| sed -e "s/^%I/\n%I/" \
	>        $@.tmp
	wc -l    $@.tmp
number_biquf: # list all names "Numbers..." in the extract
	grep -P "^.N A\d{6} +Number" cat_extract.tmp
prime_biquf:  # list all names "Primes..."  in the extract
	grep -P "^.N A\d{6} +Prime|Discriminant"  cat_extract.tmp
	
#----
pricong: # Extract "Primes of the form a*x^2 + b*x*y + c*y^2"
	grep -iP "Prime" $(CAT) | grep -P "^%[NFC]" | grep -P "form (\d+) *\*? *[a-cxy]\^2 *[\+\-] *" \
	| cut -b4- | sort | uniq -w7 \
	| grep -vE "A098828" \
	| perl pricong.pl -d 1 \
	2>       $@.rest.tmp \
	| tee    $@.tmp
	wc -l    $@*.tmp
primpoly: # Extract "Prime" ...sum(ai*x^ei) -> aman/A114350.man
	grep -iP "Prime" $(CAT) | grep -P "^%[NFC]" | grep -P "form \-?\d+ *\*? *([a-z])\^\d+ *[\+\-] *\d+ *\*? *\\1(\^\d+)?( *[\+\-] *\d+ *\*? *\\1(\^\d+)?)?" \
	| tee    $@.tmp
	wc -l    $@.tmp
	
	