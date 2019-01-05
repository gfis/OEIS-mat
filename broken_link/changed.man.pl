#!perl

# @(#) $Id$
# List of manual changes - generate status updates accordingly
# 2019-01-02: + filename
# 2018-12-19, Georg Fischer
#-------------------------------
use strict;
my $timestamp = &iso_time(time());
my $count = 0;

while (<DATA>) {
	next if m{^\#}; # skip thos which are already updated
	s{\s+\Z}{}; # chompr
	my ($aseqno, $status, $filename, $rest) = split(/\t/);
	$count ++;
	print '-- ' . join(" ", ($aseqno, $status, $filename, $rest)) . "\n";
	if ($filename !~ m{[\*\%]}) {
		print <<"GFis";
UPDATE url1 SET status=\'$status\', access=\'$timestamp\' 
  WHERE aseqno=\'$aseqno\' AND filename=\'$filename\';
GFis
	} else {
		print <<"GFis";
UPDATE url1 SET status=\'$status\', access=\'$timestamp\' 
  WHERE aseqno=\'$aseqno\';
GFis
	}
	if ($count % 4 == 0) {
		print "COMMIT;\n";
	}
} # while DATA
#----
sub iso_time {
    my ($unix_time) = @_;
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
    return sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
} # iso_time
__DATA__ 
# Artificial status codes:
# 240 = trusted sites
# 241 = manual check had no problem
# 245 = proposed normally
# 247 = emailed
# 248 = changed by other OEIS-Editor
# 249 = changed/approved by GFis
# 250 = approved by GFis, Ref -> Link
# 341 = jonathanwellons.com
# 342 = email to Michael Somos, somos.crg4.com is down
# 343 = temporarily set on hold, cf. email http://matwbn.icm.edu.pl
# 344 = trottermath.net
# 345 = /~cos/% of F. Ruskey
# 350 = unknown
# 447 = catched by navigationshilfe.t-online.de, 404 in reality
#-----------------------------------------------------------
# 			by Richard J. Mathar 2018-12-13
# A002858	248	0007    Philip Gibbs    http:// http
# A146768	248	0002    Helmes B.       http:// http
# A191093	248	0001    Wikipedia       http:// http
# A238537	248	0003    Wikipedia       http:// http
# A238602	248	0005    Wikipedia       http:// http
# A241276	248	0002    Wikipedia       http:// http
# A265580	248	0001    D. Einstein     http:// http
# A265582	248	0001    D. Einstein     http:// http 
# 			access='2018-12-19 11:32:50'
# A293059	249	bad IP address
# A319876	249	trivial
# A320523	249	triple https://
# A097566	249	Somos
# A017987	249	http://www.math.hmc.edu/seniorthesis/archives/2013/jpeebles/jpeebles-2013-thesis-poster.pdf References -> Links
# A106706	249	https://web.archive.org/web/20071009070537/http://bearcastle.com/blog/?p=596
# A066226	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066228	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066238	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066239	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066240	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066242	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066245	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066361	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066363	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066365	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066367	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A066573	249	J. Pe, <a href="http://www.numeratus.netfperfect/fperfect.html">On a Generalization of Perfect Numbers</a>, J. Rec. Math., 31(3) (2002-2003), 168-172.
# A085682	249	Numbers n such that n^n-(n-1)^n is prime. done 2018-12-18
# A140393	249	replaced by Wayback link
# A078402	249	space in Wolfram link
# A102705	249	ding-bong, from A102701
# A238695	247	was ok
# A282529	247	was ok
# 
# A258142	248	double "http://" wolfram
# A219388	247	spaces, The Internet database of periodic tables
# A278035	247	space and personal path
# A034695	249	hyphen missing
# A008425	249	space in URL, + ISBN
# A008364	249	space in URL
# A103377	247	Allouche
# A135209	247	D'Agapeyeff cipher 2 links
# A096560	247	INTEL FORTRAN language reference
# A108536	200	US Treasury returned '415'
# A084427	200	Scienceworld, Easter, Ascension Day in April
# A258882	200	451	... due to legal reasons - asked the other editors
# A066720	200	Google Groups
# A068369	200	Google Groups
# A088749	200	arXiv link
# A286349	200	arXiv link
# A127836	200	Mathworld link
# A065125	200	numeratus.net/just/just.html
# A141618	200	.sa King Fahd University
# A145105	200	Huen, .sg, Wayback
# A094216	200	TLD .yu -> .rs
# A020701	200	TLD .yu -> .rs
# A116157	200	.th - takes a while
# A236228	200	.th - unspecific
# A106806	200	.nu, Warholm Danish kings
# A048987	200	.nu, Perft
# A119869	200	.nu 2x
# A070730	200	.int -> .eu European coins
# A201488	200	2 links + 1 ref.
# A001597	200	Dincer .7z
# A072359	200	S. Whitechapel  www.geocities.com/aladgyma/articles/scimaths/pseudo.htm
# A096339	200	S. Whitechapel  www.geocities.com/aladgyma/articles/scimaths/pseudo.htm
# A096660	200	S. Whitechapel  www.geocities.com/aladgyma/articles/scimaths/pseudo.htm
# A065379	200	William Rex Marshall, Palindromic squares with a prime root
# A006516	200	Link to AMS too long
# A046180	200	link to Google Books too long
# A059255	200	link to Google Books too long
# A066413	200	link to Google Books too long, could be replaced
# A225488	200	link to Google Books too long
# A234319	200	link to Google Books too long
# A242497	200	link to Google Books too long
# A078125	248	www.uni-vt.bg/showfullpub.asp?u=32&amp;fn=AACCTMP.pdf
# A101223	247	debian.fmi.uni-sofia.bg/~sirbasil/factorsgn4.html <tintschev@phys.uni-sofia.bg>
# A101259	247	debian.fmi.uni-sofia.bg/~sirbasil/factorsgn4.html
# A101260	247	debian.fmi.uni-sofia.bg/~sirbasil/factorsgn4.html
# A125792	249	www.uni-vt.bg/showfullpub.asp?u=32&amp;fn=AACCTMP.pdf
# A003035	247	email zhao.hui.du@gmail.com
# A006065	247	email 
# A060315	247	email 
# A075441	247	email 
# A146974	247	email 
# A172992	247	email 
# A181784	247	email 
# A137591	249	.bg
# A031436	248	Betten and Betten
# A130510	249	Elkies ABC
# A006752	249	Plouffe IP address
# A054391	249	Mansour
# A008297	248	Mansour-Schork
# A006012	249	Broken link repaired (without "/new")
# A078482	249	Broken link repaired (without "/new")
# A103209	249	without "/new"
# A220875	249	without "/new"
# A220876	249	without "/new"
# A220877	249	without "/new"
# A080993	248	The National Scrabble Association dissolved on July 1, 2013.
# A080994	248	The National Scrabble Association dissolved on July 1, 2013.
# A046005	249	Arno
# A046007	249	Arno
# A046009	249	Arno
# A046011	249	Arno
# A046013	249	Arno
# A046015	249	Arno
# A191410	249	Steven Arno, M. L. Robinson and Ferrel S. Wheeler, <a href="http://matwbn.icm.edu.pl/ksiazki/aa/aa83/aa8341.pdf">Imaginary quadratic fields with small odd class number</a>, Acta Arithm. 83.4 (1998), 295-330
# A117633	249	Self-avoiding walks, Manhattan
# A085714	250	Bart de Smit
# A085153	249	Abderrahmane Nitaj, <a href="https://nitaj.users.lmno.cnrs.fr/abc.html">The ABC conjecture homepage</a>
# A120498	249	Nitaj ABC conjecture
# A147638	249	Nitaj ABC conjecture
# A147639	249	Nitaj ABC conjecture
# A190846	249	Nitaj ABC conjecture
# A252493	249	Nitaj ABC conjecture
# A004204	249	R. L. Graham and D. H. Lehmer, <a href="http://www.math.ucsd.edu/~ronspubs/76_07_schurs_matrix.pdf">ON THE PERMANENT OF SCHUR'S MATRIX</a>, J. Australian Math. Soc., 21A (1976), 487-497.
# A004205	249	"
# A004206	249	"
# A004246	249	"
# A147679	249	"
# A230582	249	Numberphile video Nepal Flag
# A057896	249	Numberphile video birth years
# A107452	249	http://preprinti.imfm.si/PDF/00939.pdf  Marko Boben
# A107453	249	http://preprinti.imfm.si/PDF/00939.pdf 
# A107454	249	http://preprinti.imfm.si/PDF/00939.pdf 
# A107455	249	http://preprinti.imfm.si/PDF/00939.pdf 
# A107456	249	http://preprinti.imfm.si/PDF/00939.pdf 
# A107457	249	http://preprinti.imfm.si/PDF/00939.pdf 
# A107459	249	http://preprinti.imfm.si/PDF/00939.pdf 
# A107460	249	http://preprinti.imfm.si/PDF/00939.pdf    
# A060645	247	jpr2718@gmail.com 
# A114046	247	jpr2718@gmail.com 
# A114047	247	jpr2718@gmail.com 
# A114048	247	jpr2718@gmail.com 
# A114049	247	jpr2718@gmail.com 
# A114050	247	jpr2718@gmail.com 
# A114051	247	jpr2718@gmail.com 
# A114052	247	jpr2718@gmail.com
# A241298	241	HyperCalc 
# A243913	241	HyperCalc 
# A246564	241	HyperCalc
#----------------------------2019-01-02
# A133802	249	Marek Wolf
# A099172	249	Binary strings without zigzags
# A225694	249	FROM SEQUENCES TO POLYNOMIALS AND BACK, VIA OPERATOR ORDERINGS
# A225695	249	FROM SEQUENCES TO POLYNOMIALS AND BACK, VIA OPERATOR ORDERINGS
# A138386	249	Knuth Fasc. 3b
# A143413	249	Apery
# A052894	249	PNAS Chen
# A018819	241	paper110.pdf	x
# A096443	249	apf7.pdf	x
# A238975	249	apf7.pdf	x
# A277120	249	apf7.pdf	x
# A277130	249	apf7.pdf	x
# A023871	249	104767415	1047674152
# A085826	249	contfrac.htm
# A085827	249	contfrac.htm
# A085826	249	herk_num.htm
# A085827	249	herk_num.htm
# A296506	249	WP7_2017_03.pdf	WP7_2017_03_________.pdf
# A025018	249	goldbach.htm	x
# A025018	249	g-en.html
# A123136	249	intcontest.pdf
# A123137	249	intcontest.pdf
# A123138	249	intcontest.pdf
# A200214	249	Factorizations.pdf
# # ME: Polynexus Numbers and other mathematical wonders
# # http://members.fortunecity.fr/polynexus/index.html
# # http://www.fortunecity.fr/polynexus/index.html
# # -> https://web.archive.org/web/20040920090251/http://members.fortunecity.fr:80/polynexus/index.html
# A202155	249	20006851_577.pdf
# A202156	249	20006851_577.pdf
# A115995	249	spt-parity.pdf
# A058133	249	*
# A151823	249	*
# A014221	249	*
#---------------------------2018-01-03
# A008300	248	LabelledEnumeration.pdf
# A224179	249	GWILF2
# A224180	249	GWILF2
# A224181	249	GWILF2
# A224182	249	GWILF2
# A151975	249	*   Floretion Online Multiplier
# A100213	249	*   Floretion Online Multiplier
# A108930	249	*   Floretion Online Multiplier
# A117153	249	*	Floretion Online Multiplier
# A076129	249	*	[1]
# A101592	249	*	Lists small
# A051254	241	A3n.html
# A060699	241	A3n.html
# A068028	249	facts.html
# A052491	249	*
# A269323	241	tmmp-2015-0040.xml
# A277534	249	pythag.html
# A046081	249	*	proposed 
# A160535	249	*	proposed 
# A172344	249	NumberFactorsTotientFunction.htm	.aspx
# A007647	249	status.html	http://guenter.loeh.name/gc/status.html
# A240234	249	status.html	http://guenter.loeh.name/gc/status.html
# A054873	249	dm040103.abs.html	Elena Barcucci, Alberto Del Lungo, Elisa Pergola, Renzo Pinzani, <a href="https://hal.inria.fr/hal-00958943">Permutations avoiding an increasing number of length-increasing forbidden subsequences</a>, Discrete MAthematics and Theoretical Computer Science 4, 2000, 31-44
# A054872	249	dm040103.abs.html
# # A006318	249	dm040103.abs.html  - multi-issues
# A135709	249	cardcolm200803.html
# A062991	249	ppt.pdf	was https
# # A009766	249	ppt.pdf	- postponed, Dejter also
# A093700	249	1046889587
# A102537	249	750317016.html?FMT
# A054589	249	publication.html
# A069942	249	40-1-3.pdf Joseph L. Pe
# A253057	249	base.pdf
# A253058	249	base.pdf
# A074664	249	soda05_suffixarray.pdf
# A074664	249	hadamard.pdf
# A113871	249	hadamard.pdf
# A099168	249	s46eisenko.html
# A094867	249	CA_history.pdf
# A133028	249	*	http://www.polrimos.com/http://www.polprimos.com
# A000296	249	JohnsonThesis.pdf
#------------------2018-01-04
# A160535	245	?IDDOC	Watson, G. N., <a href="http://www.digizeitschriften.de/dms/resolveppn/?PID=GDZPPN002174499">Ramanujans Vermutung ueber Zerfaellungsanzahlen.</a> J. Reine Angew. Math. (Crelle), 179 (1938), 97-128.
# A002300	249	?IDDOC	Same change was reviewed and approved in A160535.
# A160458	249	?IDDOC	
# A160459	249	?IDDOC	
# A160460	249	?IDDOC	
# A160461	249	?IDDOC	
# A160462	249	?IDDOC	
# A160463	249	?IDDOC	
# A160506	249	?IDDOC	
# A160521	249	?IDDOC	
# A160524	249	?IDDOC	
# A160534	249	?IDDOC	
A208356	249	show_file.php?soubor_id=920360
A003043	249	znps_mat_stos_04_2014_str_005-016.pdf
A180026	249	znps_mat_stos_04_2014_str_005-016.pdf
A001443	249	starter.pdf
A006204	249	starter.pdf
# A003111	249	cm	Jieh Hsiang, Yuhpyng Shieh, Yaochiang Chen, <a href="https://www.researchgate.net/publication/2568740_The_Cyclic_Complete_Mappings_Counting_Problems">Cyclic complete mappings counting problems</a>, National Taiwan University, Taipei, April 2003
A006204	245	cm	Jieh Hsiang, Yuhpyng Shieh, Yaochiang Chen, <a href="https://www.researchgate.net/publication/2568740_The_Cyclic_Complete_Mappings_Counting_Problems">Cyclic complete mappings counting problems</a>, National Taiwan University, Taipei, April 2003
# A071607	249	cm	Jieh Hsiang, Yuhpyng Shieh, Yaochiang Chen, <a href="https://www.researchgate.net/publication/2568740_The_Cyclic_Complete_Mappings_Counting_Problems">Cyclic complete mappings counting problems</a>, National Taiwan University, Taipei, April 2003
# A071608	249	cm	Jieh Hsiang, Yuhpyng Shieh, Yaochiang Chen, <a href="https://www.researchgate.net/publication/2568740_The_Cyclic_Complete_Mappings_Counting_Problems">Cyclic complete mappings counting problems</a>, National Taiwan University, Taipei, April 2003
# 
A071706	249	cm	Jieh Hsiang, Yuhpyng Shieh, Yaochiang Chen, <a href="https://www.researchgate.net/publication/2568740_The_Cyclic_Complete_Mappings_Counting_Problems">Cyclic complete mappings counting problems</a>, National Taiwan University, Taipei, April 2003

