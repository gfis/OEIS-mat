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
D=0
RALEN=350
#--------

all:
	# targets: 
help:
	grep -E "^[a-z]" checks.make
#================
# general targets

checks: \
			asdata_check \
			asdir_check  \
			asname_check \
			bad_check    \
			bfdir_check  \
			brol_check   \
			cons_check   \
			denom_check  \
			offset_check \
			radata_check \
			rbdata_check \
			sign_check   \
			synth_check  \
			terms_check  \
			eval_checks  \
			html_checks
#
#		bfdata_check \
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
	perl html_checks.pl -m checks.make $(FILE).txt > $(FILE).html
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
	| grep -v "allocated for " \
	| grep -E "[a-zB-Z]" \
	| cut -b 9- \
	| grep -vf $(PULL)/draft_load.tmp \
	>> $@.txt || :
	wc -l $@.txt
#----
bad_check: # Check b-files for bad format
	echo -e "A-Number\tbfimin\tbfimax\toffset2\tterms\ttail\tfilesize\tmaxlen\tMessage" > $@.txt
	grep -E "bad" $(COMMON)/bfinfo.txt \
	>>    $@.txt || :
	wc -l $@.txt
##----
bfdata_check: # Compare <em>stripped</em> file with terms extracted from local b-files
	grep -vE "^#" $(COMMON)/stripped | sed -e "s/ \,/\t/" -e "s/,$$//"  \
	> x.tmp
	echo -e "A-Number\tTerms" > $@.txt
	sort x.tmp bfdata.txt | uniq -c | grep -vE "^ +2 +" \
	| grep -E "," \
	| cut -b 9- \
	| perl comp_terms.pl \
	| grep -vf $(COMMON)/draft_load.tmp \
	>> $@.txt || :
	wc -l $@.txt
#----
bfdir_check: # Compare <em>bfilelist</em> with local b-file sizes (maybe for draft)
	$(DBAT) "SELECT d.aseqno \
		, substr(d.created, 1, 16) AS oeis_time, substr(b.access, 1, 16) as local_time \
		, d.filesize AS oeis_size,  b.filesize AS local_size, b.message \
		FROM  bfdir d LEFT JOIN bfinfo b ON d.aseqno = b.aseqno  \
		WHERE d.filesize <> COALESCE(b.filesize, 1) \
		ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#   	        OR substr(d.created, 1, 10)  <> substr(b.access, 1, 10)s \
#		, d.filesize - b.filesize \
#	      AND d.aseqno NOT IN (SELECT aseqno FROM draft  ) 
#--------------------------------
brol_check: joeis_check
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
joeis_check: # jOEIS G.f. differences 2019-05-19
	echo "A_Number	Message	Expected	Computed" > $@.txt
	gawk -e '{ print $$1 "\t" $$2 "\t" substr($$3,0,8) "\t" substr($$4,0,32) "...\t" substr($$6,0,32) }' \
		computed.log \
	>>       $@.txt
	wc -l    $@.txt
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
	       			AND keyword NOT LIKE 'allocat%' \
	       			AND keyword NOT LIKE 'dead%' \
	       			AND keyword NOT LIKE 'recycled%' \
	          ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
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
offset_check: # Sequence offset differs from first index in b-file
	$(DBAT) "SELECT a.aseqno, a.offset1, b.bfimin \
		, substr(a.access, 1, 16) AS astime, substr(b.access, 1, 16) as bftime \
		, a.keyword, b.message \
	    FROM asinfo a, bfinfo b \
	    WHERE a.aseqno = b.aseqno \
	      AND a.offset1 <> b.bfimin \
	      AND a.keyword NOT LIKE '%allocated%'  \
	      AND a.keyword NOT LIKE '%recycled%'  \
	      AND a.aseqno NOT in (SELECT aseqno FROM draft) \
	    ORDER BY 1" \
	>     $@.txt
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
	      AND a.aseqno NOT IN (SELECT aseqno FROM draft  ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
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
	      AND d.aseqno NOT IN (SELECT aseqno FROM draft  ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
#--
synthe_check: # Sequence without local synthesized b-file and no entry in <em>bfilelist</em>
	$(DBAT) "SELECT a.aseqno, a.offset1 \
		, substr(a.access, 1, 16) AS astime \
		, a.keyword \
	    FROM asinfo a \
	    WHERE a.keyword LIKE '%synth%' \
	      AND a.aseqno   NOT IN (SELECT d.aseqno FROM bfdir  d) \
	      AND a.aseqno   NOT IN (SELECT b.aseqno FROM bfinfo b) \
	      AND a.aseqno NOT IN (SELECT aseqno FROM draft  ) \
	    ORDER BY 1" \
	>     $@.txt
	wc -l $@.txt
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
	      AND a.aseqno  NOT in (SELECT aseqno FROM draft) \
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
