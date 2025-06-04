#!make

# OEIS-mat: MultiplicativeSequence
# @(#) $Id$
# 2025-06-01: Georg Fischer; *UP=56; copief from ../keyword
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
BASE=./keywordlist.txt
REMOTE=user@server.tld
COMMON=../common

all: 
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#----
mudata:
	$(DBAT) "SELECT i.aseqno, i.keyword, i.offset1, d.data \
	  FROM asinfo i, asdata d \
	  WHERE i.aseqno = d.aseqno \
	  ORDER BY 1" \
	| grep -vP "cons|tab|bref|dead|word" \
	| perl -pe 's/\,(easy|new|changed|less|hard|nice|hear|look)//g;' \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
#----   
multest:
	perl multest.pl mudata.tmp \
	| endirect \
	| tee $@.tmp
	wc -l $@.tmp
eval:
	grep -E "^A" multest.tmp \
	| grep -v mult \
	>     $@.tmp
	wc    $@.tmp
	e     $@.tmp
#----
