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
df: dfinite df_load df_patch df_sel df_prep
#----
recur.grep:
	ssh gfis@atair 'cd ~/work/gits/OEIS-mat/common ; find ajson -iname "*.json" | sort | xargs -l grep -HE "Recurrence"' | tee $@.txt
#----
dfinite.grep:
	ssh gfis@atair 'cd ~/work/gits/OEIS-mat/common ; find ajson -iname "*.json" | sort | xargs -l grep -iHE "[DPC]\-finite"' | tee $@.txt
dfinite:
	perl dfinite.pl dfinite.grep.txt \
	| sort | uniq -w7 \
	| grep -vE "A071359|A098442|A106191|A144580|A145889|A152886|A227292|A346224|A351930|A352681" \
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
df_patch:
	$(DBAT) "UPDATE seq4 SET parm1='(n+2)*a(n)+5*(-n-1)*a(n-1)+2*(4*n+1)*a(n-2)+4*n*a(n-3)+2*(-2*n+11)*a(n-5)+2*(4*n-23)*a(n-6)+4*(-n+6)*a(n-7)=0.' WHERE aseqno = 'A098051';"
	$(DBAT) "UPDATE seq4 SET parm1='-n*(n-1)*(n-2)*(2*n-3)*a(n) + 216*(4*n-11)*(4*n-1)*(4*n-5)*(4*n-7)*a(n-3)' WHERE aseqno='A347855';"
df_sel:
	$(DBAT) -x "SELECT s.aseqno, s.callcode, s.offset1, s.parm1, s.parm2, s.parm3 \
	  FROM seq4 s \
	  WHERE s.callcode = 'holope' \
	    AND (  s.aseqno NOT IN (SELECT aseqno FROM joeis) \
	        OR (COALESCE((SELECT j.superclass FROM joeis j WHERE s.aseqno = j.aseqno), 'nyi') <> 'HolonomicRecurrence' \
	           AND s.aseqno >= 'A059000' \
	           ) \
	        ) \
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
#----
# on the server:
# find ajson -iname "*.json" | xargs -l grep -iH Conjecture | grep Mathar | tee conjmath.tmp
# ajson/A338727.json: "Conjecture: D-finite with recurrence (n+2)^2*(n-1)^2*a(n) -4*n^2*(2*n-1)^2*a(n-1)=0. - _R. J. Mathar_, Dec 11 2020",
conj: conj_load conj_eval
conj_load: # load RM's conjectures into seq2
	grep -v Ekhad conjmath.tmp \
	| sed -e "s/^ajson\///" -e "s/\"//g" -e "s/\.json\:\t*/\t/" -e "s/Conjecture:? ?//" -e "s/\. *\- *_R\. J. Mathar_.*//" \
	| sort | uniq -w7 \
	>        $@.tmp
	cd ../../common ; make seq2 LIST=../contrib/rm/$@.tmp
conj_eval: # check whether we have them
	$(DBAT) -x "SELECT s.aseqno, COALESCE(j.superclass, 'nyi'), s.info \
	  FROM seq2 s LEFT JOIN joeis j ON s.aseqno = j.aseqno \
	  ORDER BY 1"\
	>        $@.tmp
	head -n4 $@.tmp
	wc -l    $@.tmp
