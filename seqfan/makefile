#!make

# makefile for SeqFan email list archive index
# @(#) $Id$
# 2019-06-05, Georg Fischer
#----------------------------------------
LIM=16
MF=64
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
BASE=bigout1
WAIT=16
COMMON=../common
#-------------------------
all: 
	# please make targets explicitely: table, brol, url1 ...
	grep -E "^[a-z]" makefile
#-------------------------
sfdir:
	wget http://list.seqfan.eu/pipermail/seqfan/ -O $@.html
	#  <td><A href="2019-June.txt.gz">[ Gzip'd Text 5 KB ]</a></td>
	# http://list.seqfan.eu/pipermail/seqfan/2011-September.txt.gz
sfget:
	perl -ne 'if (m{href=\"(20..\-\w+\.txt\.gz)}) { print "http://list.seqfan.eu/pipermail/seqfan/$$1\n"; }' \
		sfdir.html \
	| tee $@.tmp
	wget --wait=8 --no-clobber -i $@.tmp
#----
evalink: evalink1 evalink2 # get the links
evalink1:
	grep "seqfan.eu" $(COMMON)/jcat25.txt \
	| tee $@.tmp
evalink2:
	cat evalink1.tmp \
	| perl -ne 'm{\"([^\"]+)}; print "$$1\n";' \
	| sort | uniq | sort -r \
	| tee $@.tmp
	wc -l $@.tmp
#----
expand: # expand all gzips
	find . -iname "*.gz" | xargs -innn gzip -dk nnn
	wc -l *.txt
