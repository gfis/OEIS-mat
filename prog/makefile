#!make

# OEIS-mat/prog - analyze programs in the OEIS
# @(#) $Id$
# 2026-07-14: Georg Fischer; *CKZ=74
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
SLEEP=16
COMMON=$(GITS)/OEIS-mat/common
HERE=$(GITS)/OEIS-mat/prog
CAT=$(COMMON)/jcat25.txt 
XTRANS=java -jar $(GITS)/xtrans/dist/xtrans.jar
DATE=`date +%Y-%m-%d`
MANY=64
#----
all: help # get a list of the possible targets
help: # list all targets: 
	grep -E "^[a-z]" makefile
#================================
SUBDIR=pari
asprog_split: # split an extract of asprog.txt into single files
	grep -P "\t$(SUBDIR)\t" $(COMMON)/asprog.txt \
	| head -n $(MANY) \
	>        $@.tmp 
	tail -n2 $@.tmp
	wc -l    $@.tmp
	rm -rf   $(SUBDIR)
	cat $@.tmp \
	| perl asprog_split.pl -s $(SUBDIR) 
	du -b    $(SUBDIR)
#----
SRC=pari/A090869.1.pari
gp1:
	$(XTRANS) -pari $(SRC) -gp x.tmp 
	echo  $(SRC)                | tee -a $@.log
	diff  x.tmp     $(SRC) 2>&1 | tee -a $@.log
check_pari: # check whether pari -> SAX -> pari yields the identical source
	rm -f gp1.log
	find $(SUBDIR) -iname "*.$(SUBDIR)" \
	| xargs -innn make -s gp1 SRC=nnn
#----
asprog_opers: # extract the operators from asprog (sequences of non-word, non-bracket, non-space characters)
	grep  -P "\tpari\t" $(COMMON)/asprog.txt \
	| perl asprog_opers.pl \
	| sort -k2,2n \
	| tee    $@.tmp
	wc -l    $@.tmp 
	tail -n64 $@.tmp | cut -f1 | perl -pe "s/\s*\Z/ /" \
	| tee    $@.txt
#----

