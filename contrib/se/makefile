#!make

# makefile for contrib/eilers
# @(#) $Id$
# 2023-12-05, Georg Fischer

GITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
BFILE=$(COMMON)/bfile
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
OFFSET=0
#----------------
all:
	grep -E "^[a-z]" makefile
	# parameter S=seqno SLEEP=$(SLEEP) SHIFT=$(SHIFT) WIDTH=$(WIDTH)
#================
lego:
#	g++ lego.cpp -o lego.o
#	g++ -o lego.o lego.exe
	g++ -Ofast -c -o $@.o $@.cpp
	g++ -o $@.exe $@.o
	chmod 755 $@.exe
jc:
	javac Lego.java
#--------