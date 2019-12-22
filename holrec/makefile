#!make

# OEIS-mat/holrec - holonomic recurrences
# @(#) $Id$
# 2019-12-09, Georg Fischer: copied from ../linrec
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMATH=java -cp  $(GITS)/ramath/dist/ramath.jar org.teherba.ramath
COMMON=../common
D=0
AINIT=0
RTLEN=256

all: rectab recuf
#===============================================
holtabs:
	$(DBAT) -f holrec.create.sql
	$(DBAT) -f holatt.create.sql
#----
subjoeis:
	$(DBAT) "SELECT aseqno, superclass \
		FROM joeis \
		WHERE superclass in ('LinearRecurrence', 'GeneratingFunctionSequence', 'HolonomicRecurrence') \
		ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
jlist:
	cut -b1-7 subjoeis.tmp | xargs -l -i{} cmd /c jo {}
holregen:
	perl holregen.pl subjoeis.tmp > $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
countjoeis:
	$(DBAT) "SELECT superclass, COUNT(superclass) \
		FROM joeis \
		WHERE superclass in ('LinearRecurrence', 'GeneratingFunctionSequence', 'HolonomicRecurrence') \
		GROUP BY superclass \
		ORDER BY 1" 
#----
rectab: recma recurr rectab2 rectab3 rectab4
rectab2: recma5     recur5 
	sort recma5.tmp recur5.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
rectab3:
	grep holo rectab2.tmp \
	| grep -vE "\-256" \
	| grep -vE ",," \
	| grep -vE "=" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
rectab4:
	$(RAMATH).sequence.JoeisPreparer -d $(D) -f rectab3.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--
recma: recma1 recma2 recma3 recma4 recma5
recma1:
	grep -E "^%t A[0-9]* RecurrenceTable" $(COMMON)/cat25.txt \
	| perl -pe "\
	s/^...//; \
	s/ /\t/; \
	s/\..*//; \
	" \
	| perl -ne 'if (length($$_) < $(RTLEN)) { print; }' \
	| uniq -w 7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recma2:
	make -f $(COMMON)/makefile seq2 LIST=recma1.tmp
recma3:
	$(DBAT) -x "SELECT s.aseqno, 'recma', i.offset1, s.info \
		FROM seq2 s, asinfo i \
		WHERE s.aseqno = i.aseqno \
		  AND s.aseqno NOT IN (SELECT aseqno FROM joeis) \
		ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recma4: 
recma5:
	perl rectab.pl -d $(D) recma3.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--
recurr: recur1 recur2 recur3 recur4 recur5
recur1:
	grep -E "^%F A[0-9]* Recurrence\:" $(COMMON)/cat25.txt \
	| perl -pe "\
	s/^...//; \
	s/ /\t/; \
	" \
	| perl -ne 'if (length($$_) < $(RTLEN)) { print; }' \
	| uniq -w 7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recur2:
	make -f $(COMMON)/makefile seq2 LIST=recur1.tmp
recur3:
	$(DBAT) -x "SELECT s.aseqno, 'recur', i.offset1, s.info, d.data, d.termno \
		FROM seq2 s, asdata d, asinfo i \
		WHERE s.aseqno = d.aseqno \
		  AND s.aseqno = i.aseqno \
		  AND s.aseqno NOT IN (SELECT aseqno FROM joeis) \
		ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recur4:
	perl pre_rectab.pl -a $(AINIT) recur3.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recur5:
	perl rectab.pl -d $(D) recur4.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
recuf: recuf1 recuf2 recuf3 recuf4 recuf5 recuf6 recuf7
recuf1:
	perl grep_rectab.pl $(COMMON)/cat25.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recuf2:
	uniq -w7 recuf1.tmp \
	| cut -b1-1024 \
	>        $@.tmp
	make -f $(COMMON)/makefile seq2 LIST=$@.tmp
recuf3:
	$(DBAT) -x "SELECT s.aseqno, 'recuf', i.offset1, s.info, d.data, d.termno \
		FROM seq2 s, asdata d, asinfo i \
		WHERE s.aseqno = d.aseqno \
		  AND s.aseqno = i.aseqno \
		  AND s.aseqno NOT IN (SELECT aseqno FROM joeis) \
		ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recuf4:
	perl pre_rectab.pl  -a $(AINIT) recuf3.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recuf5:
	perl rectab.pl -d $(D) recuf4.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recuf6:
	grep holo recuf5.tmp \
	| grep -vE "\-256" \
	| grep -vE ",," \
	| grep -vE "=" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
recuf7:
	$(RAMATH).sequence.JoeisPreparer -d $(D) -f recuf6.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--------
njoeis: # LIST
	make -f $(COMMON)/makefile seq 
	$(DBAT) -x "SELECT COUNT(aseqno) FROM seq \
	WHERE aseqno NOT IN (SELECT aseqno FROM joeis)"
#----------------
seq: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/seq.create.sql
	cut -b1-7 $(LIST) | grep -E "^A" | $(DBAT) -m csv -r seq
	$(DBAT) -n seq
delseq: seq # parameters: $(TAB) $(LIST)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
#======================================================
