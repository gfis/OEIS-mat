__DATA__
A211795		Number of (w,x,y,z) with all terms in {1,...,n} and w*x < 2*y*z.		203
0, 1, 11, 58, 177, 437, 894, 1659, 2813, 4502, 6836, 10008, 14121, 19449, 26117, 34372, 44422, 56597, 71044, 88160, 108115, 131328, 158074, 188773, 223604, 263172, 307719, 357715, 413493, 475690, 544480, 620632, 704381, 796413 (list; graph; refs; listen; history; text; internal format)
OFFSET	
0,3
COMMENTS	
a(n) + A211809(n) = n^4.
Each sequence in the following guide counts 4-tuples
(w,x,y,z) such that the indicated relation holds and the four numbers w,x,y,z are in {1,...,n}.  
The notation "m div" means that m divides every term of the sequence.
A211058 ... wx <= yz
A211787 ... wx <= 2yz
A211795 ... wx < 2yz
A211797 ... wx > 2yz
A211809 ... wx >= 2yz
A211812 ... wx <= 3yz
A211917 ... wx < 3yz
A211918 ... wx > 3yz
A211919 ... wx >= 3yz
A211920 ... 2wx < 3yz
A211921 ... 2wx <= 3yz
A211922 ... 2wx > 3yz
A211923 ... 2wx >= 3yz
A212019 ... wx = 2yz ..... 2 div
A212020 ... wx = 3yz ..... 2 div
A212021 ... 2wx = 3yz .... 2 div
A212047 ... wx = 4yz
A212048 ... 3wx = 4yz .... 2 div
A212049 ... wx = 5yz ..... 2 div
A212050 ... 2wx = 5yz .... 2 div
A212051 ... 3wx = 5yz .... 2 div
A212052 ... 4wx = 5yz .... 2 div
A209978 ... wx = yz + 1 .. 2 div
A212053 ... wx <= yz + 1
A212054 ... wx > yz + 1
A212055 ... wx <= yz + 2
A212056 ... wx > yz + 2
A197168 ... wx = yz + 2 .. 2 div
A061201 ... w = xyz
A212057 ... w < xyz
A212058 ... w >= xyz
A212059 ... w = xyz - 1
A212060 ... w = xyz - 2
A212061 ... wx = (yz)^2
A212062 ... w^2 = xyz
A212063 ... w^2 < xyz
A212064 ... w^2 >= xyz
A212065 ... w^2 <= xyz
A212066 ... w^2 > xyz
A212067 ... w^3 = xyz
A002623 ... w = 2x + y + z
A006918 ... w = 2x + 2y + z
A000601 ... w = x + 2y + 3z (except for initial 0's)
A212068 ... 2w = x + y + z
A212069 ... 3w = x + y + z (w = average{x,y,z})
A212088 ... 3w < x + y + z
A212089 ... 3w >= x + y + z
A212090 ... w < x + y + z
A000332 ... w >= x + y + z
A212145 ... w < 2x + y + z
A001752 ... w >= 2x + y + z
A001400 ... w = 2x +3y + 4z
A005900 ... w = -x + y + z
A192023 ... w = -x + y + z + 2
A212091 ... w^2 = x^2 + y^2 + z^2 ... 3 div
A212087 ... w^2 + x^2 = y^2 + z^2
A212092 ... w^2 < x^2 + y^2 + z^2
A212093 ... w^2 <= x^2 + y^2 + z^2
A212094 ... w^2 > x^2 + y^2 + z^2
A212095 ... w^2 >= x^2 + y^2 + z^2
A212096 ... w^3 = x^3 + y^3 + z^3 ... 6 div
A212097 ... w^3 < x^3 + y^3 + z^3
A212098 ... w^3 <= x^3 + y^3 + z^3
A212099 ... w^3 > x^3 + y^3 + z^3
A212100 ... w^3 >= x^3 + y^3 + z^3
A212101 ... wx^2 = yz^2
A212102 ... 1/w = 1/x + 1/y + 1/z
A212103 ... 3/w = 1/x + 1/y + 1/z; w = h.m. of {x,y,z}
A212104 ... 3/w >= 1/x + 1/y + 1/z; w >= h.m.
A212105 ... 3/w < 1/x + 1/y + 1/z; w < h.m.
A212106 ... 3/w > 1/x + 1/y + 1/z; w > h.m.
A212107 ... 3/w <= 1/x + 1/y + 1/z; w <= h.m.
A212133 ... median(w,x,y,z) = mean(w,x,y,z)
A212134 ... median(w,x,y,z) <= mean(w,x,y,z)
A212135 ... median(w,x,y,z) > mean(w,x,y,z)
A212241 ... wx + yz > n
A212243 ... 2wx + yz = n
A212244 ... w = xyz - n
A212245 ... w = xyz - 2n
A212246 ... 2w = x + y + z - n
A212247 ... 3w = x + y + z + n
A212249 ... 3w < x + y + z + n
A212250 ... 3w >= x + y + z + n
A212251 ... 3w = x + y + z + n + 1
A212252 ... 3w = x + y + z + n + 2
A212254 ... w = x + 2y + 3z - n
A212255 ... w^2 = mean(x^2, y^2, z^2)
A212256 ... 4/w = 1/x + 1/y +1/z + 1/n
In the list above, if the relation in the second column is of the form "w rel ax + by + cz" then the sequence is linearly recurrent.  
In the list below, the same is true for expressions involving more than one relation.
A000332 ... w < x <= y < z .... C(n,4)
A000914 ... w < x <= y < z .... Stirling 1st kind
A000914 ... w < x <= y >= z ... Stirling 1st kind
A050534 ... w < x < y >= z .... tritriangular
A001296 ... w <= x <= y >= z .. 4-dim pyramidal
A006322 ... x < x > y >= z
A002418 ... w < x >= y < z
A050534 ... w < x >=y >= z
A212415 ... w < x >= y <= z
A001296 ... w < x >= y <= z
A212246 ... w <= x > y <= z
A006322 ... w <= x >= y <= z
A212501 ... w > x < y >= z
A212503 ... w < 2x and y < 2z ..... A (note below)
A212504 ... w < 2x and y > 2z ..... A
A212505 ... w < 2x and y >= 2z .... A
A212506 ... w <= 2x and y <= 2z ... A
A212507 ... w < 2x and y <= 2z .... B
A212508 ... w < 2x and y < 3z ..... C
A212509 ... w < 2x and y <= 3z .... C
A212510 ... w < 2x and y > 3z ..... C
A212511 ... w < 2x and y >= 3z .... C
A212512 ... w <= 2x and y < 3z .... C
A212513 ... w <= 2x and y <= 3z ... C
A212514 ... w <= 2x and y > 3z .... C
A212515 ... w <= 2x and y >= 3z ... C
A212516 ... w > 2x and y < 3z ..... C
A212517 ... w > 2x and y <= 3z .... C
A212518 ... w > 2x and y > 3z ..... C
A212519 ... w > 2x and y >= 3z .... C
A212520 ... w >= 2x and y < 3z .... C
A212521 ... w >= 2x and y <= 3z ... C
A212522 ... w >= 2x and y > 3z .... C
A212523 ... w + x < y + z
A212560 ... w + x <= y + z
A212561 ... w + x = 2y + 2z
A212562 ... w + x < 2y + 2z ....... B
A212563 ... w + x <= 2y + 2z ...... B
A212564 ... w + x > 2y + 2z ....... B
A212565 ... w + x >= 2y + 2z ...... B
A212566 ... w + x = 3y + 3z
A212567 ... 2w + 2x = 3y + 3z
A212570 ... |w - x| = |x - y| + |y - z|
A212571 ... |w - x| < |x - y| + |y - z| ... B ... 4 div
A212572 ... |w - x| <= |x - y| + |y - z| .. B
A212573 ... |w - x| > |x - y| + |y - z| ... B ... 2 div
A212574 ... |w - x| >= |x - y| + |y - z| .. B
A212575 ... 2|w - x| = |x - y| + |y - z|
A212576 ... |w - x| = 2|x - y| + 2|y - z|
A212577 ... |w - x| = 2|x - y| - |y - z|
A212578 ... 2|w - x| = |x - y| - |y - z|
A212579 ... min{|w-x|,|w-y|} = min{|x-y|,|x-z|}
A212692 ... w = |x - y| + |y - z| ............... 2 div
A212568 ... w < |x - y| + |y - z| ............... 2 div
A212573 ... w <= |x - y| + |y - z| .............. 2 div
A212574 ... w > |x - y| + |y - z|
A212575 ... w >= |x - y| + |y - z|
A212676 ... w + x = |x - y| + |y - z| ......... H
A212677 ... w + y = |x - y| + |y - z|
A212678 ... w + x + y = |x - y| + |y - z|
A006918 ... w + x + y + z = |x - y| + |y - z| . H
A212679 ... |x - y| = |y - z| ................. H
A212680 ... |x - y| = |y - z| + 1 ..............H 2 div
A212681 ... |x - y| < |y - z| ................... 2 div
A212682 ... |x - y| >= |y - z|
A212683 ... |x - y| = w + |y - z| ............... 2 div
A212684 ... |x - y| = n - w + |y - z|
A212685 ... |w - x| = w + |y - z|
A186707 ... |w - x| < w + |y - z| ... (Note D)
A212714 ... |w - x| >= w + |y - z| .......... H . 2 div
A212686 ... 2*|w - x| = n + |y - z| ............. 4 div
A212687 ... 2*|w - x| < n + |y - z| ......... B
A212688 ... 2*|w - x| < n + |y - z| ......... B . 2 div
A212689 ... 2*|w - x| > n + |y - z| ......... B . 2 div
A212690 ... 2*|w - x| <= n + |y - z| ........ B
A212691 ... w + |x - y| = |x - z| + |y - z| . E . 2 div
...
In the above lists, all the terms of (w,x,y,z) are in {1,...,n}, 
but in the next lists they are all in {0,...,n}, 
and sequences are all linearly recurrent.
  R=range{w,x,y,z}=max{w,x,y,z}-min{w,x,y,z}.
A212740 ... max{w,x,y,z} < 2*min{w,x,y,z} .... A
A212741 ... max{w,x,y,z} >= 2*min{w,x,y,z} ... A
A212742 ... max{w,x,y,z} <= 2*min{w,x,y,z} ... A
A212743 ... max{w,x,y,z} > 2*min{w,x,y,z} .... A . 2 div
A212744 ... w=range (=max-min) ............... E
A212745 ... w=max{w,x,y,z} - 2*min{w,x,y,z}
A212746 ... R is in {w,x,y,z} ................ E
A212569 ... R is not in {w,x,y,z} ............ E
A212749 ... w=R or x<R or y<R or z<R ......... A
A212750 ... w=R or x=R or y<R or z<R ......... A
A212751 ... w=R or x=R or y<R or z<R ......... A
A212752 ... w<R or x<R or y<R or z>R ......... A
A212753 ... w<R or x<R or y>R or z>R ......... D
A212754 ... w<R or x>R or y>R or z>R ......... D
A002415 ... w = x + R ........................ D
A212755 ... |w - x| = R ...................... D
A212756 ... 2w = x + R
A212757 ... 2w = R
A212758 ... w = floor(R/2)
A002413 ... w = floor((x+y+z/2))
A212759 ... w, x, y are even
A212760 ... w is even and x = y + z .......... E
A212761 ... w is odd and x and y are even .... F . 2 div
A212762 ... w and x are odd y is even ........ F . 2 div
A212763 ... w, x, y are odd .................. F
A212764 ... w, x, y are even and z is odd .... F
A030179 ... w and x are even and y and z odd
A212765 ... w is even and x,y,z are odd ...... F
A212766 ... w is even and x is odd ........... A . 2 div
A212767 ... w and x are even and w+x=y+z ..... E
A212889 ... R is even ........................ A
A212890 ... R is odd ......................... A . 2 div
A212742 ... w-x, x-y, y-z are all even ....... A
A212892 ... w-x, x-y, y-z are all odd ........ A
A212893 ... w-x, x-y, y-z have same parity ... A
A005915 ... min{|w-x|, |x-y|, |y-z|} = 0
A212894 ... min{|w-x|, |x-y|, |y-z|} = 1
A212895 ... min{|w-x|, |x-y|, |y-z|} = 2
A179824 ... min{|w-x|, |x-y|, |y-z|} > 0
A212896 ... min{|w-x|, |x-y|, |y-z|} <= 1
A212897 ... min{|w-x|, |x-y|, |y-z|} > 1
A212898 ... min{|w-x|, |x-y|, |y-z|} <= 2
A212899 ... min{|w-x|, |x-y|, |y-z|} > 2
A212901 ... |w-x| = |x-y| = |y-z|
A212900 ... |w-x|, |x-y|, |y-z| are distinct . G
A212902 ... |w-x| < |x-y| < |y-z| ............ G
A212903 ... |w-x| <= |x-y| <= |y-z| .......... G
A212904 ... |w-x| + |x-y| + |y-z| = n ........ H
A212905 ... |w-x| + |x-y| + |y-z| = 2n ....... H
...
Note 
# A212503-A212506 (and others) have these recurrence coefficients: 
# A: 2,2,-6,0,6,-2,-2,1.
# B: 3,-1,-5,5,1,-3,1
# C: 0,2,2,-1,-4,0,2,0,-2,0,4,1,-2,-2,0,1
# D: 4,-5,0,5,-4,1
# E: 1,3,-3,-3,3,1,-1
# F: 1,4,-4,-6,6,4,-4,-1,1
# G: 2,1,-3,-1,1,3,-1,-2,1
# H: 2,1,-4,1,2,-1
EXAMPLE	
a(2)=11 counts these (w,x,y,z): (1,1,1,1), (1,1,1,2), (1,1,2,1), (2,1,2,1), (2,1,1,2), (1,2,2,1), (1,2,1,2), (1,1,2,2), (1,2,2,2), (2,1,2,2), (2,2,2,2).
MATHEMATICA	
t = Compile[{{n, _Integer}}, Module[{s = 0},
    (Do[If[w*x < 2 y*z, s = s + 1], {w, 1, #},
      {x, 1, #}, {y, 1, #}, {z, 1, #}] &[n]; s)]];
Map[t[#] &, Range[0, 40]] (* A211795 *)
(* Peter J. C. Moses, Apr 13 2012 *)
CROSSREFS	
Cf. A210000, A212959.
Clark Kimberling, Apr 27 2012
