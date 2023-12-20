#!make

# OEIS-mat/linrec/long - long g.f.s
# @(#) $Id$
# 2023-12-20: Georg Fischer
#---------------------------------
GITS=../../..
DBAT=java   -jar $(GITS)/dbat/dist/dbat.jar -e UTF-8 -c worddb
RAMATH=java -cp  $(GITS)/ramath/dist/ramath.jar org.teherba.ramath
JPREP=$(RAMATH).sequence.JoeisPreparer
PFRACT=java -cp  $(RAMATH).symbolic.PolyFraction
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
JOEIS=$(GITS)/joeis
COMMON=$(GITS)/OEIS-mat/common
SLEEP=8
COMMON=../../common
D=0

all:
	grep -E "^[a-z]" makefile
#======================================================
gfurls:
	wget -w $(SLEEP) -i gfurls.txt
#----
urlist:
	rm -f urlist1.tmp
	find urls -iname "a*.txt" | xargs -innn make urlist1 A=nnn
urlist1:
	perl -e 'my $$a = shift(@ARGV); $$a =~ m{(a\d+)}; my $$aseqno = uc($$1); print "$$aseqno\n\;gf\=\n";' $(A) >> $@.tmp
	cat  $(A) \
	| sed -e "s/[\:\. ]//g" -e "s/Gf//" \
	| grep -vP "a\(" \
	| tee -a       $@.tmp
	echo ";"   >>  $@.tmp
urlprep:
	perl preplong.pl urlist.man \
	>         $@.tmp
	head -n2  $@.tmp
	wc -l     $@.tmp
#----
maplist:
	rm -f maplist1.tmp
	cat $@.txt | xargs -innn make maplist1 A=nnn
maplist1:
	echo $(A) >> $@.tmp
	grep -P "^%p $(A)" $(COMMON)/jcat25.txt | cut -b 12- | grep -vP "seq|series" \
	| sed -e "s/\://g" -e "s/ //g" -e "s/gf/\;gf/" \
	| tee -a     $@.tmp
	echo ";" >>  $@.tmp
maprep:
	perl preplong.pl maplist.man \
	>         $@.tmp
	head -n2  $@.tmp
	wc -l     $@.tmp
	
greplong:
	grep -P "([\+\-] *\d+ *\* *x\^\d+ *){4}" $(COMMON)/jcat25.txt | grep -P "^\%[NFCpto]" \
	| grep -viP "\.\.|sum|prod|gcd|reversion" \
	| tee $@.tmp
	wc -l $@.tmp
