#!make

# OEIS-mat/numden: Numerator/Denominator relations
# @(#) $Id$
# 2025-06-13: Georg Fischer
#---------------------------------
GITS=../..
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
COMMON=../common
FISCHER=$(GITS)/joeis-lite/internal/fischer
REFLECT=$(FISCHER)/reflect
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar
JPREP=$(RAMATH)  org.teherba.ramath.sequence.JoeisPreparer
#----
all:
	grep -E "^[a-z]" makefile
#----
numden: # get the Numerator/Denominator pairs
	grep -P "(Denomin|Numer)ators? of|(Denomin|Numer)ators? (are )?in ..?\D{6}|(Denomin|Numer)ator is ..?\D{6}|\(([Dd]enomin|[Nn]umer)ators\)" ../common/jcat25.txt | grep -P "^.[NFCY]" \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
nyiden:
	grep -P "^%" numden.tmp \
	| cut -b4- | sed -e "s/ /\t/" \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
	perl $(FISCHER)/htmlize.pl $@.tmp > $@.html
	chmod 755 $@.html
	./$@.html
arico:
	grep -P "^#" numden.tmp \
	| grep -E "€" \
	| cut -b4- | sed -e "s/ /\t/" \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
	perl $(FISCHER)/htmlize.pl $@.tmp > $@.html
	chmod 755 $@.html
	cmd /c start $@.html
#----
xrefari: # get nyi from jcat25.#Y
	grep -P "^#Y" $(COMMON)/jcat25.txt | grep -P "€\d{6} *\(\w+" \
	| perl xrefari.pl \
	| sort -k5 -k1 \
	>        $@.tmp
	wc -l    $@.tmp
	perl $(FISCHER)/htmlize.pl $@.tmp > $@.html
	chmod 755 $@.html
	cmd /c start $@.html
	>        $@.tmp