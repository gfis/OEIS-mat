#!make

# OEIS-mat/data - new extraction from ../../oeisdata
# @(#) $Id$
# 2023-05-01: Georg Fischer
#---------------------------------
GITS=../..
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
SLEEP=16
DATA=$(GITS)/oeisdata
HERE=$(GITS)/OEIS-mat/data
REMOTE=atair
# set_env_var_REMOTE
#-------------
all: help
help:
	grep -E "^[a-z]" makefile
#======================
seq: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/$@.create.sql
	cut -b1-7 $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
seq2: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/$@.create.sql
	cut -b1-  $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
seq3: # parameter: $(LIST)
	$(DBAT) -f $(COMMON)/$@.create.sql
	cut -b1-  $(LIST) | grep -E "^A" | sort | uniq > $@.tmp
	$(DBAT) -m csv -r $@ < $@.tmp
	$(DBAT) -4 $@
	$(DBAT) -n $@
#==============================
cat25:
	cd $(DATA) ; find seq | sort > $(HERE)/$@.list.tmp
	rm -f $@.txt
	cd $(DATA) ; cat $(HERE)/$@.list.tmp | xargs -l -innn cat nnn >> $(HERE)/$@.txt
	head -n4 $@.txt
	wc -l    $@.txt
	ls -al   $@.txt
#--------
conjec8: # compare the 2 from conjec7
	$(DBAT) -x "SELECT s.aseqno, j.superclass, n.name \
	  FROM  seq s, asname n LEFT JOIN joeis j ON j.aseqno = n.aseqno \
	  WHERE s.aseqno = n.aseqno \
	    AND s.aseqno NOT IN (SELECT s2.aseqno FROM seq2 s2) ORDER BY 1" \
	| tee    $@.tmp
	wc -l    $@.tmp
#----

