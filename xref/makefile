#!make

# OEIS-mat/xref - Evaluate CROSSREFERENCES
# @(#) $Id$
# 2019-03-20: Georg Fischer, copied from ./mine
#---------------------------------
DBAT=java -jar ../../dbat/dist/dbat.jar -e UTF-8 -c worddb
SLEEP=16
DUMPS=../dumps
HEAD=8
PULL=../pull
COMMON=../common
D=0
G=n
all:
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
#======================
asxref: asxref1 asxref2
asxref1:
	perl $(COMMON)/extract_info.pl -ax ./ajson > asxref.txt
asxref2:
	head -n4 asxref.txt
	
#---------------------
many: refers_many referred_many
refers_many:
	$(DBAT) -1024 \
	"SELECT x.aseqno, COUNT(x.rseqno), n.name, i.author \
		FROM  asxref x, asname n, asinfo i \
		WHERE x.aseqno = n.aseqno \
		  AND x.aseqno = i.aseqno \
		  AND x.aseqno NOT IN (SELECT aseqno FROM joeis) \
		  AND x.rseqno NOT IN (SELECT aseqno FROM joeis) \
		GROUP BY x.aseqno, n.name, i.author \
		ORDER BY 2 DESC" \
	| tee $@.txt
referred_many:
	$(DBAT) -256 \
	"SELECT x.rseqno, COUNT(x.aseqno) \
		, n.name, i.author, SUBSTR(created, 1, 10) AS created \
		FROM  asxref x, asname n, asinfo i \
		WHERE x.rseqno = n.aseqno \
		  AND x.rseqno = i.aseqno \
		GROUP BY x.rseqno, n.name, i.author, SUBSTR(created, 1, 10) \
		ORDER BY 2 DESC" \
	| tee $@.txt
#----
# Peter 2019-07-09
reftabl:
	$(DBAT) -100 \
	"SELECT x.rseqno, COUNT(x.aseqno) \
		                 , n.name, i.author, SUBSTR(created, 1, 10) AS created, i.keyword \
		FROM  asxref x, asname n, asinfo i \
		WHERE x.rseqno = n.aseqno \
		  AND x.rseqno = i.aseqno \
		  AND i.keyword like '%tabl%' \
		GROUP BY x.rseqno, n.name, i.author, SUBSTR(created, 1, 10), i.keyword \
		ORDER BY 2 DESC" \
	| perl -pe "s{\'\'}{\'}g" > $@.txt
#----------------
# LIST=../../joeis-lite/internal/fischer/partial_sum_stage2.out.ut
LIST=partial_sum_stage2.out
noxref: # LIST= ; Sean 2022-06-23
	$(DBAT) -f $(COMMON)/seq2.create.sql
	sed -e "s/ /\t/" $(LIST) \
	| $(DBAT) -r seq2
	$(DBAT) "(SELECT s.aseqno, '', '->', '', s.info   FROM asxref x, seq2 s \
	           WHERE s.aseqno = x.aseqno AND s.info = x.rseqno) \
	UNION    (SELECT s.aseqno, '', '<-', '', s.info   FROM asxref x, seq2 s \
	           WHERE s.aseqno = x.rseqno AND s.info = x.aseqno) \
	UNION    (SELECT s.aseqno, '', '??', '', s.info   FROM seq2 s \
	           WHERE s.info   NOT IN (SELECT x.rseqno FROM asxref x WHERE x.aseqno = s.aseqno) \
	             AND s.aseqno NOT IN (SELECT x.rseqno FROM asxref x WHERE x.aseqno = s.info  ) ) \
	ORDER BY 1" \
	| tee $@.tmp
	cut -f3 $@.tmp | sort | uniq -c
#----

