#!make

# OEIS-mat/linrec - linear recurrences and index
# @(#) $Id$
# 2019-03-29: revisited for joeis
# 2019-02-19: HTMLIZE
# 2019-01-22: unpacking from ../dumps
# 2019-01-17: Georg Fischer
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMATH=java -cp  $(GITS)/ramath/dist/ramath.jar org.teherba.ramath.symbolic.PolyFraction
SLEEP=16
DUMPS=../dumps
HEAD=8
PULL=../pull
COMMON=../common
D=0
G=n
SORTALLN=sort       -k1$(G)  -k2$(G)  -k3$(G)  -k4$(G)  -k5$(G)  -k6$(G)  -k7$(G)  -k8$(G)  -k9$(G) \
	      -k10$(G) -k11$(G) -k12$(G) -k13$(G) -k14$(G) -k15$(G) -k16$(G) -k17$(G) -k18$(G) -k19$(G) \
	      -k20$(G) -k21$(G) -k22$(G) -k23$(G) -k24$(G) -k25$(G) -k26$(G) -k27$(G) -k28$(G) -k29$(G) \
	      -k30$(G) -k31$(G) -k32$(G) -k33$(G) -k34$(G) -k35$(G) -k36$(G) -k37$(G) -k38$(G) -k39$(G) \
	      -k40$(G) -k41$(G) -k42$(G) -k43$(G) -k44$(G) -k45$(G) -k46$(G) -k47$(G) -k48$(G) -k49$(G) \
	      -k30$(G) -k31$(G) -k32$(G) -k33$(G) -k34$(G) -k35$(G) -k36$(G) -k37$(G) -k38$(G) -k39$(G) \
	      -k40$(G) -k41$(G) -k42$(G) -k43$(G) -k44$(G) -k45$(G) -k46$(G) -k47$(G) -k48$(G) -k49$(G) \
	      -k50$(G) -k51$(G) -k52$(G) -k53$(G) -k54$(G) -k55$(G) -k56$(G) -k57$(G) -k58$(G) -k59$(G) \
	      -k60$(G) -k61$(G) -k62$(G) -k63$(G) -k64$(G) -k65$(G) -k66$(G) -k67$(G) -k68$(G) -k69$(G) 
all:
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#--------------------
gf1:
	grep -E "F A[0-9]* G\. *f\." $(COMMON)/cat25.txt  > gf1.tmp
	wc -l gf1.tmp
gf2:
	cut -b4- gf1.tmp | sed -e "s/ /\t/" | sort | uniq \
	| sed -e "s/\.//g" -e "s/G *f: *//" \
	| grep -vE "A[^0-9]" \
	| grep -vE "[B-Z]" \
	| grep -vE "[a-zA-Z][a-zA-Z]" \
	| grep -vE "^.......*[0-9][0-9][0-9][0-9]" \
	| grep -E "\/" \
	>        gf2.tmp
	head -n4 gf2.tmp
	wc -l    gf2.tmp
	cut -b 1-7 gf2.tmp | sort | uniq -c | grep -v " 1 " | cut -b 9- > gf2.dupl.tmp
	grep -vf gf2.dupl.tmp gf2.tmp > gf2.single.tmp
gf3:
	make -f $(COMMON)/makefile seq2 LIST=gf2.single.tmp
	$(DBAT) "SELECT aseqno, info \
		FROM seq2 \
		WHERE aseqno NOT IN (SELECT aseqno from joeis) \
		ORDER BY 1 " \
	>        gf3.tmp
	head -n4 gf3.tmp
	wc -l    gf3.tmp
#----------------
# Generating functions from cat25 file
catgf: catgf0 catgf1 catgf2
# %F A000032 G.f.: (2 - x)/(1 - x - x^2).
# 1234567890123456789
catgf0:
	perl extract_catgf.pl -d 0 $(COMMON)/cat25.txt \
	>       $@.tmp
	head -4 $@.tmp
	wc -l   $@.tmp
catgf1:
	$(RAMATH) -f   catgf0.tmp > $@.tmp
catgf2:
	grep -E "orgf" catgf1.tmp \
	| grep -vP '\d{16}' \
	>       $@.txt
	tail -4 $@.txt
	wc -l   $@.txt
catgf3:
	grep -vE "^#" catgf0.tmp | sed -e "s/fract/x/" \
	>       $@.tmp
	head -4 $@.tmp
	wc -l   $@.tmp
catgf4:
	cat catgf0.tmp | sed -e "s/fract/x/" | grep -E "sqrt" \
	>       $@.tmp
	head -4 $@.tmp
	wc -l   $@.tmp
#	| grep -E "Conjecture:" 
gfmatconj:
	grep Mathar $(COMMON)/cat25.txt \
	| grep -E '^%F ' \
	| grep -vi Sum  \
	| grep -E "a\(n\)" \
	| grep -E "= *0" \
	>       $@.tmp
	head -4 $@.tmp
	wc -l   $@.tmp
recur:
	perl extract_recur.pl $(COMMON)/cat25.txt \
	>       $@.tmp
	head -4 $@.tmp
	wc -l   $@.tmp 
#--------
elu1:
	grep "def " generatingFunctions.txt \
	| cut -b5-11 \
	>		$@.tmp
	wc -l   $@.tmp
	make -f $(COMMON)/makefile seq LIST=$@.tmp
	$(DBAT) "SELECT aseqno \
		FROM seq \
		WHERE aseqno NOT IN (SELECT aseqno from joeis) \
		ORDER BY 1 " \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
elu2:
	perl extract_sage.pl generatingFunctions.txt \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
elu3:
	$(RAMATH) -n 16 -f elu2.tmp \
	>        $@.tmp
elu4:
	grep -E "coef" elu3.tmp | sed -e "s/coef\t16\t\[//" -e "s/\]//" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	make -f $(COMMON)/makefile seq2 LIST=$@.tmp
	$(DBAT) -x "SELECT s.aseqno, s.info \
		FROM  seq2 s, asdata d \
		WHERE s.aseqno = d.aseqno \
		  AND s.info   = SUBSTR(d.data, 1, LENGTH(s.info)) \
		ORDER BY 1" \
	> 		 $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
elu5:
	$(DBAT) -x "(SELECT s.aseqno, 'coef', s.info \
		FROM  seq2 s, asdata d \
		WHERE s.aseqno = d.aseqno \
		  AND s.info   <> SUBSTR(d.data, 1, LENGTH(s.info)) \
		  AND d.data LIKE '%' || s.info || '%') \
	    UNION   (SELECT s.aseqno, 'term', d.data \
		FROM  seq2 s, asdata d \
		WHERE s.aseqno = d.aseqno \
		  AND s.info   <> SUBSTR(d.data, 1, LENGTH(s.info)) \
		  AND d.data LIKE '%' || s.info || '%') \
		ORDER BY 1, 2" \
	> 		 $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
gf_check:
	$(DBAT) -x "(SELECT s.aseqno, 'coef', s.info \
		FROM  seq2 s, asdata d \
		WHERE s.aseqno = d.aseqno \
		  AND d.data NOT LIKE '%' || SUBSTR(s.info, 31, 32) || '%') \
	    UNION   (SELECT s.aseqno, 'term', d.data \
		FROM  seq2 s, asdata d \
		WHERE s.aseqno = d.aseqno \
		  AND d.data NOT LIKE '%' || SUBSTR(s.info, 31, 32) || '%') \
		ORDER BY 1, 2" \
	> 		 $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
#----
cox: coxgn1 coxf1 coxf2
coxgn1: # get Coxeter sequence names
	# rm -f coxg*.tmp
	grep "Number of reduced words of length n in Coxeter group " $(COMMON)/names \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
coxf1: # get coxG calls from 'names' subset
	perl -ne 'm{^(A\d+)\D+(\d+)\D+(\d+)\D+(\d+)}; print "$$1\tcoxf\t$$4\t$$2\n"' \
	coxgn1.tmp | sort > $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	$(RAMATH) -n 24 -f $@.tmp > $@.txt
	make -f $(COMMON)/makefile seq2 LIST=$@.txt
coxf2:
	$(DBAT) -x "(SELECT s.aseqno, 'coxf', s.info \
		FROM  seq2 s, asdata d \
		WHERE s.aseqno = d.aseqno \
		  AND d.data NOT LIKE s.info || '%' \
		  AND s.info NOT LIKE d.data || '%' \
	    ) UNION (SELECT s.aseqno, 'term', d.data \
		FROM  seq2 s, asdata d \
		WHERE s.aseqno = d.aseqno \
		  AND d.data NOT LIKE s.info || '%' \
		  AND s.info NOT LIKE d.data || '%' \
		) ORDER BY 1, 2" \
	> 	  	 $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
#----
checks:          \
	lr_checks    \
	eval_checks  \
	html_checks
eval_checks:
	cat *check.t* \
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
#----
html_checks:
	perl ../bfcheck/tsv_html.pl -m init eval_checks.lst >  check_index.html
	ls -1 *_check.txt | sed -e "s/.txt//" \
	| xargs -l -i{} make -s html_check1 FILE={}
	perl ../bfcheck/tsv_html.pl -m term eval_checks.lst >> check_index.html
html_check1:
	perl ../bfcheck/tsv_html.pl -m var $(FILE).txt > $(FILE).html
deploy_checks:
	scp *check*.html gfis@teherba.org:/var/www/html/teherba.org/OEIS-mat/common/
#----------------
seq: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/seq.create.sql
	cut -b1-7 $(LIST) | grep -E "^A" | $(DBAT) -m csv -r seq
	$(DBAT) -n seq
delseq: seq # parameters: $(TAB) $(LIST)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
#----------------------
flinrec:
	perl flinrec.pl $(COMMON)/stripped | tee $@.tmp
linhrec1:
	perl linhrec.pl $(COMMON)/stripped 
linhrec:
	cp -v ../../linhrec/dist/linhrec.jar .
	java -jar linhrec.jar -f $(COMMON)/stripped
#======================================================
linrec: lrlink lrindx lrload
# linrec_link linrec_mmacall linrec_wget linrec_index
#--
lrlink: lrlink2 lrlink3 lrlink_patch lrlord_patch lrlink_check
lrlink0:
	find $(COMMON)/ajson -iname "*.json" | sort | xargs -l grep -H \
	"Index entries for linear recurrence" > lrlink1.tmp || :
	head -n4 lrlink1.tmp
	wc   -l  lrlink1.tmp
lrlink2:
	perl extract_linrec.pl -m link          lrlink1.tmp \
	| $(SORTALLN) \
	| uniq \
	| grep -vE "01174[05]" \
	> lrlink2.tmp
	wc -l lrlink*.tmp
lrlink3:
	perl extract_linrec.pl -m lrlink > lrlink.create.sql
	$(DBAT) -f                         lrlink.create.sql
	$(DBAT) -m csv -s "\t" -r lrlink < lrlink2.tmp
	$(DBAT) -n lrlink
	$(DBAT) -4 lrlink
#--
lrlink_patch:
	$(DBAT) -n lrlink
	$(DBAT) -v "DELETE FROM lrlink where lorder <> 88888888 AND lorder >= 2800;"
	$(DBAT) -v "UPDATE lrlink SET lorder = sigorder WHERE lorder = 88888888;"
	$(DBAT) -n lrlink
#----
lrlink_check: # Lin. rec. link, but no index entry
	$(DBAT) "SELECT 'A' || seqno, lorder, compsig, sigorder, signature, '#' \
	FROM lrlink \
	WHERE seqno NOT IN (SELECT seqno FROM lrindx) \
	  AND lorder < 2800 \
	ORDER by 1" \
	| sed -e "s/\r//" \
	>       $@.txt
	head -4 $@.txt	
	wc -l   $@.txt
#-------------
lrmmac: lrmmac1 lrmmac2 lrmmac3
lrmmac1: # extract MMA LinearRecurrence calls from ./ajson 
	rm -f $@.tmp
	find $(COMMON)/ajson -iname "*.json" | sort | xargs -l grep -H \
	"LinearRecurrence" \
	>> $@.tmp || :
lrmmac2: # extract parameters, eventually modified by Join parameters
	perl extract_linrec.pl -m mmac lrmmac1.tmp > $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
lrmmac3: # create table lrmmac
	perl extract_linrec.pl -m lrlink 9678kk\
	| sed -e "s/lrlink/lrmmac/g" | tee lrmmac.create.sql
	$(DBAT) -f                         lrmmac.create.sql
	$(DBAT) -m csv -s "\t" -r          lrmmac < lrmmac2.tmp
	$(DBAT) -4 lrmmac
	$(DBAT) -n lrmmac
#-------------
mmac_joeis:
	$(DBAT) "SELECT 'A' || seqno, signature, initerms, termno FROM lrmmac \
		WHERE 'A' || seqno NOT IN \
		(SELECT aseqno FROM joeis WHERE superclass LIKE 'Linear%') \
		ORDER BY 1" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
mmac_err02:
	make seq LIST=errors-2019-04-02.txt
	$(DBAT) -x "SELECT 'A' || seqno \
	  , (CASE WHEN sigorder = termno THEN 'LinearRecurrence2' ELSE 'LinearRecurrence3' END) \
	  , signature, initerms, termno FROM lrmmac \
		WHERE 'A' || seqno IN (SELECT aseqno FROM seq) \
		ORDER BY 1" \
		>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#---------------
lrlord_check: # Compare orders in lin. rec. links
	# Link was to wrong order.
	$(DBAT) "SELECT 'A' || seqno AS aseqno, lorder, sigorder, signature \
	FROM lrlink \
	WHERE lorder    <> sigorder \
	  AND sigorder  <> 0 \
	  AND signature <> '88888888' \
	ORDER by 1" \
	| sed -e "s/\r//" \
	>       $@.txt
	head -4 $@.txt	
	wc -l   $@.txt
lrlord_patch:
	$(DBAT) -v "UPDATE lrlink SET sigorder = lorder WHERE seqno = '322829';"
	make seq LIST=lrlord_check.man
	$(DBAT) -v "UPDATE lrlink SET lorder = sigorder WHERE 'A' || seqno IN \
		(SELECT aseqno FROM seq);"
lriord_check: # Compare orders in lin. rec. index
	$(DBAT) "SELECT 'A' || seqno AS aseqno, lorder, sigorder, compsig, signature \
	FROM lrindx \
	WHERE lorder <> sigorder \
	ORDER by 1" \
	| sed -e "s/\r//" \
	>       $@.txt
	head -4 $@.txt	
	wc -l   $@.txt
#----
lrlink_insert: lrlink_insert1 lrlink_insert2
lrlink_insert1:
	$(DBAT) -x "SELECT lorder, compsig, seqno, sigorder, signature, '#<strong>' \
	FROM lrlink \
	WHERE seqno NOT IN (SELECT seqno FROM lrindx) \
	  AND lorder < 2800 \
	ORDER by 1" \
	| sed -e "s/\r//" \
	>       $@.txt
	head -4 $@.txt	
	wc -l   $@.txt
lrlink_insert2:
	$(DBAT) -n lrindx
	$(DBAT) -m csv -s "\t" -r lrindx < lrlink_insert1.txt
	$(DBAT) -4 lrindx
	$(DBAT) -n lrindx
#-----
lrperiod:
	find $(COMMON)/ajson -iname "*.json" | sort | xargs -l grep -H \
	"Index entries for periodic sequences with large period" \
	> $@.tmp
#----------------------
lrindx: lrindx1 lrindx2 lrindx3 lrindx4 lrindx5
lrindx0:
	wget "https://oeis.org/wiki/Index_to_OEIS:_Section_Rec?action=raw" -O lrindx.raw
lrindx1:
	# sed -e "s/:signature */:/" -e "s/=====/====/g" lrindx.raw \
	# | grep -vE "^ *$$" \
	cat lrindx.raw \
	> lrindx.wiki
	echo >> lrindx.wiki # append linefeed
	# diff -y --suppress-common-lines lrindx.raw lrindx.wiki || :
	perl extract_linrec.pl -d $(D) -m index -f lrindx.spec.tmp  lrindx.wiki \
			> lrindx.tmp
lrindx2:
	perl extract_linrec.pl -d $(D) -m lrindx \
			>  lrindx.create.sql
	$(DBAT) -f lrindx.create.sql
	$(DBAT) -m csv -s "\t" -r lrindx <  lrindx.tmp
	$(DBAT) -n                lrindx
	$(DBAT) -4 lrindx
lrindx3:
	$(DBAT) -x "SELECT lorder, compsig, seqno, sigorder, signature, comment \
		FROM lrindx " \
	| sed -e "s/\r//" \
	| $(SORTALLN) \
	| perl -ne "s/\'\'/\'/g; print;" \
	> lrindx.sort.tmp
	# diff -wy --suppress-common-lines lrindx.tmp lrindx.sort.tmp || :  
	# diff -C0 -w                      lrindx.tmp lrindx.sort.tmp || :
lrindx4:
	perl extract_linrec.pl -d $(D) -m wrindx -f lrindx.spec.tmp lrindx.sort.tmp \
	> lrindx.new.tmp
	# | grep -vE "^ *$$"
	tail -2 lrindx.new.tmp | hexdump -C
	wc -l lrindx.new.tmp 
lrindx5:
	wc -l      lrindx.wiki lrindx.new.tmp 
	diff -C0                          lrindx.wiki lrindx.new.tmp > lrindx.diffc.tmp || :
	diff -wy --suppress-common-lines  lrindx.wiki lrindx.new.tmp > lrindx.diffy.tmp || :
#-------------------------------------
lrtest: lrtest0 lrtest1 lrindx2 lrindx3 lrindx4 lrtest5
lrtest0:
lrtest1:
	perl extract_linrec.pl -d $(D) -m index  -f lrindx.spec.tmp  lrtest.man \
	          > lrindx.tmp
lrtest5:
	head -n 999         lrindx.new.tmp 
	diff -C2   lrtest.man lrindx.new.tmp > lrindx.diffc.tmp || :
	diff -wy   lrtest.man lrindx.new.tmp                    || :
#-------------------------------	
linrec_xtract:
	perl extract_linrec.pl -m xtract  linhrec12.txt > $@.txt
linrec_eval:
	cat linrec_*.txt \
	| gawk -e '{print $$1 "\t" $$2 "\t" $$3 "\t" $$4}' \
	| sort | uniq \
	| grep -v "113300	mmacall	3	1,1,1" \
	>     all_linrec.tmp
	wc -l all_linrec.tmp
#-------------
lr_checks: lrlink_check lrindex_check lriord_check lrlord_check
# lrsign_check 
#--	
#--	
lrindex_check: # Lin. rec. in index, but no link -&gt; delete index entry
	$(DBAT) "SELECT a.seqno, a.lorder, a.signature as Index_Signature \
	FROM lrindx a \
	WHERE a.seqno NOT IN (SELECT seqno FROM lrlink) \
	  AND (SELECT s.keyword FROM asinfo s WHERE s.aseqno = 'A' || a.seqno) NOT LIKE '%dead%' \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#--	
lrsign_check: # Differences in lin. rec. signatures
	$(DBAT) "SELECT 'A' || a.seqno, a.lorder \
	    , b.mode \
		, a.signature AS Index_Signature \
		, b.signature AS Link_Signature \
	FROM lrindx a, lrlink b \
	WHERE a.seqno     =  b.seqno \
	  AND a.compsig   <> b.compsig \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#--	
lrstrip_check: # Whether there are not sufficiently many initial terms in file stripped
	$(DBAT) "SELECT 'A' || i.seqno AS A_number, i.sigorder, a.termno, i.signature \
	FROM lrindx i, asinfo a \
	WHERE 'A' || i.seqno = a.aseqno \
	  AND i.sigorder    >= a.termno \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#--
lrmorest_check: # Whether there are more initial terms in file stripped
	$(DBAT) "SELECT 'A' || i.seqno AS A_number, i.sigorder, a.termno, i.signature \
	FROM lrindx i, asinfo a \
	WHERE 'A' || i.seqno  = a.aseqno \
	  AND i.sigorder + 1 <= a.termno \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
dummy2:
	echo " \
	  AND a.aseqno NOT IN (SELECT aseqno FROM joeis) \
	"	
#---------------------
lrsigadd_check: # Additional signatures in links
	$(DBAT) "SELECT DISTINCT a.signature \
	FROM lrlink a LEFT JOIN lrindx b ON a.signature = b.signature
	WHERE a.signature NOT IN (SELECT DISTINCT b.signature FROM lrindx b) \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#---------------------
lrsigadd:
	$(DBAT) "SELECT DISTINCT a.lorder \
		, a.signature AS asig \
	FROM linrec a \
	WHERE a.mode      = 'link' \
	  AND a.signature NOT IN \
	    ( SELECT DISTINCT b.signature \
	      FROM linrec b \
	      WHERE b.mode      = 'index'\
	    ) \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#
lrordadd:
	$(DBAT) "SELECT DISTINCT a.lorder \
	FROM linrec a \
	WHERE a.mode      = 'link' \
	  AND a.lorder NOT IN \
	    ( SELECT DISTINCT b.lorder \
	      FROM linrec b \
	      WHERE b.mode      = 'index'\
	    ) \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#---------------------
morix:
	$(DBAT) "SELECT DISTINCT a.aseqno, a.keyword, a.offset1, b.bfimax, i.signature \
	FROM lrindx i, asinfo a \
	LEFT JOIN bfinfo b ON a.aseqno = b.aseqno \
	WHERE a.aseqno = 'A' || i.seqno \
	  AND a.keyword like '%more%' \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
morln:
	$(DBAT) "SELECT DISTINCT a.aseqno, a.keyword, a.offset1, b.bfimax, l.signature \
	FROM lrlink l, asinfo a \
	LEFT JOIN bfinfo b ON a.aseqno = b.aseqno \
	WHERE a.aseqno = 'A' || l.seqno \
	  AND a.keyword like '%more%' \
	ORDER by 1" \
	>     $@.txt	
	wc -l $@.txt	
#---------------------------
form:
	perl extract_linrec.pl -m form form1.tmp \
	> $@.tmp
	wc -l $@.tmp 
#-------------------

	
	