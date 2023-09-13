#!make

# OEIS-mat/arti - derive jOEIS programs automatically from existing ones
# @(#) $Id$
# 2023-09-01: Georg Fischer
#---------------------------------
GITS=../..
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
CAT=$(COMMON)/jcat25.txt
D=0
G=n
# set_env_var_REMOTE
#-------------
all:
	# targets: new = prepare newseq archlist regen (in that order)
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
delseq: seq # parameters: $(TAB) $(LIST)
	$(DBAT) -v "DELETE FROM $(TAB) WHERE aseqno IN (SELECT aseqno FROM seq)"
#==============================
# sort program lines in jcat25
sortprep:
	grep -P "^[\%\#][optF]" $(CAT) \
	| perl sortprep.pl \
	| sort -k2,2 -k4,4 -k1,1 \
	>          $@.tmp
	head -n2   $@.tmp
	wc -l      $@.tmp
evalsame:
	cat sortprep.tmp \
	| perl evalsame.pl \
	>          $@.tmp
	head -n2   $@.tmp
	wc -l      $@.tmp
#----
joeis_ccan:
#----------------------------
maple_lines:
	grep -E "^\%p" jcat25.txt | grep combstruct | cut -b4- \
	| sort | uniq -w7 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
