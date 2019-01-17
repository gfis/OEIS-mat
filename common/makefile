#!make

# OEIS-mat/common
# @(#) $Id$
# 2019-01-17: Georg Fischer
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
SLEEP=32

all: 
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#--------
new:
	perl history.pl -g $@ -w $(SLEEP)
	ls -al `date +%Y-%m-%d`
changed:
	perl history.pl -g $@ -w $(SLEEP)
	ls -al `date +%Y-%m-%d`
#--------------------------------
fsizes_update:
	$(DBAT) -f temp.create.sql
	$(DBAT) -m csv -s " " -r temp < fsizes.1.tmp
	$(DBAT) -4 temp
	$(DBAT) -n temp
	$(DBAT) -v "UPDATE bflink b SET b.fsize = \
	    COALESCE((SELECT t.temp FROM temp t WHERE b.aseqno = t.aseqno), -1)"
#=================
# old targets
news2:
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	cat archlist.tmp | xargs -l -i{} rm -vf ../store/{}.text
#------------
