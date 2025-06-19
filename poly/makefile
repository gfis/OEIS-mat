#!make

# OEIS-mat: PolynomialFieldSequence
# @(#) $Id$
# 2025-06-08: Georg Fischer; *FP=11
#---------------------------------
GITS=../..
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb 
COMMON=../common
FISCHER=$(GITS)/joeis-lite/internal/fischer
REFLECT=$(FISCHER)/reflect
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar
JPREP=$(RAMATH)  org.teherba.ramath.sequence.JoeisPreparer
#----
all: packegf getegf psimple egfu2 polysh
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
	# e        $@.tmp
#----
psimple: # extract polynomials - simple attempt
	perl psimple.pl getegf.tmp \
	| sort -k5 \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
	# e        $@.tmp
#----	 
egfu2:
	$(JPREP) -f psimple.tmp -cc post2 \
	>        $@.1.tmp
	grep -E  "\?" $@.1.tmp > $@.rest.tmp || :
	grep -vE "\?" $@.1.tmp > $@.tmp || :
	head -n4 $@.tmp
	wc -l    $@*.tmp  
#----
polysh: # polish the postfix
	perl polysh.pl egfu2.tmp \
	2>       $@.rest.tmp \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.*tmp
	e        $@.tmp
deploy:
	# cp       polysh.tmp $(FISCHER)/aman/polyex.man
#----
expsum:
	grep -iP "exp\(Sum" $(COMMON)/jcat25.txt \
	| grep -P "^%" \
	| cut -b4- | sed -e "s/ /\t/" \
	| endirect \
	>        $@.tmp
	head -n8 $@.tmp
	wc -l    $@.tmp
	perl $(FISCHER)/htmlize.pl $@.tmp > $@.html
	chmod 755 $@.html
	cmd /c $@.html
	

