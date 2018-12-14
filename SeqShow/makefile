#!make

# Generate the files for the OEIS/music exhibition in Heidelberg, May 2018
# @(#) $Id$
# 2018-12-14, Georg Fischer
#---------------------------------
C=4
D=0
INPUT=Music1.en_de.txt

all: 
	# please make targets explicitely: new ...
	grep -E "^[a-z]" makefile
#----
new: 
	perl showgen.pl -c $(C) -l en < $(INPUT)
	cp web/index.en.html web/index.html
	perl showgen.pl -c $(C) -l de < $(INPUT)
#------------
zip:
	rm -r *.bak
	zip -r ../SeqShow.zip *
	cp ../SeqShow.zip ../SeqShow.`date +%Y-%m-%d_%H.%M.%S`.zip
