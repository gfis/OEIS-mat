#!make

# OEIS-mat: keyword-related queries
# @(#) $Id$
# 2019-01-13: Georg Fischer, copied from ../bfcheck
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
BASE=../bfcheck/neil_lists/keywordlist.txt

all: 
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#----
list:
	less $(BASE)
keyw_split:
	perl keyword.pl -a split $(BASE) > $@.1.tmp
	cut -d" " -f 2 $@.1.tmp | sort | uniq -c | tee $@.2.tmp
keyword_stats:
	perl keyword.pl -a html  keyw_split.2.tmp > $@.html
#-----------------
deploy:
	cp -v keyword_stats.html index.html
	scp index.html \
		gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/keyword/
#=================
