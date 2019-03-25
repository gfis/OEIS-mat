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
	$(DBAT) -256 \
	"SELECT x.aseqno, COUNT(x.rseqno) \
		, n.name, i.author, SUBSTR(created, 1, 10) AS created \
		FROM  asxref x, asname n, asinfo i \
		WHERE x.aseqno = n.aseqno \
		  AND x.aseqno = i.aseqno \
		GROUP BY x.aseqno, n.name, i.author, SUBSTR(created, 1, 10) \
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

