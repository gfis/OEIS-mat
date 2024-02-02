#!make

# OEIS-mat/contrib/sm - Seiichi Manyama
# @(#) $Id$
# 2023-05-31: Georg Fischer
#---------------------------------
GITS=../../..
COMMON=../../common
ROBOT=$(GITS)/OEIS-mat/robot
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar
JPREP=$(RAMATH)  org.teherba.ramath.sequence.JoeisPreparer
CAT=../../common/jcat25.txt
#-------------
help:
all: # all possible targets:
	grep -P "^\w[^\:]*\:" makefile | sort 
#==============================
smsort:
	grep -P "\tnyi" smlist.txt \
	| cut -f1,3-5 \
	| sort -k2,2 \
	| sed -e "s/\t/ /g" -e "s/^/%F /" \
	>        $@.tmp
	wc -l    $@.tmp
	cd $(COMMON) ; perl nyi.pl -q smsort ../contrib/sm/smsort.tmp > ../contrib/sm/smsort.txt
	wc -l    $@.txt
#----
#2345678901
#N A123456 a(n) = 
serrev0:
	grep -P "Series_Rever" $(CAT) | cut -b4-10 | tee grep.tmp
	grep -f grep.tmp $(CAT) | grep -P "^%o A\d+ *\(PARI\) *a\(" | grep " = sum" | tee serrev.tmp
serrev:
	perl $@.pl $@.tmp \
	2>       $@.rest.tmp \
	| tee    $@.txt
	wc -l    $@.*
#----
serexp0:
	grep -P "^%o A\d+ *\(PARI\) *a\(" $(CAT) \
	| grep -P "sum\(" \
	| grep -P "\)\*binomial" | grep -vP "prod|my|local|vec|bernfrac|floor|ceil" \
	| perl -pe 's{ *\\\\.*}{};' \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#	| # grep -vP "\/\(n\+1\)\;" \
#
serexp:
	grep -Pi "\, *bi" serexp0.tmp \
	| perl serrev.pl \
	2>       $@.rest.tmp \
	| tee    $@.txt
	wc -l    $@.*
#----
