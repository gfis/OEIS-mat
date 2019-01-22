#!make

# OEIS-mat/bfcheck/www_teo -> teherba.org
# @(#) $Id$
# 2019-01-17: Georg Fischer
#---------------------------------
all: 
	# targets: new = prepare newseq archlist regen (in that order)
	grep -E "^[a-z]" makefile
eval:
	grep -E "^%[0-9]" bextra_combine.txt | cut -b1-2 | sort | uniq -c
grep3:
	grep -E "^%3" bextra_combine.txt | cut -b4-10| sort | tee grep3.tmp
grepi:
	grep -E "^%$(I)" bextra_combine.txt | cut -b4-10| sort | tee gf$(I).tmp

#--------
clean:
	rm -vf *.bak *.tmp
	ls -al
deploy: clean
	scp *.* gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/bfcheck/
