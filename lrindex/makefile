#!make

# OEIS-mat/lrindex - recreate OEIS wiki page: "Index of linear recurrences ..."
# @(#) $Id$
# 2019-06-04: moved from ../linrec
# 2019-03-29: revisited for joeis
# 2019-02-19: HTMLIZE
# 2019-01-22: unpacking from ../dumps
# 2019-01-17: Georg Fischer
#---------------------------------
GITS=../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
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
#======================================================
all:
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#======================================================
lrindex: lrlink lrindx 
#--
lrlink_prep: # extract all links (faster on Linux)
	find $(COMMON)/ajson -iname "*.json" | sort | xargs -l grep -iH \
	"Index entries for linear recurrence" > lrlink1.tmp || :
	head -n4 lrlink1.tmp
	wc   -l  lrlink1.tmp
#----
lrlink: lrlink2 lrlink3 lrlink_patch lrlord_patch lrlink_check
lrlink2: 
	perl extract_lrindex.pl -m link         lrlink1.tmp \
	| $(SORTALLN) \
	| uniq \
	| grep -vE "01174[05]" \
	> lrlink2.tmp
	wc -l lrlink*.tmp
lrlink3:
	perl extract_lrindex.pl -m lrlink > lrlink.create.sql
	$(DBAT) -f                          lrlink.create.sql
	$(DBAT) -m csv -s "\t" -r lrlink <  lrlink2.tmp
	$(DBAT) -n lrlink
	$(DBAT) -4 lrlink
#--
lrlink_patch:
	$(DBAT) -n lrlink
	$(DBAT) -v "UPDATE lrlink SET aseqno = 'A' || seqno;"
	$(DBAT) -v "DELETE FROM lrlink where lorder <> 88888888 AND lorder >= 2800;"
	$(DBAT) -v "UPDATE lrlink SET lorder = sigorder WHERE lorder = 88888888;"
	$(DBAT) -n lrlink
#----
lrlink_check: # Lin. rec. link, but no index entry
	$(DBAT) "SELECT aseqno, lorder, compsig, sigorder, signature, '#' \
	FROM lrlink \
	WHERE aseqno NOT IN (SELECT aseqno FROM lrindx) \
	  AND lorder < 2800 \
	ORDER by 1" \
	| sed -e "s/\r//" \
	>       $@.txt
	head -4 $@.txt	
	wc -l   $@.txt
#-------------
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
#--------
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
#----------------------
lrindx:      lrindx_pre lrlink_insert lrindx_post
lrindx_pre:  lrindx0 lrindx1 lrindx2 
lrindx_post: lrindx3 lrindx4 lrindx5
#----
lrindx0:
	rm -f lrindx.raw
	wget "https://oeis.org/wiki/Index_to_OEIS:_Section_Rec?action=raw" -O lrindx.raw
lrindx1:
	cat lrindx.raw \
	| perl -pe 's/\<\/?strong\>//g;' \
	> lrindx.wiki
	grep strong lrindx.wiki || :
	echo >> lrindx.wiki # append linefeed
	# diff -y --suppress-common-lines lrindx.raw lrindx.wiki || :
	perl extract_lrindex.pl -d $(D) -m index -f lrindx.spec.tmp  lrindx.wiki \
			> lrindx.tmp
lrindx2:
	perl extract_lrindex.pl -d $(D) -m lrindx > lrindx.create.sql
	$(DBAT) -f                                  lrindx.create.sql
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
	perl extract_lrindex.pl -d $(D) -m wrindx -f lrindx.spec.tmp lrindx.sort.tmp \
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
	perl extract_lrindex.pl -d $(D) -m index  -f lrindx.spec.tmp  lrtest.man \
	          > lrindx.tmp
lrtest5:
	head -n 999         lrindx.new.tmp 
	diff -C2   lrtest.man lrindx.new.tmp > lrindx.diffc.tmp || :
	diff -wy   lrtest.man lrindx.new.tmp                    || :
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
seq: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/seq.create.sql
	cut -b1-7 $(LIST) | grep -E "^A" | $(DBAT) -m csv -r seq
	$(DBAT) -n seq
delseq: seq # parameters: $(TAB) $(LIST)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
#----------------
