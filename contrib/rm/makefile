#!make

# makefile for OEIS-mat/contrib/rh (R. Hardin)
# base k circular numbers ... difference at most d
# @(#) $Id$
# 2021-04-08, Georg Fischer

GITS=../../..
DBAT=java -jar $(GITS)/dbat/dist/dbat-lite.jar -e UTF-8 -c worddb
COMMON=$(GITS)/OEIS-mat/common
BFILE=$(COMMON)/bfile
JOEIS=$(GITS)/joeis
LITE=$(GITS)/joeis-lite
FISCHER=$(LITE)/internal/fischer
RAMATH=java -cp $(GITS)/ramath/dist/ramath.jar org.teherba.ramath
#----------------
all:
	grep -E "^[a-z]" makefile
#================
df: dfinite df_load df_sel df_prep
#----
dfinite.grep:
	ssh gfis@atair 'find ajson -iname "*.json" | sort | xargs -l grep -iHE "[DPC]\-finite"' | tee $@.txt
dfinite:
	perl dfinite.pl dfinite.grep.txt \
	| sort | uniq -w7 \
	| grep -vE "A071359|A098442|A227292|A346224|A351930|A352681" \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	cut -f2  $@.tmp | sort | uniq -c
#--------------------------------
df_load:
	cd $(FISCHER) ; make seq4 LIST=../../../OEIS-mat/contrib/rm/dfinite.tmp
df_eval:
	$(DBAT) -x "SELECT s.aseqno, s.callcode, COALESCE(j.superclass, 'nyi') \
	  FROM seq4 s LEFT JOIN joeis j ON s.aseqno = j.aseqno \
	  ORDER BY 1"\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
	grep -P "\tholope\tnyi" $@.tmp | wc -l
#----
df1_load:
	cd ../../common ; make seq  LIST=../contrib/rm/dfinite1.txt
df1_eval:
	$(DBAT) -x "SELECT s.aseqno FROM seq s \
	  WHERE s.aseqno NOT IN (SELECT aseqno FROM seq4) \
	  ORDER BY 1"\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
df_sel:
	$(DBAT) -x "SELECT s.aseqno, s.callcode, s.offset1, s.parm1, s.parm2, s.parm3 \
	  FROM seq4 s \
	  WHERE s.callcode = 'holope' \
	    AND s.aseqno NOT IN (SELECT aseqno FROM joeis) \
	  ORDER BY 1"\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
df_prep:
	perl df_prep.pl df_sel.tmp \
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
#----
hg: hg_load hg_eval
hg_load:
	cd $(FISCHER) ; make seq  LIST=../../../OEIS-mat/contrib/rm/hypergeom.txt
hg_eval:
	$(DBAT) -x "SELECT s.aseqno, COALESCE(j.superclass, 'nyi') \
	  FROM seq s LEFT JOIN joeis j ON s.aseqno = j.aseqno \
	  ORDER BY 1"\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
