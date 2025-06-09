#!make

# OEIS-mat: PolynomialFieldSequence
# @(#) $Id$
# 2025-06-08: Georg Fischer; *FP=11
#---------------------------------
GITS=../..
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
COMMON=../common
REFLECT=$(GITS)/joeis-lite/internal/fischer/reflect

all: 
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#----
BASE=ExponentialGeneratingFunction
packegf: # pack all that extend $(BASE) 
	cd $(REFLECT) ; make pack_base BASE=$(BASE)
	mv -v $(REFLECT)/pack.$(BASE).tmp $@.tmp
#----
getegf: # extact the implemented e.g.f.s
	perl getegf.pl packegf.tmp \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
	e        $@.tmp
#----
