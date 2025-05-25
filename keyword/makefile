#!make

# OEIS-mat: keyword-related queries
# @(#) $Id$
# 2025-05-22: again; *TP=76
# 2021-07-26: revisited
# 2019-01-13: Georg Fischer, copied from ../bfcheck
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
BASE=./keywordlist.txt
REMOTE=user@server.tld
COMMON=../common

all: 
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#----
keyw: keyw_select keyw_split keyw_stats deploy keyw_load
#
keyw_select: # select current keywords
	$(DBAT) -x "SELECT '%K', aseqno, keyword FROM asinfo;" \
	>        $(BASE)
	head -n4 $(BASE)
	wc -l    $(BASE)
#-----
keyw_split: # split into single keywords
	perl keyword.pl -a split $(BASE) > $@.tmp
	cut -d" " -f 2 $@.tmp | sort | uniq -c | tee $@.1.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#--
keyw_stats: # build a HTML list with the statistics
	perl keyword.pl -a html -kw keyw_split.tmp keyw_split.1.tmp \
	>        $@.html
	wc -l    $@.html
#--
deploy: # upload the keyword statistics 
	cp -v keyw_stats.html index.html
	echo set REMOTE=
	scp index.html $(REMOTE):/var/www/html/teherba.org/OEIS-mat/keyword/
#----------------
keyw_load: # load keywords into keyw
	sed -e "s/ /\t/" keyw_split.tmp \
	| sort | uniq \
	>        $@.tmp
	$(DBAT) -f keyw.create.sql
	$(DBAT) -r keyw < $@.tmp
	$(DBAT) -4 keyw
	$(DBAT) -n keyw
#----
checks: check_easy check_fini_full check_full check_nice check_sign check_tabf check_tabl
check_easy:
	$(DBAT) "SELECT k1.aseqno, k1.keyword, k2.keyword \
	FROM keyw k1, keyw k2 \
	WHERE k1.aseqno=k2.aseqno AND k1.keyword='easy' \
	  AND k2.keyword IN ('hard','more','obsc','uned','unkn') \
	  ORDER BY 3,1" \
	| tee $@.tmp
	wc -l $@.tmp
check_fini_full:
	$(DBAT) "SELECT k1.aseqno, i.keyword \
	FROM keyw k1, asinfo i \
	WHERE k1.aseqno=i.aseqno AND k1.keyword='full' \
	  AND i.keyword NOT LIKE '%fini%' \
	  ORDER BY 1" \
	| tee $@.tmp
	wc -l $@.tmp
check_full:
	$(DBAT) "SELECT k1.aseqno, k1.keyword, k2.keyword \
	FROM keyw k1, keyw k2 \
	WHERE k1.aseqno=k2.aseqno AND k1.keyword='full' \
	  AND (k2.keyword IN ('cofr','eigen','mult','tabl','tabf'))\
	  ORDER BY 3,1" \
	| tee $@.tmp
	wc -l $@.tmp
check_nice:
	$(DBAT) "SELECT k1.aseqno, k1.keyword, k2.keyword \
	FROM keyw k1, keyw k2 \
	WHERE k1.aseqno=k2.aseqno AND k1.keyword IN ('nice','core','look','hear') \
	  AND k2.keyword IN ('less','dumb','obsc','uned','unkn') \
	  ORDER BY 3,1" \
	| tee $@.tmp
	wc -l $@.tmp
check_sign:
	$(DBAT) "SELECT k1.aseqno, k1.keyword, k2.keyword \
	FROM keyw k1, keyw k2 \
	WHERE k1.aseqno=k2.aseqno AND k1.keyword='sign' \
	  AND k2.keyword IN ('nonn','cons') \
	  ORDER BY 3,1" \
	| tee $@.tmp
	wc -l $@.tmp
check_tabf:
	$(DBAT) "SELECT k1.aseqno, k1.keyword, k2.keyword \
	FROM keyw k1, keyw k2 \
	WHERE k1.aseqno=k2.aseqno AND k1.keyword='tabf' \
	  AND k2.keyword IN ('tabl','mult') \
	  ORDER BY 3,1" \
	| tee $@.tmp
	wc -l $@.tmp
#	  AND k2.keyword IN ('tabl','cons','mult','cofr','walk','word') \
#
check_tabl:
	$(DBAT) "SELECT k1.aseqno, k1.keyword, k2.keyword \
	FROM keyw k1, keyw k2 \
	WHERE k1.aseqno=k2.aseqno AND k1.keyword='tabl' \
	  AND k2.keyword IN ('tabf') \
	  ORDER BY 3,1" \
	| tee $@.tmp
	wc -l $@.tmp
#	  AND k2.keyword IN ('tabf','cons','mult','cofr','walk','word') \
#
#----
base_stats: # print count of "base" sequences in groups Ann*
	$(DBAT) "SELECT SUBSTR(aseqno, 1, 3), COUNT(SUBSTR(aseqno, 1, 3)) FROM keyw \
	    WHERE keyword = 'base' \
	    GROUP BY SUBSTR(aseqno, 1, 3) ORDER BY 1;"
#================
