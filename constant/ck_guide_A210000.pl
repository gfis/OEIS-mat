
login
The OEIS Foundation is supported by donations from users of the OEIS and by a grant from the Simons Foundation.
 
Logo
 		Hints
(Greetings from The On-Line Encyclopedia of Integer Sequences!)
A210000		Number of unimodular 2 X 2 matrices having all terms in {0,1,...,n}.		101
0, 6, 14, 30, 46, 78, 94, 142, 174, 222, 254, 334, 366, 462, 510, 574, 638, 766, 814, 958, 1022, 1118, 1198, 1374, 1438, 1598, 1694, 1838, 1934, 2158, 2222, 2462, 2590, 2750, 2878, 3070, 3166, 3454, 3598, 3790, 3918, 4238, 4334, 4670, 4830 (list; graph; refs; listen; history; text; internal format)
OFFSET	
0,2
COMMENTS	
a(n) is the number of 2 X 2 matrices having all terms in {0,1,...,n} and inverses with all terms integers.
Most sequences in the following guide count 2 X 2 matrices having all terms contained in the domain shown in column 2 and determinant d or permanent p or sum s of terms as indicated in column 3.
A059306 ... {0,1,...,n} ..... d=0
A171503 ... {0,1,...,n} ..... d=1
A210000 ... {0,1,...,n} .... |d|=1
A209973 ... {0,1,...,n} ..... d=2
A209975 ... {0,1,...,n} ..... d=3
A209976 ... {0,1,...,n} ..... d=4
A209977 ... {0,1,...,n} ..... d=5
A210282 ... {0,1,...,n} ..... d=n
A210283 ... {0,1,...,n} ..... d=n-1
A210284 ... {0,1,...,n} ..... d=n+1
A210285 ... {0,1,...,n} ..... d=floor(n/2)
A210286 ... {0,1,...,n} ..... d=trace
A280588 ... {0,1,...,n} ..... d=s
A106634 ... {0,1,...,n} ..... p=n
A210288 ... {0,1,...,n} ..... p=trace
A210289 ... {0,1,...,n} ..... p=(trace)^2
A280934 ... {0,1,...,n} ..... p=s
A210290 ... {0,1,...,n} ..... d>=0
A183761 ... {0,1,...,n} ..... d>0
A210291 ... {0,1,...,n} ..... d>n
A210366 ... {0,1,...,n} ..... d>=n
A210367 ... {0,1,...,n} ..... d>=2n
A210368 ... {0,1,...,n} ..... d>=3n
A210369 ... {0,1,...,n} ..... d is even
A210370 ... {0,1,...,n} ..... d is odd
A210371 ... {0,1,...,n} ..... d is even and >=0
A210372 ... {0,1,...,n} ..... d is even and >0
A210373 ... {0,1,...,n} ..... d is odd and >0
A210374 ... {0,1,...,n} ..... s=n+2
A210375 ... {0,1,...,n} ..... s=n+3
A210376 ... {0,1,...,n} ..... s=n+4
A210377 ... {0,1,...,n} ..... s=n+5
A210378 ... {0,1,...,n} ..... t is even
A210379 ... {0,1,...,n} ..... t is odd
A211031 ... {0,1,...,n} ..... d is in [-n,n]
A211032 ... {0,1,...,n} ..... d is in (-n,n)
A211033 ... {0,1,...,n} ..... d=0 (mod 3)
A211034 ... {0,1,...,n} ..... d=1 (mod 3)
A209974 = (A209973)/4
A134506 ... {1,2,...,n} ..... d=0
A196227 ... {1,2,...,n} ..... d=1
A209979 ... {1,2,...,n} .... |d|=1
A197168 ... {1,2,...,n} ..... d=2
A210001 ... {1,2,...,n} ..... d=3
A210002 ... {1,2,...,n} ..... d=4
A210027 ... {1,2,...,n} ..... d=5
A209978 = (A196227)/2
A209980 = (A197168)/2
A211053 ... {1,2,...,n} ..... d=n
A211054 ... {1,2,...,n} ..... d=n-1
A211055 ... {1,2,...,n} ..... d=n+1
A055507 ... {1,2,...,n} ..... p=n
A211057 ... {1,2,...,n} ..... d is in [0,n]
A211058 ... {1,2,...,n} ..... d>=0
A211059 ... {1,2,...,n} ..... d>0
A211060 ... {1,2,...,n} ..... d>n
A211061 ... {1,2,...,n} ..... d>=n
A211062 ... {1,2,...,n} ..... d>=2n
A211063 ... {1,2,...,n} ..... d>=3n
A211064 ... {1,2,...,n} ..... d is even
A211065 ... {1,2,...,n} ..... d is odd
A211066 ... {1,2,...,n} ..... d is even and >=0
A211067 ... {1,2,...,n} ..... d is even and >0
A211068 ... {1,2,...,n} ..... d is odd and >0
A209981 ... {-n,....,n} ..... d=0
A209982 ... {-n,....,n} ..... d=1
A209984 ... {-n,....,n} ..... d=2
A209986 ... {-n,....,n} ..... d=3
A209988 ... {-n,....,n} ..... d=4
A209990 ... {-n,....,n} ..... d=5
A211140 ... {-n,....,n} ..... d=n
A211141 ... {-n,....,n} ..... d=n-1
A211142 ... {-n,....,n} ..... d=n+1
A211143 ... {-n,....,n} ..... d=n^2
A211140 ... {-n,....,n} ..... p=n
A211145 ... {-n,....,n} ..... p=trace
A211146 ... {-n,....,n} ..... d in [0,n]
A211147 ... {-n,....,n} ..... d>=0
A211148 ... {-n,....,n} ..... d>0
A211149 ... {-n,....,n} ..... d<0 or d>0
A211150 ... {-n,....,n} ..... d>n
A211151 ... {-n,....,n} ..... d>=n
A211152 ... {-n,....,n} ..... d>=2n
A211153 ... {-n,....,n} ..... d>=3n
A211154 ... {-n,....,n} ..... d is even
A211155 ... {-n,....,n} ..... d is odd
A211156 ... {-n,....,n} ..... d is even and >=0
A211157 ... {-n,....,n} ..... d is even and >0
A211158 ... {-n,....,n} ..... d is odd and >0
LINKS	
Table of n, a(n) for n=0..44.
FORMULA	
a(n) = 2*A171503(n).
EXAMPLE	
a(2)=6 counts these matrices (using reduced matrix notation):
(1,0,0,1), determinant = 1, inverse = (1,0,0,1)
(1,0,1,1), determinant = 1, inverse = (1,0,-1,1)
(1,1,0,1), determinant = 1, inverse = (1,-1,0,1)
(0,1,1,0), determinant = -1, inverse = (0,1,1,0)
(0,1,1,1), determinant = -1, inverse = (-1,1,1,0)
(1,1,1,0), determinant = -1, inverse = (0,1,1,-1)
MATHEMATICA	
a = 0; b = n; z1 = 50;
t[n_] := t[n] = Flatten[Table[w*z - x*y, {w, a, b}, {x, a, b}, {y, a, b}, {z, a, b}]]
c[n_, k_] := c[n, k] = Count[t[n], k]
Table[c[n, 0], {n, 0, z1}]  (* A059306 *)
Table[c[n, 1], {n, 0, z1}]  (* A171503 *)
2 %                         (* A210000 *)
Table[c[n, 2], {n, 0, z1}]  (* A209973 *)
%/4                         (* A209974 *)
Table[c[n, 3], {n, 0, z1}]  (* A209975 *)
Table[c[n, 4], {n, 0, z1}]  (* A209976 *)
Table[c[n, 5], {n, 0, z1}]  (* A209977 *)
CROSSREFS	
Cf. A171503.
See also the very useful list of cross-references in the Comments section.
Sequence in context: A345332 A183023 A284246 * A134067 A024932 A273365
Adjacent sequences:  A209997 A209998 A209999 * A210001 A210002 A210003
KEYWORD	
nonn
AUTHOR	
Clark Kimberling, Mar 16 2012
EXTENSIONS	
A209982 added to list in comment by Chai Wah Wu, Nov 27 2016
STATUS	
approved
Lookup | Welcome | Wiki | Register | Music | Plot 2 | Demos | Index | Browse | More | WebCam
Contribute new seq. or comment | Format | Style Sheet | Transforms | Superseeker | Recent
The OEIS Community | Maintained by The OEIS Foundation Inc.
License Agreements, Terms of Use, Privacy Policy. .
Last modified August 24 05:15 EDT 2021. Contains 346946 sequences. (Running on oeis4.)