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
	| perl -pe 's/\,(easy|new|changed|less|hard|nice|hear|look|nonn)//g;' \
	>        $@.tmp
	tail -n4 $@.tmp
	wc -l    $@.tmp
#----   
multest:
	perl multest2.pl mudata.tmp \
	| endirect \
	>        $@.tmp
	tail -n8 $@.tmp
	wc -l    $@.tmp
eval: fail_mult pass_nomult pass_njoeis
fail_mult:
	grep -P "^[A-Z]\d{6}" multest.tmp \
	| grep -P "\bFAIL\b" | grep -P "\bmult\b" \
	>        $@.tmp
	tail -n8 $@.tmp
	wc       $@.tmp
	e        $@.tmp
pass_nomult:
	grep -P "^[A-Z]\d{6}" multest.tmp \
	| grep -P "\bpass\b" | grep -vP "\bmult\b" \
	>        $@.tmp
	tail -n8 $@.tmp
	wc       $@.tmp
	e        $@.tmp   
pass_njoeis:
	grep -P "^[A]\d{6}" multest.tmp \
	| grep -P "\bpass\b" \
	>        $@.tmp
	tail -n8 $@.tmp
	wc       $@.tmp
	e        $@.tmp   
#----
