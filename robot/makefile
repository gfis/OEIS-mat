#!make

# OEIS-mat/robot - automatic preparation of parameters for the generation of Java programs for jOEIS
# @(#) $Id$
# 2023-05-01, Georg Fischer: start with lingf
#---------------------------------
GITS=../..
COMMON=$(GITS)/OEIS-mat/common
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
RAMATH=java -cp  $(GITS)/ramath/dist/ramath.jar org.teherba.ramath
JPREP=$(RAMATH).sequence.JoeisPreparer
PFRACT=java -cp  $(RAMATH).symbolic.PolyFraction
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
ODATA=$(GITS)/oeisdata
HERE=$(GITS)/OEIS-mat/robot
REMOTE=atair
# set_env_var_REMOTE
#-------------
all: help
help:
	grep -E "^[a-z]" makefile
#========
linman4: # convert to num, den tuples with JPREP
	$(JPREP) -f linman2.tmp \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
linman: # -> lingf (*.gen)
	grep -E "fract1" linman4.tmp \
	| sed -e "s/fract1/lingf/" \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
#--------
# Robot#1: Ordinary (rational) generating functions
ogf: ogf1 ogf2 
ogf1: # extract
	grep -E "%[SOFN]" $(COMMON)/jcat25.txt \
	| perl catex_gf.pl -d 0 \
	>        $@.tmp
	head -n2 $@.tmp
	wc -l    $@.tmp
ogf2: # use JPREP to generate (num, den) tuples for rational o.g.f.s 
	$(JPREP) -f ogf1.tmp \
	>        $@.tmp
	grep -E "fract1" $@.tmp | sed -e "s/fract1/lingf/" \
	| perl -ne 'my @f = split(/\t/); print if length($$f[4]) < 2048;' \
	>        $@.gen
	head -n2 $@.gen
	wc -l    $@.gen
	mv -v    $@.gen ogf.gen
	cp -v    ogf.gen ogf.`date +%Y-%m-%d`.gen
#----
fract21:
	grep -E  "fract21" ogf2.tmp \
	| sed -e "s/fract21/trigf/" \
	>        $@.gen
	tail -n2 $@.gen
	wc -l    $@.gen
fract22:
	grep -E  "fract22" ogf2.tmp \
	| sed -e "s/fract22/trigf/" \
	>        $@.gen
	tail -n2 $@.gen
	wc -l    $@.gen
#----
partsum:
	grep -E "^%" $(COMMON)/jcat25.txt | grep -P "Partial sums of A" \
	| perl ../common/nyi.pl -p | cut -b6- | grep -vE "#\?" \
	| perl -ne 'my $$line = $$_; if ($$line =~ s{\A(A\d+) *}{}) { my $$an = $$1; '\
	' if ($$line =~ m{of (A\d+)}) { my $$rn = $$1; '\
	' print join("\t", $$an, partsum, 0, "", "", "new $$rn()", "") . "\n"; } else { print "# $$line"; }}'\
	| tee    $@.gen
	wc -l    $@.gen
#----
xfract: nfract fract1 fract2 fract39
xnfract:
	grep -E "^#" catgf1.tmp \
	| sort -k3 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp	
xfract1:
	grep -vE "^#" catgf1.tmp | grep fract1 \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	make njoeis LIST=$@.tmp
xfract2:
	grep -vE "^#" catgf1.tmp | grep -E "fract2" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	# make njoeis LIST=$@.tmp
xfract2_prep:
	
xfract39:
	grep -vE "^#" catgf1.tmp | grep -E "fract[3-9]" \
	>       $@.tmp || :
	head -64 $@.tmp
	wc -l   $@.tmp
#-----
