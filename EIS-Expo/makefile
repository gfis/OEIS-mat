#!make

# Generate the files for the OEIS/music exhibition in Heidelberg, May 2018
# @(#) $Id$
# 2018-12-14, Georg Fischer
#---------------------------------
C=4
D=0
INPUT=Music1.en_de.txt

all: new
# please make targets explicitely: new ...
#	grep -E "^[a-z]" makefile
#----
new: 
	perl expogen.pl -c $(C) -l en < $(INPUT)
	cp web/index.en.html web/index.html
	perl expogen.pl -c $(C) -l de < $(INPUT)
	tidy -q web/index.de.html > x.tmp
	tidy -q web/index.en.html > x.tmp
#------------
zip:
	rm -rf *.bak
	zip -r ../EIS-Expo.zip *
	cp ../EIS-Expo.zip ../EIS-Expo.`date +%Y-%m-%d_%H.%M.%S`.zip
deploy: 
	scp ../EIS-Expo.zip web/stylesheet.css web/*.html \
	web/img/hear.jpg \
	Music1.en_de.txt \
	gfis@punctum.com:/var/www/html/teherba.org/OEIS-mat/EIS-Expo
