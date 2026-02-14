#!make

# OEIS-mat/common - scripts and data common to all subprojects
# @(#) $Id$
# 2019-04-11, Georg Fischer: extracted from $(COMMON)/makefile
#---------------------------------
GITS=../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
DUMPS=../dumps
HEAD=4
COMMON=$(GITS)/OEIS-mat/common
JOEIS=../$(GITS)/gitups/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
PULL=../pull
D=0
RALEN=350
LIST=computed.log
EDIT=
#--------

all:
	# targets: 
help:
	grep -E "^[a-z]" checks.make
#================
# general targets

checks: \
	asdata_check \
	asname_check \
	bad_check    \
	bfdata_check \
	bfdir_check  \
	bfsize_check \
	cons_check   \
	lead0_check  \
	listasc_check\
	nxinc_check  \
	offset_check \
	sign_check   \
	synth_check  \
	terms_check  \
	eval_checks  \
	html_checks
#
#	allocb_check \
#	asdir_check  \
#	bfdata_check \
#	brol_check   \
#	cojec_check  \
#	denom_check  \
#	guide_check  \
#	nydone_check \
#	nydsdb_check \
#	off_a0_check \
#	order_check  \
#	radata_check \
#	rbdata_check \
#	uncat_check  \
#
clean_checks:
	rm -f *_check.txt *_check.htm*
eval_checks:
	cat *check.txt \
	| grep -E "^A[0-9]" \
	| cut -b1-7 | sort | uniq -c > $@.tmp
	gawk -e '{ print $$2 }'        $@.tmp  > fetch_list.txt
	wc -l fetch_list.txt
	wc -l *check*.txt \
	>   $@.`date +%Y-%m-%d.%H_%M`.log
	diff -wy --width=64 \
		$@.`date +%Y-%m-%d.%H_%M`.log $@.log || :
	cp  $@.`date +%Y-%m-%d.%H_%M`.log $@.log
	head -n 999999 *_check.txt > $@.lst
html_checks:
	perl html_checks.pl -init eval_checks.lst >  check_index.html
	ls -1 *_check.txt | sed -e "s/.txt//" \
	| xargs -l -i{} make -f checks.make -s html_check1 FILE={}
	perl html_checks.pl -term eval_checks.lst >> check_index.html
html_check1:
	perl html_checks.pl $(EDIT) -m checks.make $(FILE).txt > $(FILE).html
deploy_checks:
	scp *check*.html gfis@teherba.org:/var/www/html/teherba.org/OEIS-mat/common/
#----------------
## use the ones in makefile:
##
## seq: # parameter: $(LIST)
## 	$(DBAT) -f $(COMMON)/seq.create.sql
## 	cut -b1-7 $(LIST) | grep -E "^A" | sort | uniq > seq.tmp
## 	$(DBAT) -m csv -r seq < seq.tmp
## 	$(DBAT) -n seq
## seq2: # parameter: $(LIST)
## 	$(DBAT) -f $(COMMON)/seq2.create.sql
## 	cat $(LIST) | grep -E "^A" | sort | uniq > seq2.tmp
## 	$(DBAT) -m csv -r seq2 < seq2.tmp
## 	$(DBAT) -4 seq2
## 	$(DBAT) -n seq2
## delseq: seq # parameters: $(TAB) $(LIST)
## 	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
#================
# check targets alphabetically from here

allocb_check: # Sequence is allocated and has a b-file
	$(DBAT) "SELECT d.aseqno \
		, substr(b.created, 1, 16) as bfile_time \
		, substr(d.access , 1, 16) AS seq_time \
		, CASE WHEN d.aseqno IN (SELECT aseqno FROM draft  ) THEN 'yes' ELSE 'no' END AS draft \
		, n.name \
		FROM  asinfo d, bfdir b, asname n \
		WHERE d.aseqno = b.aseqno \
		  AND b.aseqno = n.aseqno \
		  AND d.keyword LIKE '%allocated%' \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
asdata_check: # Terms in sequence and entry in <em>stripped</em> file differ
	grep -vE "^#" $(COMMON)/stripped | sed -e "s/ \,/\t/" -e "s/,$$//"  \
	> x.tmp
	cut -f1,3 asdata.txt > asdata.tmp
	echo -e "A-Number\tName" > $@.txt
	sort x.tmp asdata.tmp | uniq -c | grep -vE "^  *2 " \
	| grep -E "\," \
	| cut -b 9- \
	>> $@.txt || :
	rm -f asd.?.tmp
	wc -l $@.txt
#----
asdir_check: # b-file is newer than sequence 
	$(DBAT) "SELECT d.aseqno \
		, substr(b.created, 1, 16) as bfile_time \
		, substr(d.access , 1, 16) AS seq_time \
		FROM  asinfo d, bfdir b \
		WHERE d.aseqno = b.aseqno  \
		  AND TIMESTAMPDIFF(HOUR, b.created, d.access) < -5 \
		  AND b.created > '2019-02-01 00:00:00' \
	      AND d.aseqno NOT IN (SELECT aseqno FROM draft  ) \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#----
asname_check: # Name in sequence and entry in <em>names</em> file differ
	grep -vE "^#" $(COMMON)/names | sed -e "s/ /	/" \
	> x.tmp
	perl uncode.pl asname.txt > y.tmp
	echo -e "A-Number\tName" > $@.txt
	sort x.tmp y.tmp | uniq -c | grep -vE "^  *2 " \
	| grep -E "[a-zB-Z]" \
	| cut -b 9- \
	| grep -vf $(PULL)/draft_load.tmp \
	>> $@.txt || :
	wc -l $@.txt
#	| grep -v "allocated for " \
#
#----
bad_check: # Check b-files for bad format
	echo -e "A-Number\tbfimin\tbfimax\toffset2\tterms\ttail\tfilesize\tmaxlen\tMessage" > $@.txt
	grep -E "bad" $(COMMON)/bfinfo.txt \
	>>    $@.txt || :
	wc -l $@.txt
#----
bfdata_check: # Compare <em>stripped</em> file with terms extracted from local b-files
	grep -vE "^#" $(COMMON)/stripped | sed -e "s/ \,/\t/" -e "s/,$$//"  \
	> x.tmp
	echo -e "A-Number\tTerms" > $@.txt
	cut -f1,3 -d"	" bfdata.txt > y.tmp
	sort x.tmp y.tmp | uniq -c | grep -vE "^ +2 +" \
	| grep -E "," \
	| cut -b 9- \
	| perl comp_terms.pl \
	| grep -vf $(COMMON)/draft_load.tmp \
	>> $@.txt || :
	wc -l $@.txt
#----
bfdir_check: # Files in <em>bfilelist</em> and not in local dicrectory
	$(DBAT) "SELECT d.aseqno, d.created, d.filesize \
		FROM  bfdir d \
		WHERE d.aseqno NOT IN (SELECT aseqno FROM bfinfo) \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#----
bfsize_check: # Compare <em>bfilelist</em> with local b-file sizes (without drafts)
	$(DBAT) "SELECT d.aseqno \
		, substr(d.created, 1, 16) AS oeis_time, substr(b.access, 1, 16) as local_time \
		, d.filesize AS oeis_size,  b.filesize AS local_size, b.message \
		FROM  bfdir d, bfinfo b \
		WHERE d.filesize <> b.filesize \
		  AND d.aseqno = b.aseqno  \
	      AND d.aseqno NOT IN (SELECT aseqno FROM draft  ) \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#   	        OR substr(d.created, 1, 10)  <> substr(b.access, 1, 10)s \
#		, d.filesize - b.filesize \
#--------------------------------
brol_check: # LIST= 
	echo "A-number	Link" > $@.txt
	cat $(LIST)          >> $@.txt
	make -f checks.make html_check1 EDIT=-e FILE=brol_check
#--------------------------------
cofr_joeis: # Which cofr are not implemented in jOEIS by ContinuedFractionSequence
	$(DBAT) "SELECT i.aseqno, j.superclass, i.keyword, i.program, n.name \
	    FROM asname n, asinfo i LEFT JOIN joeis j ON j.aseqno = i.aseqno \
	    WHERE i.aseqno = n.aseqno \
	      AND i.keyword LIKE '%cofr%' \
	      AND COALESCE(j.superclass, '') NOT LIKE 'ContinuedFraction%' \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--------------------------------
cojec_check: # Conjectured and in joeis
	$(DBAT) "SELECT j.aseqno, j.superclass, a.keyword, a.program \
	    FROM joeis j, asinfo a \
	    WHERE j.aseqno = a.aseqno \
	      AND j.aseqno IN (SELECT aseqno FROM cojec) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
cojec_seq4: # Conjectured and in seq4
	$(DBAT) "SELECT s.aseqno, s.parm5 \
	    FROM seq4 s, asinfo a \
	    WHERE s.aseqno = a.aseqno \
	      AND s.aseqno IN (SELECT aseqno FROM cojec) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--------------------------------
cons_check: consa_check consb_check consc_check
consa_check: # Keyword "cons" and more than one digit in a term
	$(DBAT) "SELECT a.aseqno, b.maxlen, b.terms, b.tail \
		, a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.keyword LIKE '%cons%'  \
	      AND b.maxlen > 1 \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
consb_check: # Keyword "cons" and not "nonn"
	$(DBAT) "SELECT a.aseqno, b.maxlen, b.terms, b.tail \
		, a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.keyword     LIKE '%cons%'  \
	      AND a.keyword NOT LIKE '%nonn%'  \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
consc_check: # Keyword "cons" related to name
	$(DBAT) "SELECT a.aseqno, a.keyword, n.name \
	    FROM asinfo a, asname n \
	    WHERE a.aseqno = n.aseqno \
	      AND a.keyword     LIKE '%cons%'  \
	      AND a.keyword NOT LIKE '%base%'  \
	      AND n.name    NOT LIKE '%xpansion%' \
	      AND n.name    NOT LIKE '%ecimal%' \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#----
dead:
	$(DBAT) -x "SELECT i.aseqno, n.name, 0 \
	    FROM asinfo i, asname n \
	    WHERE i.aseqno = n.aseqno \
	      AND i.keyword LIKE '%dead%' \
	    ORDER BY 1" \
	| perl -ne 'my ($$aseqno, $$name, $$rest) = split(/\t/); $$name =~ m{(A\d\d\d+)}; my $$bseqno = $$1; '\
	' my $$code = lc(substr($$name, 0, 4)); $$code =~ s{inco|not |van |appa|appe}{erro}i; '\
	' print join("\t", $$aseqno, "$@", 0, $$bseqno, $$code, substr($$name, 0, 64)) . "\n";'\
	>        $@.gen
	head -n4 $@.gen
	wc -l    $@.gen
	cd $(FISCHER); make seq4 LIST=../$(COMMON)/$@.gen
dead_check: dead # Where are dead, erroneous sequences still referenced?
	$(DBAT) "SELECT r.aseqno, b.keyword, s.aseqno, s.parm2, a.keyword \
		FROM asxref r, seq4 s, asinfo a, asinfo b \
		WHERE r.aseqno = b.aseqno \
		  AND s.aseqno = r.rseqno \
		  AND s.aseqno = a.aseqno \
		  AND s.parm1 <> r.aseqno \
		  AND (s.parm2 =  'erro' OR s.parm2 =  'dupl') \
		  AND b.keyword NOT LIKE '%dead%' \
		ORDER BY 1" \
	| tee    $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
#--------------------------------
decindex_check: # maxlen of terms in b-file is 1 and decindex < bfimax / 2
	$(DBAT) "SELECT b.aseqno, b.bfimax, b.decindex, b.tail, i.author, n.name \
		FROM bfinfo b, asname n, asinfo i \
		WHERE b.aseqno = i.aseqno \
		  AND i.aseqno = n.aseqno \
		  AND b.bfimax >= 500 \
		  AND b.maxlen = 1 \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#		  AND b.decindex < b.bfimax / 2 \
#
#--------------------------------
denom_check: # Name of the sequence contains "Denominator", keyword <em>sign</em>, and <em>nonn</em> terms
	$(DBAT) -f seq2.create.sql
	grep -i "denominator" asname.txt > $@.tmp
	$(DBAT) -m csv -s "\t" -r seq2 < $@.tmp
	$(DBAT) "SELECT a.aseqno, s.info AS name, a.revision AS rev, substr(a.access, 1, 10) AS changed, a.keyword, a.author \
		FROM seq2 s, asinfo a  \
		LEFT JOIN bfinfo b ON b.aseqno = a.aseqno \
		WHERE a.aseqno = s.aseqno \
		  AND a.keyword LIKE '%sign%' \
		  AND COALESCE(b.message, 'dummy') NOT LIKE '%sign%' \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--------------------------------
full_check: # Keyword "full" and not "synth"
	$(DBAT) "SELECT a.aseqno, a.keyword, b.bfimin, b.bfimax \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.keyword     LIKE '%full%'  \
	      AND a.keyword NOT LIKE '%synth%'  \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#---------------------------
guide_check: # make a list of the "Guide to related sequences"
	echo aseqno > $@.txt
	grep -E "[0-9] Guide to related sequences" jcat25.txt \
	| perl -pe 's{\A.. (A\d+).*}{$$1\tguide};' \
	>>  $@.txt
	wc -l $@.txt
	make -f checks.make html_check1 FILE=$@
#---------------------------
joeis_check: # parameter: LOG in joeis-lite/internal/fischer
	echo "A_Number	bfimax	Status	Expected	Computed" > $@.txt
	grep -E "^A[0-9]" $(FISCHER)/$(LOG).fail.log \
	| gawk -e '{ print $$1 "\t" $$2 "\t" substr($$3,0,8) "\t" substr($$4,0,32) "...\t" substr($$6,0,32) }' \
	| perl -pe "s{\.\.\.}{ ms} if m{pass};" \
	>>       $@.txt
	wc -l    $@.txt
	make -f checks.make html_check1 FILE=$@
joeis_fail: # parameter: LOG in joeis-lite/internal/fischer
	echo "A_Number	bfimax	Status	Expected	Computed" > $@.txt
	grep -E "^A[0-9]" $(FISCHER)/$(LOG).fail.log \
	| grep -vP "\tFATO\t" \
	| gawk -e '{ print $$1 "\t" $$2 "\t" substr($$3,0,8) "\t" substr($$4,0,32) "...\t" substr($$6,0,32) }' \
	| perl -pe "s{\.\.\.}{ ms} if m{pass};" \
	>>       $@.txt
	wc -l    $@.txt
	make -f checks.make html_check1 FILE=$@
joeis_pass: # parameter: LOG in joeis-lite/internal/fischer
	echo "A_Number	bfimax	Status	Expected	Computed" > $@.txt
	grep -E "^A[0-9]" $(FISCHER)/$(LOG).pass.log \
	| grep -vP "\tFATO\t" \
	| gawk -e '{ print $$1 "\t" $$2 "\t" substr($$3,0,8) "\t" substr($$4,0,32) "...\t" substr($$6,0,32) }' \
	| perl -pe "s{\.\.\.}{ ms} if m{pass};" \
	>>       $@.txt
	wc -l    $@.txt
	make -f checks.make html_check1 FILE=$@
joeis_all: # parameter: LOG in joeis-lite/internal/fischer
	echo "A_Number	bfimax	Status	Expected	Computed" > $@.txt
	sort $(FISCHER)/$(LOG).pass.log $(FISCHER)/$(LOG).fail.log | grep -E "^A[0-9]" \
	| gawk -e '{ print $$1 "\t" $$2 "\t" substr($$3,0,8) "\t" substr($$4,0,32) "...\t" substr($$6,0,32) }' \
	| perl -pe "s{\.\.\.}{ ms} if m{pass};" \
	>>       $@.txt
	wc -l    $@.txt
	make -f checks.make html_check1 FILE=$@
#---------------------------
joeis_fini_check: # keyword fini and not subclass of FiniteSequence
	$(DBAT) "SELECT a.aseqno, a.keyword, j.superclass \
	    FROM asinfo a, joeis j \
	    WHERE a.aseqno = j.aseqno \
	      AND a.keyword     LIKE '%fini%'  \
	      AND j.superclass <> 'FiniteSequence' \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
	make -f checks.make html_check1 FILE=$@
#--------------------------------
keyword_check: # Forbidden combinations of keywords
	$(DBAT) "SELECT aseqno, keyword \
	    FROM asinfo a \
	    WHERE (keyword     LIKE '%tabl%' AND keyword     LIKE '%tabf%') \
	      OR  (keyword     LIKE '%nice%' AND keyword     LIKE '%less%') \
	      OR  (keyword     LIKE '%easy%' AND keyword     LIKE '%hard%') \
	      OR  (keyword     LIKE '%nonn%' AND keyword     LIKE '%sign%') \
	      OR  (keyword     LIKE '%full%' AND keyword     LIKE '%more%') \
	      OR  (keyword     LIKE '%cons%' AND keyword     LIKE '%sign%') \
	      OR  (keyword     LIKE '%full%' AND keyword NOT LIKE '%fini%') \
	      OR  (keyword NOT LIKE '%nonn%' AND keyword NOT LIKE '%sign%'  \
	                AND keyword NOT LIKE 'allocat%'  \
	                AND keyword NOT LIKE 'dead%'     \
	                AND keyword NOT LIKE 'recycled%' \
	                AND keyword NOT LIKE 'system%'   \
	          ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#---------------------------
lead0_check:
	cp -v ../lrindex/lead0.tmp $@.txt
	wc -l $@.txt
#---------------------------
listinc_check:
	$(DBAT) "SELECT b.aseqno, b.bfimax - b.bfimin, b.decindex, n.name \
	  FROM bfinfo b, asname n \
	  WHERE b.aseqno = n.aseqno \
	    AND (n.name LIKE 'Numbers _ such that %' \
	     OR  n.name LIKE  'Primes _ such that %' \
	     OR  n.name LIKE  'Primes of form %' \
	     ) \
	    AND b.decindex < b.bfimax - 4 \
	    AND b.decindex > b.bfimin + 4 \
	  ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
	make -f checks.make html_check1 FILE=$@
#----
listasc_check:
	grep "^%o" jcat25.txt | grep -P "\(PARI\) is(Ok)?\(" \
	| cut -b4-10 \
	>     $@.tmp
	grep -P "Numbers \w+ such that|(Numbers|Primes|Squares|Cubes) (with|whose|for which|which)" asname.txt \
	| cut -b1-7 \
	>>    $@.tmp
	sort  $@.tmp | uniq -w7 > $@.1.tmp
	make seq LIST=$@.1.tmp
	$(DBAT) "SELECT s.aseqno, b.bfimax - b.bfimin, b.decindex, n.name \
	  FROM seq s, bfinfo b, asname n \
	  WHERE s.aseqno = b.aseqno \
	    AND b.aseqno = n.aseqno \
	    AND b.decindex < b.bfimax - 4 \
	    AND b.decindex > b.bfimin + 4 \
	  ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
	make -f checks.make html_check1 FILE=$@
#---------------------------
nxinc_check:
	$(DBAT) "SELECT b.aseqno, '[' || b.bfimin || '..' || b.bfimax || ']', b.message \
	  FROM bfinfo b \
	  WHERE b.message LIKE '%nxinc%' \
	  ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
	make -f checks.make html_check1 FILE=$@
#---------------------------
mma_check: # Terms in sequence differ from first terms in MMA Lin.Rec. call
	make -f makefile seq2 LIST=$(FISCHER)/mmacheck.tmp
	$(DBAT)  "SELECT a.aseqno, SUBSTR(a.data, 1, LENGTH(s.info)*2) as data, s.info \
		FROM  asdata a, seq2 s \
		WHERE a.aseqno = s.aseqno \
		  AND s.info <>        SUBSTR(a.data, 1, LENGTH(s.info)) \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
	make -f checks.make html_checks
#---------------------------
more_check: # Keyword "more" and more than 32 terms
	$(DBAT)  "SELECT a.aseqno, b.bfimax - b.bfimin + 1 AS nterms, a.keyword, n.name \
		FROM  asinfo a, bfinfo b, asname n \
		WHERE a.aseqno = b.aseqno \
		  AND b.aseqno = n.aseqno \
		  AND a.keyword LIKE '%more%' \
		  AND b.bfimax - b.bfimin + 1 > 32 \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--------------------------------
neof_check: # b-files with no LF behind the last term
	$(DBAT) "SELECT 'b' || substr(aseqno, 2, 6) || '.txt' FROM bfinfo WHERE message LIKE '%neof%' ORDER BY 1" \
	| sed -e "s/\r//" \
	> $@.1.tmp
	wc -l $@.1.tmp
noef2:
	grep -E "neof48|neof49|neof50|neof51|neof52|neof53|neof54|neof55|neof56|neof57" \
	rm -f $@.2.tmp
	cat  $@.1.tmp | xargs -l -i{} tail -vc32 bfile/{}.txt >> $@.2.tmp
	wc -l $@.*
#--------------------------------
nobase: # search for "IntegerDigits|sumdigits"
	grep -E "IntegerDigits|sumdigits" cat25.txt | cut -b 4-10 | sort | uniq \
	>       $@.txt
	head -4 $@.txt
	wc -l   $@.txt
nobase_check: # Sequences without keyword "base" mentioning "IntegerDigits|sumdigits"
	cat nobase.txt > x.tmp
	make seq LIST=x.tmp
	$(DBAT) "SELECT s.aseqno, n.name, i.keyword FROM seq s, asname n, asinfo i \
	WHERE s.aseqno = n.aseqno \
	  AND n.aseqno = i.aseqno \
	  AND NOT i.keyword LIKE '%base%' \
	  AND NOT i.keyword LIKE '%word%' \
	  AND NOT n.name    LIKE '%cellular automaton%' \
	ORDER BY 1" \
	>       $@.txt
	wc -l   $@.txt
#--------------------------------
nydone_check:
	$(DBAT) "SELECT n.aseqno, i.program, b.bfimax, n.info, i.keyword \
	  FROM nydone n, asinfo i, bfinfo b \
	  WHERE n.aseqno = i.aseqno \
	    AND i.aseqno = b.aseqno \
	  ORDER BY 1" \
	>       $@.txt
	wc -l   $@.txt
#--------------------------------
nydsdb_check:
	$(DBAT) "SELECT n.aseqno, s.si, s.mt, s.ix, n.info \
	  FROM nydone n, seqdb s \
	  WHERE n.aseqno = s.aseqno \
	    AND s.si <= '02' \
	  ORDER BY 1" \
	>       $@.txt
	wc -l   $@.txt
#--------------------------------
offset_check: # Sequence offset differs from first index in b-file and no draft
	$(DBAT) "SELECT a.aseqno, a.offset1, b.bfimin \
	    , substr(a.access, 1, 16) AS astime, substr(b.access, 1, 16) as bftime \
	    , a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.offset1 <> b.bfimin \
	      AND a.keyword NOT LIKE '%allocated%'  \
	      AND a.keyword NOT LIKE '%recycled%'  \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#	      AND a.aseqno NOT in (SELECT aseqno FROM draft) \
#
#--------------------------------
off_a0_check: # Sequence has offset > 0 and a(0)=...
	grep -E "a\(0\)" asname.txt \
	| cut -f1 \
	>     $@.tmp
	make seq  LIST=$@.tmp
	make seq2 LIST=off_a0_ok.man
	$(DBAT) "SELECT s.aseqno, i.offset1, b.bfimax, i.author, n.name, i.keyword \
	    FROM seq s, asinfo i, bfinfo b, asname n \
	    WHERE s.aseqno = i.aseqno \
	      AND i.aseqno = b.aseqno \
	      AND b.aseqno = n.aseqno \
	      AND i.offset1 > 0 \
	      AND s.aseqno NOT IN (SELECT aseqno FROM seq2) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#---------------------------
order_check:
	cp -v ../lrindex/order_only.tmp $@.txt
	wc -l $@.txt
#----
pass_check: # Check whether test result counts equals number of terms in b-files
	$(DBAT) "SELECT s.aseqno, s.info as testcount, b.bfimax - b.bfimin  + 1 AS bfcount \
	    FROM seq2 s, bfinfo b \
	    WHERE s.aseqno = b.aseqno \
	      AND CAST(s.info AS INT) <> b.bfimax - b.bfimin + 1 \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#----
radata_check: # Synthesized and term list is longer than $(RALEN) characters - candidate for b-file
	$(DBAT) "SELECT a.aseqno, LENGTH(d.data) AS len, a.author \
		, substr(a.access, 1, 16) AS oeis_time	  \
		FROM asinfo a, asdata d \
	    LEFT JOIN bfinfo b ON d.aseqno = b.aseqno \
	    WHERE a.aseqno = d.aseqno \
	      AND LENGTH(d.data) > $(RALEN) \
	      AND b.message LIKE 'synth' \
	    ORDER BY 2 DESC, 3 " \
	>     $@.txt
	wc -l $@.txt
rbdata_check: # b-file and term list is longer than $(RALEN) characters - candidate for truncation
	$(DBAT) "SELECT a.aseqno, LENGTH(d.data) AS len, a.author \
		, substr(a.access, 1, 16) AS oeis_time	  \
		, b.bfimax \
		FROM asinfo a, asdata d \
	    LEFT JOIN bfinfo b ON d.aseqno = b.aseqno \
	    WHERE a.aseqno = d.aseqno \
	      AND LENGTH(d.data) > $(RALEN) \
	      AND b.message NOT LIKE 'synth' \
	    ORDER BY 2 DESC, 3 " \
	>     $@.txt
	wc -l $@.txt
#-------------------------
sean402_check: # errors in generated joeis Lin.Rec. classes 
	echo aseqno	mma_call                  > $@.txt
	cat $(FISCHER)/errors-2019-04-02.txt >> $@.txt	
	make -f checks.make html_checks
#--------------------------------
sign_check: signa_check signb_check
signa_check: # Sequence has keyword <em>sign</em> and no negative terms in b-file
	$(DBAT)  "SELECT a.aseqno, a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND b.bfimin >= 0 \
	      AND  a.keyword NOT LIKE '%dead%' \
	      AND (a.keyword     LIKE '%sign%' AND b.message NOT LIKE '%sign%' \
	      ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--
signb_check: # Sequence has no keyword <em>sign</em> and b-file has negative terms
	$(DBAT)  "SELECT a.aseqno, a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND b.bfimin >= 0 \
	      AND  a.keyword NOT LIKE '%dead%' \
	      AND (a.keyword NOT LIKE '%sign%' AND b.message     LIKE '%sign%' \
	      ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#---------------------------
synth_check: syntha_check synthb_check synthc_check synthd_check synthe_check synthf_check synthg_check
#--
syntha_check: # Sequence (no draft) does not link to a b-file, but there is one in <em>bfilelist</em>
	$(DBAT) "SELECT a.aseqno \
		, a.keyword \
		, substr(a.access , 1, 16) AS oeis_time \
		, substr(d.created, 1, 16) AS bfdir_time \
		, d.filesize \
	    FROM asinfo a, bfdir d \
	    WHERE a.aseqno = d.aseqno \
	      AND a.keyword      LIKE '%synth%' \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#	      AND a.aseqno NOT IN (SELECT aseqno FROM draft  ) \
#--
synthb_check: # Sequence links to a b-file which is not in <em>bfilelist</em>
	$(DBAT) "SELECT a.aseqno \
		, substr(a.access, 1, 16) AS access \
		, a.keyword \
	    FROM asinfo a \
	    WHERE a.keyword  NOT LIKE '%synth%' \
	      AND a.aseqno   NOT IN (SELECT aseqno FROM bfdir b) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--
synthc_check: # Local b-file is not <em>synth</em>, but it is not in <em>bfilelist</em>
# our file is not synth and it is not in bfdir
	$(DBAT) "SELECT b.aseqno \
		, substr(b.access, 1, 16) AS access \
		, b.filesize \
		, b.message \
	    FROM bfinfo b \
	    WHERE b.message  NOT LIKE '%synth%' \
	      AND b.aseqno   NOT IN (SELECT d.aseqno FROM bfdir d) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--
synthd_check: # Local b-file is <em>synth</em>, but it is in <em>bfilelist</em>
	$(DBAT) "SELECT d.aseqno \
		, substr(d.created, 1, 16) AS oeis_time, substr(b.access, 1, 16) AS local_time\
		, d.filesize, b.filesize \
		, b.message \
	    FROM bfdir d, bfinfo b \
	    WHERE d.aseqno   = b.aseqno \
	      AND b.message      LIKE '%synth%' \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#	      AND d.aseqno NOT IN (SELECT aseqno FROM draft  ) \
#--
synthe_check: # Sequence without local synthesized b-file and no entry in <em>bfilelist</em>
	$(DBAT) "SELECT a.aseqno, a.offset1 \
		, substr(a.access, 1, 16) AS astime \
		, a.keyword \
	    FROM asinfo a \
	    WHERE a.keyword LIKE '%synth%' \
	      AND a.aseqno   NOT IN (SELECT d.aseqno FROM bfdir  d) \
	      AND a.aseqno   NOT IN (SELECT b.aseqno FROM bfinfo b) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#	      AND a.aseqno NOT IN (SELECT aseqno FROM draft  ) \
#--------
synthf: synthf1 synthf2
synthf1:
	$(DBAT) -x "SELECT 'bfile/b' || SUBSTR(aseqno, 2, 6) || '.txt' \
	    FROM bfdir \
	    ORDER BY 1" \
	| sed -e "s/\r//" \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
synthf2:
	rm -f $@.tmp
	cat synthf1.txt | xargs -l head -n1 >> $@.tmp || :
#--
synthf_check: # b-files with fake comment "synthesized from ..."
	grep -i synthesi synthf2.tmp | cut -b3- \
	| grep -E "^A[0-9]" | sed -e "s/ /\t/" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	make -f makefile seq LIST=$@.tmp
	$(DBAT) "SELECT s.aseqno, a.keyword, SUBSTR(a.access, 1, 10) AS Date \
	  FROM  seq s, asinfo a \
		WHERE s.aseqno = a.aseqno \
		  AND s.aseqno IN (SELECT aseqno FROM BFDIR) \
		  AND a.keyword NOT LIKE '%synth%' \
		ORDER BY 1 " \
	| sed -e "s/\r//" > $@.txt
	head -n 4 $@.txt
	wc -l $@.txt
#----
synthg_check: # "synth" and JSON is newer than b-file
	$(DBAT) "SELECT a.aseqno \
		, substr(a.access, 1, 16) AS ajson_time \
		, substr(b.access, 1, 16) AS bfile_time \
		, b.filesize, b.bfimin || ':' || b.bfimax \
		, a.keyword \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.keyword      LIKE '%synth%' \
	      AND a.access > b.access \
	      AND a.aseqno NOT IN (SELECT aseqno FROM bfdir) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#-----------------------------
terms_check: # The first few terms differ from the b-file, and that is not synthesized and no draft
	$(DBAT) "SELECT a.aseqno, a.terms AS asterms, b.terms AS bfterms\
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.terms <> b.terms \
	      AND b.message NOT LIKE '%synth%' \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#	      AND a.aseqno  NOT in (SELECT aseqno FROM draft) \
#-----------------------------
uncat_check: # Whether the cat25 file contains newer sequences
	make -f makefile seq2 LIST=uncat_date1.tmp
	$(DBAT) "SELECT a.aseqno, SUBSTR(a.access, 1, 10) AS ajson_date, s.info AS cat25_date \
	    FROM asinfo a, seq2 s \
	    WHERE a.aseqno = s.aseqno \
	      AND SUBSTR(a.access, 1, 7) < SUBSTR(s.info,1, 7) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#---------------------------------------
# unused:
#--------
WWW_TEO=../bfcheck/www_teo
bfdel:
	cat \
	$(WWW_TEO)/gf1.txt \
	$(WWW_TEO)/gf2.txt \
	$(WWW_TEO)/gf5.txt \
	$(WWW_TEO)/gf9.txt \
	> $@.tmp
	make -f makefile seq LIST=$@.tmp
bfdel_check: bfdel
	make -f checks.make bfdela_check bfdelb_check
bfdela_check:
	$(DBAT) "SELECT s.aseqno, substr(a.access, 1, 16), a.keyword \
		FROM  seq s, asinfo a \
		WHERE s.aseqno   =  a.aseqno \
	 	  AND a.keyword NOT LIKE '%synth%' \
		ORDER BY 1" \
	> $@.txt
	wc -l $@.txt
bfdelb_check:
	$(DBAT) "SELECT s.aseqno, substr(b.access, 1, 16), b.message \
		FROM  seq s, bfinfo b \
		WHERE s.aseqno   =  b.aseqno \
	 	  AND b.message NOT LIKE '%synth%' \
		ORDER BY 1" \
	> $@.txt
	wc -l $@.txt
#-------------------
bfmess_stat:
	$(DBAT) -x "select message from bfinfo" \
	| sed -e "s/[0-9]//g" > $@.1.tmp 
	grep "neof" $@.1.tmp | wc -l
	sort $@.1.tmp | uniq -c > $@.txt
#----
michel_tabl:
	$(DBAT) "SELECT i.aseqno, i.termno, i.offset1, b.bfimin, b.bfimax \
	  , CASE WHEN COALESCE(b.bfimax, 0) - COALESCE(b.bfimin, 0) + 1 \
	  > termno THEN '<bf' ELSE '   ' END \
	  , i.keyword, i.author \
	  FROM asinfo i LEFT JOIN bfinfo b ON i.aseqno = b.aseqno\
	  WHERE keyword LIKE '%tabl%' \
	    AND termno NOT in (1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66\
	    , 78, 91, 105, 120, 136, 153, 171) \
	  ORDER BY 1" > $@.txt
	head -n32 $@.txt
	wc -l     $@.txt
	sort -n  -k2.1 $@.txt > michel_sort.txt
	grep "more"    $@.txt > michel_more.txt
	wc -l michel_more.txt
	grep "fini"    $@.txt > michel_fini.txt
	wc -l michel_fini.txt
	zip michel.`date +%Y-%m-%d.%H_%M`.zip michel*.txt
michel_tabl_name:
	$(DBAT) "SELECT i.aseqno, i.termno, n.name, i.author \
	  FROM asinfo i LEFT JOIN asname n ON i.aseqno = n.aseqno\
	  WHERE keyword LIKE '%tabl%' \
	    AND termno NOT in (1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66\
	    , 78, 91, 105, 120, 136, 153, 171) \
	  ORDER BY 1" \
	>         $@.txt
	head -n32 $@.txt
	wc -l     $@.txt
	zip $@.`date +%Y-%m-%d.%H_%M`.zip $@.txt
#----
