#!make

# Makefile in gits/OEIS-mat/sequencedb
# @(#) $Id$
# 2021-06-22, Georg Fischer: copied from ../makefile
#
GITS=../..
LITE=$(GITS)/joeis-lite
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
ifeq ($(OS),Windows_NT)
    CPS=;
else
    CPS=:
endif
JAVA=java $(JOPT) -cp "$(LITE)/dist/joeis-lite.jar$(CPS)$(JOEIS)/build.tmp/joeis.jar"
#----------------
all:
	# Possible targets:
	grep -E "^[a-z]" makefile | sort
#----------------------------------
# preliminary: bring any A-number on 1 line
flatten:
	perl sdb_flat.pl compiled_entities.json \
	>        $@.json
	head -n4 $@.json
	wc -l    $@.json
#----------------------------------
# parse into seq4 format
seqdb:
	perl seqdb_parse.pl compiled_entities.json \
	| sort -k1,1 -k2,2 \
	>        $@.txt
	head -n4 $@.txt
	wc -l    $@.txt
seqdb_load:
	$(DBAT) -f seqdb.create.sql
	$(DBAT) -r seqdb < seqdb.txt
	$(DBAT) -4 seqdb
	$(DBAT) -n seqdb
#----------------------------------
load_an:
	cut -b2- flatten.json \
	| cut -f1,2 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cd .. ; make seq2 LIST=sequencedb/$@.tmp
#----
notjoeis:
	$(DBAT) -x "SELECT s.aseqno, s.info, n.name \
	  FROM seq2 s, asname n \
	  WHERE s.aseqno = n.aseqno \
	    AND s.aseqno NOT IN (SELECT aseqno FROM joeis) \
	    ORDER BY 1"\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----