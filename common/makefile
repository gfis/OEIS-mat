#!make

# OEIS-mat/common - scripts and data common to all subprojects
# @(#) $Id$
# 2019-01-22: unpacking from ../dumps
# 2019-01-17: Georg Fischer
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
SLEEP=16
DUMPS=../dumps
HEAD=8

all: 
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#--------
update_history: new changed
new:
	perl history.pl -g $@ -w $(SLEEP)
	ls -al `date +%Y-%m-%d`
changed:
	perl history.pl -g $@ -w $(SLEEP)
	ls -al `date +%Y-%m-%d`
#--------------------------------
update_list:
	tar -czvf update_list.`date +%Y-%m-%d`.tgz `date +%Y-%m-%d`/*.t*
#================================
list_dumps:
	tar -tjvf $(DUMPS)/oeis-json.tar.bz2       | head -$(HEAD)
	tar -tjvf $(DUMPS)/2019-01-21.tar.xz       | head -$(HEAD)
	tar -tzvf $(DUMPS)/b000001-b321800.tar.gz  | head -$(HEAD)
	tar -tjvf $(DUMPS)/bfiles-cleaned.tar.bz2  | head -$(HEAD)
#----
unpack_dumps: unjs1 unjs2 unbf1 unbf2 unbf3
	du -m
	find   unjs -type f | wc -l 
	find   unbf -type f | wc -l 
unjs1:
	mkdir  unjs || :
	tar -C unjs --strip-components=2 -xjf $(DUMPS)/oeis-json.tar.bz2
unjs2:
	tar -C unjs --wildcards --strip-components=3 -xjf $(DUMPS)/2019-01-21.tar.xz "update/*/json/*"
unbf1:
	mkdir  unbf || :
	tar -C unbf --strip-components=0 -xzf $(DUMPS)/b000001-b321800.tar.gz 
unbf2:
	tar -C unbf --strip-components=2 -xjf $(DUMPS)/bfiles-cleaned.tar.bz2 
unbf3:
	tar -C unbf --wildcards --strip-components=3 -xjf $(DUMPS)/2019-01-21.tar.xz "update/*/bfile/*"
#--------------------------------
bfinfo:
bfinfo_get:
	perl bfinfo.pl -br unbf > bfinfo.txt
	cp bfinfo.txt bfinfo.`date +%Y-%m-%d.%H_%M`.txt
	wc -l bfinfo.txt
bfinfo_load:
	perl bfinfo.pl -bc | tee bfinfo.create.sql
	$(DBAT) -f bfinfo.create.sql
	cut -b1-128 bfinfo.txt \
	| $(DBAT) -m csv -s "\t" -r bfinfo
	$(DBAT) -4 bfinfo
	$(DBAT) -n bfinfo
bfsynth:
	rm -f $@.1.tmp
	find unbf -type f | xargs -l grep -iH "file synthesized from" >> $@.1.tmp
	cut -f2 $@.1.tmp > $@.tmp
	wc -l $@.tmp
	
#--------------------------------
fsizes_update:
	$(DBAT) -f temp.create.sql
	$(DBAT) -m csv -s " " -r temp < fsizes.1.tmp
	$(DBAT) -4 temp
	$(DBAT) -n temp
	$(DBAT) -v "UPDATE bflink b SET b.fsize = \
	    COALESCE((SELECT t.temp FROM temp t WHERE b.aseqno = t.aseqno), -1)"
#--------------------------------
#=================
# old targets
news2:
	cat newseq.`date +%Y-%m-%d`.lst | xargs -l -i{} rm -vf ../store/{}.text
	cat archlist.tmp | xargs -l -i{} rm -vf ../store/{}.text
#------------
