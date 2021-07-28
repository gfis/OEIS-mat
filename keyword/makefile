#!make

# OEIS-mat: keyword-related queries
# @(#) $Id$
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
list: # list a CAT25 extract from 2019
	less ../bfcheck/neil_lists/keywordlist.txt
#----
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
keyword_stats: # build a HTML list with the statistics
	perl keyword.pl -a html -kw keyw_split.tmp keyw_split.1.tmp \
	>        $@.html
	wc -l    $@.html
#--
deploy: # upload the keyword statistics 
	cp -v keyword_stats.html index.html
	echo set REMOTE=
	scp index.html $(REMOTE):/var/www/html/teherba.org/OEIS-mat/keyword/
#----------------
keyw_load: # load keywords into keyw
	sed -e "s/ /\t/" keyw_split.tmp \
	>        $@.tmp
	$(DBAT) -f keyw.create.sql
	$(DBAT) -r keyw < $@.tmp
	$(DBAT) -4 keyw
	$(DBAT) -n keyw
#----
base_stats: # print count of "base" sequences in groups Ann*
	$(DBAT) "SELECT SUBSTR(aseqno, 1, 3), COUNT(SUBSTR(aseqno, 1, 3)) FROM keyw \
	    WHERE keyword = 'base' \
	    GROUP BY SUBSTR(aseqno, 1, 3) ORDER BY 1;"
#================
