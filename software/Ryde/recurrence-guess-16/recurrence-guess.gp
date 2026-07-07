\\ Copyright 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2024 Kevin Ryde
\\
\\ recurrence-guess.gp is free software; you can redistribute it and/or
\\ modify it under the terms of the GNU General Public License as published
\\ by the Free Software Foundation; either version 3, or (at your option)
\\ any later version.
\\
\\ recurrence-guess.gp is distributed in the hope that it will be useful,
\\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
\\ Public License for more details.
\\
\\ You should have received a copy of the GNU General Public License along
\\ with recurrence-guess.gp.  See the file COPYING.  If not, see
\\ <http://www.gnu.org/licenses/>.


\\ Usage: read("recurrence-guess.gp");    \\ loads pol-pfrac.gp too
\\        recurrence_guess([0, 1, 5, 19, 65, 211, 665, 2059, 6305, 19171]);
\\        =>
\\        prints a report
\\
\\ recurrence_guess(v) takes a vector of numbers (or a few other data types)
\\ and attempts to find a linear recurrence which generates them.  It prints
\\ a report of
\\
\\     * Recurrence factors
\\     * Characteristic polynomial
\\     * Generating function
\\     * Power expression, if possible
\\     * OEIS style "signature".
\\
\\
\\ Other Modules Required
\\ ----------------------
\\
\\ pol-pfrac.gp version 2,
\\       http://user42.tuxfamily.org/pari-pol-pfrac/index.html
\\
\\
\\ Values Length
\\ -------------
\\
\\ A recurrence of m terms requires minimum 2*m+1 many values to guess.
\\ The first 2*m determine the recurrence factors and 1 further value
\\ confirms it.  See the help string of variable
\\ "recurrence_guess_minimum_confirm" to adjust confirmation demanded.
\\
\\ If you know a maximum order m and give 2*m+1 values then something found
\\ at or below m will be correct.  You might know a maximum for example if
\\ values are from a set of m mutual recurrences or a state machine of m
\\ states.  For reference, a few common recurrence orders are
\\
\\     * power 2^n etc = order 1
\\     * polynomial to n^p = order p+1, eg. n^2 is order 3
\\     * cumulative = same or +1
\\     * term-wise sum of sequences <= sum of their orders
\\       (union of the characteristic polynomial roots)
\\     * term-wise product of two sequences <= product of their orders
\\       (cross-products of powers of the roots)
\\     * term-wise squaring = 2*order, cubing = 3*order, etc
\\
\\ When forming a complicated sum or cumulative total of some recurrences or
\\ polynomials, it's convenient to give numbers to the guesser and let it
\\ find powers or generating function, knowing that below the maximum order
\\ the guess will be right.
\\
\\ If you don't know a maximum order m then it's always possible initial
\\ values satisfy a recurrence but more values, if you had them, would not,
\\ or would need a longer recurrence.  If many confirming values pass the
\\ recurrence, meaning an order m with 2*m much smaller than the vector
\\ length #v, then that gives some confidence, but no proof.
\\
\\
\\ Coefficients Output
\\ -------------------
\\
\\ The output is a little rough and will change.  The intention is to show
\\ interesting forms, usually to be cut and pasted into code or a document
\\ if useful.
\\
\\ Recurrence coefficients are shown high to low and low to high, with
\\ pseudo-expressions to try to make the direction clear.
\\
\\     coefficients
\\      v[n-3]* [2, 0, 1] *v[n-1]  = v[n]
\\      v[n] =  v[n-1]* [1, 0, 2] *v[n-3]
\\
\\ The second line means v[n] == 1*v[n-1] + 0*v[n-2] + 2*v[n-3].  It's usual
\\ to write high to low this way for human readers.
\\
\\ Coefficients low to high can suit program code since the indices match a
\\ vector of values going low to high.  For example a scalar product
\\
\\      [2, 0, 1] * v[5..7]~ == v[8]
\\
\\
\\ Roots Output
\\ ------------
\\
\\ Roots of the characteristic polynomial are given since the values grow as
\\ powers of those (a sum like A*X^n + B*Y^n + C*Z^n).  The power expression
\\ uses those roots when they're exact (see Value Types below).
\\
\\ Currently the roots are shown only as some floating point digits as from
\\ polroots(), so are not shown as exact numbers.  Check the characteristic
\\ polynomial factorization to see whether some are rationals or quadratics.
\\
\\
\\ Generating Function Output
\\ --------------------------
\\
\\ A generating function (an "ordinary" generating function) is given as a
\\ rational function (ratio of two polynomials in x, as per type t_RFRAC) in
\\ plain and partial fractions form.  Generating functions are helpful for
\\ manipulating linear recurrences since they effectively represent all
\\ values of the sequence.
\\
\\ In the generating function factorizations, (1-x) in the denominator means
\\ cumulative of the rest of the gf.  Or conversely (1-x) in the numerator
\\ which means differences of the rest of the gf.
\\
\\ The partial fractions are the denominator polynomial factorized to a
\\ separate term each.  This helps when a recurrence is a sum of smaller
\\ recurrences, or recurrence plus a constant or periodic term.  Numerators
\\ could be either simpler or more complicated in the full or partial
\\ fractions.
\\
\\ Another use for partial fractions is to show what types of sequences
\\ might be summed to give values.  For example 1/(1-7*x)^2 indicates 7^n,
\\ or 1/(1-7*x)^2 indicates values 7^n and n*7^n.
\\
\\ If you have some sequences and would like constant multiples of them to
\\ sum to the values then try lindep() to find those constants.  lindep()
\\ can take a matrix of values, or a vector of vectors, or vector of
\\ polynomials.  But lindep() won't act on t_RFRACs, as of GP 2.13.x, so
\\ multiply t_RFRACs through by a common denominator to make plain
\\ polynomials if combining desired gfs.
\\
\\
\\ Power Expressions Output
\\ ------------------------
\\
\\ The power expression is derived from the gf partial fractions.  There's
\\ an internal check that what's shown does in fact give the values, but the
\\ mangling is slightly subtle so you might double check.  A form
\\
\\     vector_modulo([7,5,8],n)
\\
\\ means 7,5,8 according as n==0,1,2 mod 3 respectively, etc, per function
\\
\\     vector_modulo(v,i) = v[(i%#v)+1];
\\
\\ Periodic factors 7,5,8 like this are numerator terms of the gf partial
\\ fractions, though the gf partial fractions can break down to small terms
\\ where the periodic nature is not obvious.  The power expression combines
\\ terms of the same power and polynomial factor.
\\
\\ The power expression is written for index n=0 for the first value v[1].
\\ This corresponds to the generating function first term x^0.  If a start
\\ at n=1 or similar is desired then the suggestion is an initial dummy 0 in
\\ the input vector v.  This will probably show as an "initial exception"
\\ (see below) which can be ignored.
\\
\\ The power expression always uses positive base powers, and usually reals
\\ (depending on the input values type).  It's possible something like
\\ (-2)^k, and negate any odd periodic factors of it, could simplify.  But
\\ if a base appears in a few terms then for consistency you might prefer
\\ them all the same.
\\
\\ The power expression uses 3^floor(n/8) etc for half-power terms.  If
\\ there's periodic factors then it might be possible to simplify by
\\ changing floor to ceil, or shifting to say floor((n+3)/8).  But floor is
\\ printed for consistency since several terms might be similar.
\\
\\ Polynomial terms n^something use rational or periodic coefficients.
\\ Occasionally a result might be simplified by floor() or similar.  For
\\ example
\\
\\     recurrence_guess(vector(100,n,n--; ceil(n^2 / 3)))
\\     =>
\\     1/3 * n^2  + vector_modulo([0, 2/3, 2/3],n)
\\
\\ and you can notice the constants 0, 2/3, 2/3 push 1/3*n^2 up to
\\ ceil(1/3*n^2).  However, if a limit f(n)/n as n->infinity is wanted then
\\ the plain rational coefficient on the highest term (and periodic constant
\\ offsets) might be clearer.
\\
\\ Incidentally, floors of powers are also linear recurrences
\\
\\     recurrence_guess(vector(100,n,n--; floor(10^n/7)))
\\     =>
\\     1/7*10^n + vector_modulo([-1/7,-3/7,-2/7,-6/7,-4/7,-5/7],n)
\\
\\ The remainder 10^n mod 7 is the offset, and it is periodic since multiply
\\ 10 mod 7 goes through at most 6 different values mod 7 and then repeats.
\\ Similarly any rational factor.
\\
\\
\\ Initial Exceptions
\\ ------------------
\\
\\ If a few initial values don't satisfy the recurrence then they become low
\\ 0s in the recurrence factors.  For example
\\
\\     \\ exceptions then Fibonacci
\\     recurrence_guess([99, 99, 99, 1, 2, 3, 5, 8, 13, 21, 34]);
\\     =>
\\     v[n-5]* [0, 0, 0, 1, 1] *v[n-1]  = v[n]
\\
\\ In the gf partial fractions, the initial values become constant terms
\\ (not t_RFRACs), such as 98 + 99*x + 98*x^2.  Those terms are differences
\\ from what the recurrence extended backwards would have given.  The power
\\ expression shows initial exceptions explicitly.
\\
\\ For the number of values needed when guessing, each initial exception is
\\ 2 values (itself and 1 more) because it lengthens the recurrence terms by
\\ 1 and each recurrence term requires 2 values.  If guessing from just a
\\ few values then it's worth trying with initial suspected exceptions
\\ omitted.
\\
\\ High 0s in the recurrence factors are a "delay" in the recurrence.
\\ A simple example is
\\
\\     recurrence_guess([1,2,3, 10,20,30, 100,200,300]);
\\     =>
\\     v[n-3]* [10, 0, 0] *v[n-1]  = v[n]
\\     vector_modulo([1, 2, 3],n) * 10^floor(n/3)
\\
\\ Each term is 10* its third previous.  Repetitions of values (which are a
\\ linear recurrence) come out with a similar delay, eg.
\\
\\     recurrence_guess([1,1,1, 2,2,2, 4,4,4, 8,8,8]);
\\     =>
\\     v[n-3]* [2, 0, 0] *v[n-1]  = v[n]
\\
\\
\\ OEIS Output
\\ -----------
\\
\\ A link and formula of the form used in Sloane's Online Encyclopedia of
\\ Integer Sequences are shown,
\\
\\     %H <a href="/index/Rec#order_03">Index entries for linear recurrences with constant coefficients</a>, signature (1,0,2).
\\     %F a(n) = a(n-1) + 2*a(n-3).
\\
\\ The %H and %F tags are for OEIS "internal format" and should be
\\ disregarded if you use ordinary edit instead of edit internal format.
\\
\\ The %F formula is human readable and is the sort of thing desired in the
\\ FORMULAS section of a sequence.  If the formula holds only after some
\\ initial exceptions then the starting point is included,
\\
\\     %F a(n) = a(n-1) + 2*a(n-3) for n>=5.
\\
\\ In all cases the given data values are assumed to start with v[1] as
\\ "offset" term n=0, the same as the powers expressions noted above.  This
\\ makes no difference for the recurrence link or the formula, only at the
\\ "for n>=X" so check that's right.  (And in general double-check all by
\\ some second way, such as actually using the formula in some code.)
\\
\\
\\ Value Types
\\ -----------
\\
\\ Values can be any exact Pari/GP type,
\\
\\     * integers
\\     * rationals
\\     * complex numbers or quads with integer or rational parts
\\     * polynomials with any of those as coefficients
\\
\\ GP as of 2.13.x cannot mix quads of different discriminant or quads and
\\ complex numbers, so be sure all terms are compatible.
\\
\\ The factors in the recurrence will be the same type as the values
\\ usually.  All quads print as "w" in the usual way, so when cutting and
\\ pasting output be sure to change that to a desired name.
\\
\\ The gf partial fractions and the power expression also use the same type
\\ as the values.  For example on rational values, a gf shows say 1/(1-2*x^2)
\\ and the power expression is 2^floor(n/2), but if the values include a
\\ sqrt2 = quadgen(2*4) then the gf can go down to 1/(1+sqrt2*x) and
\\ 1/(1-sqrt2*x) and the power expression uses sqrt2^n.  Putting a factor
\\ of sqrt2 or I or similar through the values can induce the further
\\ breakdown if desired, though sometimes it makes periodic terms less
\\ clear.  Maybe there should be a better way to express a base type.
\\
\\ For complex and quads, it may be worth trying real and imaginary parts
\\ separately to see if they have simpler separate forms.  Powers like
\\ (3+4*I)^n won't simplify.  They have the same recurrence for real and
\\ imaginary parts (the two being a pair of Lucas sequences).
\\
\\ Values can be t_POL polynomials in any variable or variables other than
\\ "x" -- because x is used internally and for generating function output.
\\ In simple cases, the effect of t_POL values is to find a recurrence
\\ simultaneously satisfying the sequences of their separate coefficients.
\\ This might be useful if values are something parameterized and a
\\ recurrence or power for the general case is desired.  But it may be worth
\\ trying polynomial coefficients each separately to see if they simplify.
\\
\\ In more complicated cases, the recurrence coefficients are themselves
\\ polynomials.  For example powers of a symbol,
\\
\\     recurrence_guess(vector(10,n,n--; 's^n))
\\     =>
\\     v[n] =  v[n-1]* s
\\
\\ The generating function from such forms is shown factored in GP 2.11 and
\\ up, since factor() there accepts multi-variable polynomials.
\\
\\ Powers of more complicated polynomials can give a bi-variate generating
\\ function for a triangle.  For example if you didn't already know how the
\\ binomials in Pascal's triangle arise then try each row as a polynomial in
\\ variable "y",
\\
\\     recurrence_guess(vector(10,n,n--; sum(k=0,n, binomial(n,k)*y^k)))
\\     =>
\\     generating function 1/(1 - (y+1)*x)
\\     as powers  (y + 1)^n
\\
\\ Guess can also be tried on t_RFRAC generating functions for infintely
\\ long rows, again in some variable such as y.  Or of course gfs of columns
\\ likewise, differing only in which variable is which in the result.
\\ Or diagonals of a triangle similarly (whatever is convenient).
\\
\\
\\ Polynomial Sequences
\\ --------------------
\\
\\ Values from a polynomial expression like
\\
\\     n^2 + n + 1 = 1,3,7,13,21,31,43,...
\\
\\ are a linear recurrence and can be found by recurrence_guess().  If you know
\\ some values are polynomial then polinterpolate() can be used too.  It's
\\ faster and requires only p+1 many values for terms up to n^p whereas a
\\ recurrence is order p+1 so requires 2*(p+1)+1 values.  If you have enough
\\ values then recurrence_guess() has the attraction of noticing powers and
\\ initial exceptions too.
\\
\\ Recurrence factors for a polynomial tend to be unenlightening.  The
\\ characteristic polynomial is root 1 repeated, and similar in the
\\ generating function partial fraction denominators.  For example n^2
\\ appears as characteristic polynomial (x-1)^3 and gf partial fractions
\\ 1/(1-x), 1/(1-x)^2, 1/(1-x)^3.
\\
\\ In the gf partial fractions, a term 1/(1-x)^k is values of the form
\\ (n+1)*(n+2)*...*(n+(k-1)) / (k-1)!.  This means that values like n^2 come
\\ out as a sum of various such gf parts which cancel at n powers other than
\\ n^2.  Such a sum might be helpful if you are in fact working in such
\\ polynomial products.
\\
\\ Powers times a polynomial like (n+1)*7^k go similarly but the repeated
\\ root is then power 7 etc and gf partial fractions are like 1/(1-7*x)^2
\\ etc.
\\
\\
\\ Program Use
\\ -----------
\\
\\ Guessing is done (and nothing printed) by
\\
\\     f = recurrence_guess_values_to_factors(v);
\\     g = recurrence_guess_values_to_gf(v);
\\
\\ which return a vector of factors or t_RFRAC generating function
\\ respectively.  See the help strings for details.
\\ recurrence_guess_values_to_factors(v) is the basic operation and the gf
\\
\\     g = recurrence_guess_factors_and_values_to_gf(f,v);
\\
\\ Currently the code works by a simple matsolve() to find f
\\
\\              / v[1] v[2] v[3] \  / f[1] \     / v[4] \
\\     matsolve | v[2] v[3] v[4] |  | f[2] |  =  | v[5] |
\\              \ v[3] v[4] v[5] /  \ f[3] /     \ v[6] /
\\
\\ This asks for recurrence factors f so that f times consecutive v values
\\ make the next v value, for m many such next values.  This matsolve is
\\ attempted for orders m=1 upwards until finding a solution which also
\\ satisfies the rest of v.  The code for this matsolve is only a few
\\ lines.  The bloat is all in pretty-printing the result.
\\
\\ A small to medium recurrence is normally found and confirmed quickly.
\\ A very long v without a solution might take a long time.
\\
\\
\\ Recurrence Evaluation
\\ ---------------------
\\
\\ Having found a linear recurrence or suitable generating function, code to
\\ terms of the sequence can be made in all usual ways.  From a t_RFRAC
\\ generating function, adding an O(x^20) gives a t_SER
\\
\\     1/(1-x-x^2) + O(x^7)          \\ Fibonacci numbers
\\     == 1 + x + 2*x^2 + 3*x^3 + 5*x^4 + 8*x^5 + 13*x^6 + O(x^7)
\\
\\ Vec() converts that to a vector of terms, but it discards any initial 0s.
\\
\\ For an isolated term, t_POLMOD powering is compact and efficient, but
\\ obscure.  See examples/polmod.gp in the recurrence-guess sources for the
\\ setups needed and notes on why it works.  (nfeltpow() does essentially
\\ the same, but an even more obscure setup.)
\\
\\
\\ Compatibility
\\ -------------
\\
\\ Requires GP 2.7 or higher due to ".." subvectors and probably more.
\\
\\
\\ Bugs
\\ ----
\\
\\ There's a hard-coded limit on the length of periodic powers which are
\\ recognised for the printout.  For a given gf denominator, the period is
\\ found by seeking a power p and constant c for which den is a factor of
\\ (1-c*x^p).  c becomes the base in base^floor(n/spread).
\\
\\ The best way to choose what bases to show for powers is not settled.
\\ With say (1+I)^n there's a choice of that or [periodic]*2^floor(n/2).
\\ Similarly 12th roots.  But maybe 2,3,4,6,8,12 are the only exact nth
\\ roots to encounter.  Maybe two power forms should be shown, one with
\\ bases corresponding to the gf partial fractions, one with nth roots of
\\ unity spun up to positive reals (and combined when same magnitudes), if
\\ that's different.
\\
\\ The power expression (and OEIS recurrence "n>=") is always for index n=0
\\ for the first term of the data.  It might be helpful to specify a start
\\ say n=1 or bigger if values are from the middle of a sequence.  That
\\ should be no harder than a gf shift and a factor on the power
\\ coefficients.  The suggestion for now is to prepend some dummy initial
\\ values to pad down to n=0 (possibly after getting an answer without, so
\\ as to have plenty of values).
\\
\\ Sometimes lindep() is faster than the matsolve() currently used.  Not
\\ yet sure whether that's always or sometimes.  If recurrence_guess() is a
\\ bit slow then try successive runs from a values vector v like
\\
\\     lindep([ v[1..10], v[2..11], v[3..12], ... ])
\\
\\
\\ Other Ways to Do It
\\ -------------------
\\
\\ Bill Allombert points out that bestapprPade(Ser(v)) gives a generating
\\ function for values v.  This can be faster than matsolve(), but tends to
\\ give a big expression for a non-recurrence so its result should be
\\ confirmed.
\\
\\ Charles R Greathouse has a findrec() at
\\ http://oeis.org/wiki/User:Charles_R_Greathouse_IV/Pari which is a
\\ matsolve(), and among other things shows recurrence coefficients as the
\\ "signature" form used in the OEIS (high to low coeffs).
\\
\\ OEIS Sequence Tools page http://oeis.org/wiki/Sequence_Tools has ggf()
\\ getting a gf and coefficients using qflll().  The OEIS email superseeker
\\ http://oeis.org/superhelp.txt notices linear recurrences (and others
\\ like d-finite).
\\
\\
\\ Changes
\\ -------
\\
\\ Version 1 - the first version.
\\ Version 2 - fix last value missed from confirm, allow t_POL values.
\\ Version 3 - fix for printing powers in gf denominator.
\\ Version 4 - fix for initial exceptions in powers self-test.
\\ Version 5 - fix and improve some periodic powers.
\\ Version 6 - more merging of periodic constant terms,
\\             fix for self-test of some powers.
\\ Version 7 - no factorize of multi-variable characteristic and gf.
\\ Version 8 - use gp 2.11 multi-variable factorizing.
\\ Version 9 - fix for some poly coeffs printing.
\\ Version 10 - recurrence_guess_factors_and_values_to_gf() wasn't
\\              meant to recalculate the factors.
\\ Version 11 - fix for factorized gf print.
\\ Version 12 - fix for numerator 1 in factorized gf print.
\\ Version 13 - show roots of an irreducible charpoly.
\\ Version 14 - OEIS link and formula.
\\ Version 15 - fix for noticing when has factors in gf print.
\\ Version 16 - OEIS link and formula of an eventually all 0 sequence.
\\
\\
\\ Home Page
\\ ---------
\\
\\ http://user42.tuxfamily.org/pari-recurrence-guess/index.html
\\


\\-----------------------------------------------------------------------------
\\ Configuration

recurrence_guess_minimum_confirm = 1;
{
addhelp(recurrence_guess_minimum_confirm,
"recurrence_guess_minimum_confirm = integer
This is the minimum number of confirming values which recurrence_guess() etc
must see before accepting a recurrence.

An order m recurrence is determined by 2*m values.
recurrence_guess_minimum_confirm=1 then demands vector v has at least 1 more
value satisfying the recurrence.  If recurrence_guess_minimum_confirm=0 then
every even length v will produce an order m recurrence, but no values
confirming that it might be right.");
}

recurrence_guess_variable = 'n;
{
addhelp(recurrence_guess_variable,
"recurrence_guess_variable = 'n
The name of the index variable to show in coefficients and power expressions
printed.  It should be a symbol like 'n.  This is presently only used for
printouts.

(Generating functions always show x as the formal variable, and give that in
polynomials returned by the various ...to_gf().)");
}


\\-----------------------------------------------------------------------------
\\ Generic Helpers

\\ g is a polynomial generating function ("t_RFRAC" usually).
\\ Return a vector of its first n terms, starting at coefficient of x^0.
\\ The formal variable is the given x, or default variable(g).
recurrence_guess_INTERNAL_gf_terms(g,n,var=variable(g)) =
{
  \\ print("recurrence_guess_INTERNAL_gf_terms ",g," "n);
  if(g==0,return(vector(n)));
  my(zeros = min(n,valuation(g,var)),
     v = Vec(g + O(var^n)));
  if(zeros>=0, concat(vector(zeros,i,0), v),
               v[-zeros+1 .. #v]);
}

\\ g is a polynomial generating function ("t_RFRAC" usually).
\\ Return the coefficient of its x^n term.
\\ The formal variable is the given x, or default variable(g).
recurrence_guess_INTERNAL_gf_term(g,n,var=variable(g)) = \
  recurrence_guess_INTERNAL_gf_terms(g,n+1,var)[n+1];

\\-----------------------------------------------------------------------------

\\ f is a vector of recurrence factors.
\\ v is a vector of values.
\\ Return 1 if the values all satisfy the recurrence.
recurrence_guess_INTERNAL_check(f,v) =
{
  \\ pos+#f = #v last check, so last pos = #v-#f
  for(pos=1,#v-#f,
     my(n = sum(i=0,#f-1, v[pos+i]*f[i+1]));
     if(n!=v[pos+#f], return(0)));
  1;
}

\\ return a lex() style compare of a <=> b,
\\ with comparison first by abs() magnitude then arg() angle
recurrence_guess_INTERNAL_lex_by_polar(a,b) =
{
  lex(recurrence_guess_INTERNAL_lex_by_polar_key(a),
      recurrence_guess_INTERNAL_lex_by_polar_key(b));
}
\\ likewise, but form a vector which is a key suitable for lex() compare
recurrence_guess_INTERNAL_lex_by_polar_key(z) =
{
  my(a);
  iferr(a=if(z,arg(z)),  \\ z==0 as angle a=0
        e,
        return([poldegree(z),      \\ z=poly etc
                apply(recurrence_guess_INTERNAL_lex_by_polar_key,Vec(z))]));
  if(a<0, a+=2*Pi);  \\ angle 0 <= a < 2*Pi
  [-1, norm(z), a, real(z), imag(z)];
}

\\ p is a polynomial in 'x.
\\ If it is a divisor of some 1 - c*x^e then return that 1 - c*x^e.
\\ If not then return 0.
\\ Positive real c is preferred, ready to be the base shown in powers.
recurrence_guess_INTERNAL_pol_periodic(p) =
{
  \\ In the loop have 1+c*x^e = p*q where q is a quotient made from
  \\ successive terms t/low.  Those terms are chosen to make 0s except for
  \\ the low 1.  poldegree(c) <= poldegree(p) so memory use is capped, until
  \\ the return value.
  my(low=polcoeff(p,0,'x),
     c=1-p/low);   \\ so lowest term of c is 1, then subtract that 1
  for(e=1,100,
     c /= 'x;
     my(t=polcoeff(c,0));
     \\ print(" periodic at e="e"  c="c"  t="t);
     if(poldegree(c,'x)<1,  \\ c is a constant, good
        \\ try to avoid imaginary c by squaring or cubing
        for(i=2,3,
           if(imag(t),
              my(tp=t^i);
              if(! imag(tp), t=tp; e*=i)));
        \\ try for positive c by squaring
        \\ have 1-(-c)*x^e, multiply 1+(-c)*x^e to be 1-(c^2)*x^(2*e)
        if(recurrence_guess_INTERNAL_is_negative(t),
           my(tp=sqr(t));
           if(! recurrence_guess_INTERNAL_is_negative(tp),
              t=tp; e*=2));
        \\ print(" periodic final t="t"  e="e);
        return(1 - t*'x^e));
     \\ print("  sub ", t/low * p);
     c -= t/low * p);
  0;  \\ not found
}

\\ Return a generating function for
\\    base^floor(n/spread)
\\    * n^expon
\\    * vector_modulo(periodic_vector,n)
recurrence_guess_INTERNAL_besp_to_gf(base,expon,spread,periodic_vector) =
{
  recurrence_guess_values_to_gf
  (vector((2*spread*#periodic_vector*(expon+1)+1 )*4+10,
          n,n--;   \\ 0 upwards
          base^floor(n/spread)
          * n^expon
          * recurrence_guess_INTERNAL_vector_modulo(periodic_vector,n)));
}

\\ x is a number or a polynomial.
\\ If it needs parens around for printing an exponent ^123 after then
\\ return a stringized "(x)".  If not then return x unchanged.
recurrence_guess_INTERNAL_parens_for_power(x) =
  if(recurrence_guess_INTERNAL_want_parens_for_power(x), Str("(",x,")"), x);
recurrence_guess_INTERNAL_want_parens_for_power(x) =
{
  x=simplify(x); \\ reduce poly constant only to a number
  if(type(x)=="t_POL",
     x!='x,      \\ poly term x alone no need parens

     !(real(x)==0 && imag(x)==1)       \\ number I or w no need parens
     && !(real(x)>=0                   \\ real >=0 no need parens
          && imag(x)==0
          && denominator(real(x))==1)); \\ but rational 9/2 needs parens
}

\\ x is a number.
\\ If it needs parens around for printing with a multiply *123 after then
\\ return a stringized "(x)".  If not then return x unchanged.
recurrence_guess_INTERNAL_parens_for_multiply(x) = \
  if(recurrence_guess_INTERNAL_want_parens_for_multiply(x), Str("(",x,")"), x);
recurrence_guess_INTERNAL_want_parens_for_multiply(x) =
{
  x=simplify(x); \\ reduce poly constant only to a number
  if(type(x)=="t_POL",
     my(count=0);
     for(i=0,poldegree(x),
        my(c=polcoeff(x,i));
        count+=(c!=0);
        if(count>1 || recurrence_guess_INTERNAL_want_parens_for_multiply(c),
           return(1))),
     real(x) && imag(x));
}

\\ v is a vector of periodic factors starting from i==0 mod #v.
\\ Return the factor for i.
recurrence_guess_INTERNAL_vector_modulo(v,i) = v[(i%#v)+1];

\\ v1 and v2 are vectors of periodic factors.
\\ Return a vector which is their sum.
\\ If the periods are different then they are replicated as necessary to
\\ their least common multiple.
recurrence_guess_INTERNAL_periodic_vector_binop(func,v1,v2) =
{
  vector(lcm(#v1,#v2), i,i--;
         func(recurrence_guess_INTERNAL_vector_modulo(v1,i),
              recurrence_guess_INTERNAL_vector_modulo(v2,i)));
}

\\ v is a vector of periodic factors like [5,7,-3].
\\ If the factors repeat themselves like [5,7,-3, 5,7,-3] then reduce.
recurrence_guess_INTERNAL_periodic_vector_reduce(v) =
{
  my(ds=Vecrev(divisors(#v))[^1]);
  for(len=1,floor(#v/2),
     if(#v % len, next());
     for(i=len+1,#v,
        if(v[i] != v[i-len],
           next(2)));
     return(v[1..len]));
  v;
}

\\ p is a polynomial.  Return the number of non-zero terms.
\\ Same as hammingweight(p) but allowing a specified var.
recurrence_guess_INTERNAL_pol_num_terms(p,var=variable(Pol(p))) = \
  sum(i=0,poldegree(p,var), polcoeff(p,i,var)!=0);

\\ p is a polynomial.  Return its lowest exponent non-zero term.
recurrence_guess_INTERNAL_pol_lowest_coeff(p,var=variable(Pol(p))) = \
  polcoeff(p, valuation(p,var), var);

\\ return true if x<0
recurrence_guess_INTERNAL_is_negative(x) =
{
  while(type(x)=="t_POL",
        x=simplify(x);
        x=pollead(x));
  iferr(real(x)<0 || (real(x)==0 && imag(x)<0),
        e,0);  \\ false on t_RFRAC or similar which are error for real()
}


\\-----------------------------------------------------------------------------

\\ p is a polynomial or t_RFRAC.
\\ Return a string of it with powers ascending.
\\ if want_plus is true then ensure the string starts with a + or - sign.
recurrence_guess_INTERNAL_ascending_str(p,want_plus, \
                                        var=variable(Pol(numerator(p)))) =
{
  \\ print("recurrence_guess_INTERNAL_ascending_str()\n var="var"  p="p);
  if(p==0,return("0"));
  my(den = denominator(p));
  if(poldegree(den,var) != 0,
     \\ t_RFRAC like (x+2)/(x^2+5)
     p=numerator(p);
     \\ print("den ",den," num ",p);

     \\ notice a power in the denominator
     my(den_expon=1, den_factors=iferr(factor(den),e,'cannot_factorize));
     if(den_factors!='cannot_factorize
        && matsize(den_factors)[1]==1
        && den_factors[1,2] > 1,
        \\ factor() is not actually equal to den, only up to a constant
        \\ factor so put that into the numerator
        den_expon = den_factors[1,2];
        p *= den_factors[1,1]^den_expon / den;
        den=den_factors[1,1];
        \\ print(" to power den ",den," expon ",den_expon);
       );

     \\ divide out so constant term of den is 1
     my(den_low=pollead(polrecip(den),var));
     den /= den_low;
     p /= den_low^den_expon;
     \\ print(" to constant1 den ",den," num ",p,"   den_low was ",den_low));

     p=simplify(p);
     my(p_num_terms = recurrence_guess_INTERNAL_pol_num_terms(p,var),
        p_low = recurrence_guess_INTERNAL_pol_lowest_coeff(p,var));
     while(type(p_low)=="t_POL",p_low=simplify(pollead(p_low)));
     my(p_parens = (p_num_terms != 1
                    || (real(p_low) != 0 && imag(p_low) != 0)),
        p_negate = want_plus && ! p_parens
                  && iferr(real(p_low)<0 || imag(p_low)<0,  e,0),

        den_num_terms = recurrence_guess_INTERNAL_pol_num_terms(den),
        den_low = pollead(polrecip(den),var),
        den_parens = (den_num_terms > 1
                      || (den_expon!=1 && den_low != 1)
                      || (real(den_low) != 0 && imag(den_low) != 0)));
     if(p_negate, p=-p);
     \\ print(" p_parens="p_parens" str "Str(p)" type "type(p));

     return(concat([if(want_plus,if(p_negate,"- ","+ "),""),
                    if(p_parens,"(",""),
                    recurrence_guess_INTERNAL_ascending_str(p,0,var),
                    if(p_parens,")",""),
                    "/",
                    if(den_parens,"(",""),
                    recurrence_guess_INTERNAL_ascending_str(den,0,var),
                    if(den_parens,")",""),
                    if(den_expon!=1,Str("^",den_expon),"")
                   ])));

  my(str="");
  my(join=0);
  for(i=0,poldegree(p,var),
     my(coeff=polcoeff(p,i,var));
     if(coeff==0, next());
     if(join, str=concat(str," "));
     if(join || want_plus,
        if(recurrence_guess_INTERNAL_is_negative(coeff),
           str=concat(str,"- "); coeff = -coeff,
           str=concat(str,"+ ")));
     str = concat([str,coeff*variable(p)^i]);
     join=1);
  \\ print(" ret str "str);
  str;
}

\\ f is recurrence factors which give v is a vector of values.
\\ g is a t_RFRAC generating function in 'x.
\\ gparts is a vector of g as partial fractions (so vecsum(gparts)==g).
\\ Print powers like 2^n etc for the recurrence (using gparts).
recurrence_guess_INTERNAL_show_powers(f,v,g,gparts) =
{
  my(debug=0);
  if(gparts=='cannot_factorize,return());

  print(" as powers");
  my(powers_list = List([]),
     initial_exceptions=[],
     glist = List([]));
  for(i=1,#gparts,
     my(gpart = gparts[i],       \\ t_RFRAC generating function part
        num=numerator(gpart),    \\ t_POL
        den=denominator(gpart));
     if(debug, print("gpart "gpart"\n num "num"\n den "den));

     \\ If den=1 then gpart is non t_RFRAC initial exceptions.
     if(den==1,
        initial_exceptions=v[1 .. poldegree(gpart,'x)+1];
        print("  initial exceptions ",initial_exceptions);
        next());

     \\ If den=power like (1-2*x)^3 then reduce to den=1-2*x and set pow=3.
     \\ factor() can be out by a constant factor when complex coefficients,
     \\ so adjust with num = num*newden^pow/den.
     my(pow=1, den_factors=factor(den));
     if(matsize(den_factors)[1]==1,
        pow = den_factors[1,2];
        num *= den_factors[1,1]^pow / den;
        den = den_factors[1,1]);
     if(debug, print(" pow "pow"\n num "num"\n den "den));

     \\ periodic_pol is like 1-c*x^p
     my(periodic_pol=recurrence_guess_INTERNAL_pol_periodic(den));
     if(periodic_pol==0,
        \\ this gpart not an exact power or periodic factors of an exact
        \\ power, print as the generating function
        listput(glist,gpart);
        next());
     if(debug, print(" periodic_pol ",periodic_pol));

     my(spread=poldegree(periodic_pol,'x));    \\ p high power in 1-c*x^p
     if(debug, print(" spread "spread));

     if(debug, print(" quotient "periodic_pol/den));
     num *= (periodic_pol/den)^pow;
     if(debug, print(" num with qs "num"   degree "poldegree(num,'x)));

     my(base=-pollead(periodic_pol,'x));      \\ c factor in 1-c*x^p
     if(debug, print(" base "base));

     \\ pow_poly = (n+1)*(n+2)*(n+3)*(n+4)/24 for pow=5, etc  pow-1 terms
     my(pow_poly=prod(i=1,pow-1, 'x/spread + i) / (pow-1)!);
     if(debug, print(" pow_poly ",pow_poly,"   factorial ",(pow-1)!));

     \\ 1/(1-c*x^p) is pow_poly at [1,0,0,...] every "spread" many terms
     \\ shift up for each term of num
     \\ eg. (n/3+1)*(n/3+2)*2^floor(n/3)
     \\ periodic_vectors[i] is periodic vector for term n^i, formed by
     \\ picking terms out of pow_poly and num factor
     my(periodic_vectors=vector(poldegree(pow_poly,'x)+1, i,
                                vector(spread)));  \\ zeros to start
     for(i=0,poldegree(num,'x),
        my(p= polcoeff(num,i)*subst(pow_poly,'x,'x-i) / base^floor(i/spread));
        if(debug, print("  i="i" p="p"   degree "poldegree(p,'x)));
        for(e=0,poldegree(p,'x),
           periodic_vectors[e+1][(i%spread)+1] += polcoeff(p,e,'x)));
     if(debug, print(" periodic_vectors "periodic_vectors));

     \\ reduce base and spread if possible
     \\ power is base^floor(n/spread)
     \\ try to take spread-th root of base to reduce
     \\ eg. 4^floor(n/2)  becomes 2^n * vector_modulo([1,1/2],n)
     my(spread_divisors=divisors(spread));
     forstep(s=#spread_divisors,2, -1,  \\ highest to lowest divisor
            my(sd=spread_divisors[s],
               reduced_base);

            if( \\ ispower(I,2,&b) likes to say I is square of b=0.707+0.707*I,
                \\ but want to stay exact here not go to floats.
               \\ Also, ispower() doesn't take quads, so protect with iferr.
                 iferr(ispower(base,sd,&reduced_base),e,0)
                 && type(real(reduced_base))!="t_REAL"
                 && type(imag(reduced_base))!="t_REAL",
               my(reduced_spread = spread/sd,
                  \\ periodic vector adjustment
                  \\ base^floor(i/spread) /reduced_base^floor(i/reduced_spread)
                 v=vector(spread,i,i--;
                          1/reduced_base^floor(i/reduced_spread)));
               if(debug, print(" reduce sd="sd"  base "base" -> "reduced_base
                               "  spread "spread" -> "reduced_spread
                               "  mul v="v));
               base = reduced_base;
               spread = reduced_spread;
               for(i=1,#periodic_vectors,
                  periodic_vectors[i]
                  = recurrence_guess_INTERNAL_periodic_vector_binop
                   ((x,y)->x*y, periodic_vectors[i], v));
               break()));

     for(expon=0,#periodic_vectors-1,
        listput(powers_list, [base,
                              expon,
                              spread,
                              periodic_vectors[expon+1]]));
  );
  if(debug, print(" powers_list ",powers_list));

  \\ sort powers_list descending base^(1/spread), and descending expon within
  powers_list = Vec(powers_list);
  my(spread_lcm=lcm(apply(v->v[3],powers_list)));
  my(besp_to_key=(v->[recurrence_guess_INTERNAL_lex_by_polar_key
                      (v[1]^(spread_lcm/v[3])),  \\ base^(1/spread)
                      v[2] ]));                  \\ expon
  powers_list = vecsort(powers_list,
                        (x,y)->lex(besp_to_key(x),besp_to_key(y)),
                        4); \\ descending
  if(debug, print(" powers_list sort ",powers_list));

  \\ merge powers_list entries of same base,expon,spread
  powers_list = List(powers_list);
  forstep(i=#powers_list,2, -1,
     if(powers_list[i-1][1] == powers_list[i][1]      \\ base   \
        && powers_list[i-1][2] == powers_list[i][2]   \\ expon  | all same
        && (powers_list[i-1][3] == powers_list[i][3]  \\ spread /
            || (powers_list[i][1]==1 && powers_list[i][2]==0)), \\ or 1^n*n^0
        powers_list[i-1][4]                       \\ merge into previous
        = recurrence_guess_INTERNAL_periodic_vector_binop
          ((x,y)->x+y, powers_list[i-1][4], powers_list[i][4]);
        listpop(powers_list,i)));
  if(debug, print("powers_list merged ",powers_list));

  \\ shorten periodic vectors, and delete possible zeros
  forstep(i=#powers_list,1, -1,
     my(v=recurrence_guess_INTERNAL_periodic_vector_reduce(powers_list[i][4]));
     if(v==[0],
        listpop(powers_list,i),
        powers_list[i][4]=v));

  \\ print
  my(func_vec = vector(#powers_list));
  my(plus="  ");
  for(i=1,#powers_list,
     my(base = powers_list[i][1],
        expon = powers_list[i][2],
        spread = powers_list[i][3],
        periodic = powers_list[i][4]);
     print1(plus); plus = "  + ";

     \\ periodic part [5,7]
     my(periodic_want_parens=0);
     my(periodic_str=
        if(\\ periodic terms
           #periodic>1,
           Str("vector_modulo(",periodic,","recurrence_guess_variable")"),
           \\ single term == 1, skip
           periodic[1]==1, "",
           \\ single term != 1
           periodic_want_parens=1; Str(periodic[1])));

     \\ polynomial part n^2
     my(poly_str="");
     if(expon>0,
        poly_str=Str(recurrence_guess_variable);
        if(expon>1, poly_str=Str(poly_str,"^",expon)));

     \\ base part 2^n
     my(power_str="");
     if(base != 1,
        power_str=Str(recurrence_guess_INTERNAL_parens_for_power(base),"^");
        if(spread==1,
           power_str=Str(power_str,recurrence_guess_variable),
           power_str=Str(power_str,
                         "floor(",recurrence_guess_variable,"/",spread,")")));

     if(periodic_want_parens && (poly_str!="" || power_str!=""),
        periodic_str=recurrence_guess_INTERNAL_parens_for_multiply(periodic[1]));

     my(times="");
     if(periodic_str!="", print1(periodic_str); times = " * ");
     if(poly_str!="", print1(times,poly_str); times = " * ");
     if(power_str!="", print1(times,power_str); times = " * ");
     if(times=="",print1("1")); \\ if everything else was collapsed
     print();

     func_vec[i] = (k)->k^expon
                        * recurrence_guess_INTERNAL_vector_modulo(periodic,k)
                        * base^floor(k/spread);
  );
  apply(gpart->print("  + gf ",
                     recurrence_guess_INTERNAL_ascending_str(gpart,0,'x)),
       glist);
  glist = vecsum(Vec(glist));
  if(debug, print("glist ",glist));
  if(debug, print("initial_exceptions ",initial_exceptions));

  my(func = (n)->\\ if(debug, print(" func(n="n")"));
                 if(n<#initial_exceptions, initial_exceptions[n+1],
                    recurrence_guess_INTERNAL_gf_term(glist,n)
                    + sum(i=1,#func_vec, func_vec[i](n))));
  my(t=vector(#v,n,n--; func(n)));
  if(t != v,
     error("oops, powers different from values\ngot  ",t,"\nwant ",v));

  for(i=1,#powers_list,
     my(g=recurrence_guess_INTERNAL_besp_to_gf(powers_list[i][1],
                                               powers_list[i][2],
                                               powers_list[i][3],
                                               powers_list[i][4]));
     if(debug, print("  i="i" gf "g));
     glist+=g);
  if(debug, print("glist+besp ",glist));

  glist += Polrev(initial_exceptions
                  - recurrence_guess_INTERNAL_gf_terms(glist,#initial_exceptions));
  if(debug, print("glist+exceptions ",glist));
  if(g!=glist,
     error("oops, powers reconstruct generating function different\n",
           "got  ",glist,"\nwant ",g));
}

\\ f is a matrix returned by factor(), return 1 if it's from an irreducible
\\ value, meaning 0 rows, or 1 row and exponent 1
recurrence_guess_INTERNAL_factor_is_irreducible(f) =
{
  my(rows=matsize(f)[1]);
  rows==0 || (rows==1 && f[1,2]==1);
}

\\ Maybe this could have general use pretty printing partial fractions.
\\ Or maybe it would belong in pol-pfrac.gp.
recurrence_guess_INTERNAL_print_gf(g,gparts=0) =
{
  \\ print("recurrence_guess_INTERNAL_print_gf() ",g);  \\ DEBUG
  print("  ",recurrence_guess_INTERNAL_ascending_str(g,0,'x));
  if(gparts=='cannot_factorize,return());

  if(pol_partial_fractions=='pol_partial_fractions, read("pol-pfrac.gp"));
  if(!gparts, gparts=pol_partial_fractions(g));
  \\ print("gparts="gparts);  \\ DEBUG

  \\ Print f * num / den with those polys factorized, and possible further
  \\ rational f for when factor() goes to integer coeffs.
  \\ ENHANCE-ME: Could use gparts denominators which are a partial
  \\ factorization of the denominator, and which might be a speedup for a
  \\ big polynomial.  gparts might have a denominators like (1-x)^3, not
  \\ taken down to just (1-x).  gparts may also repeat such denominators so
  \\ (1-x)^4 and (1-x)^5 too.  Probably better to factor() just once the
  \\ charpoly or its reciprocal and make pol_partial_fractions() and here
  \\ share the result.
  if(g,
     my(dens=factor(denominator(g)));
     for(i=1,matsize(dens)[1],        \\ low coeff 1 in each term
        if(polcoeff(dens[i,1],0), dens[i,1]/=polcoeff(dens[i,1],0)));
     my(num=g*factorback(dens),
        \\ iferr() to guard against cannot factorize multi-variable poly
        nums=iferr(factor(num), e, Mat([num,1])));
     for(i=1,matsize(nums)[1],        \\ low coeff + sign in each term
        if(recurrence_guess_INTERNAL_is_negative(nums[i,1]),
           nums[i,1]*=-1));
     my(f=num/factorback(nums));
     \\ print("nums "nums"  f="f);  \\ DEBUG
     \\ print("dens "dens);         \\ DEBUG
     if(! (f==1 && recurrence_guess_INTERNAL_factor_is_irreducible(nums)
                && recurrence_guess_INTERNAL_factor_is_irreducible(dens)),
        \\ something different to show factorized
        print1("  = ");
        my(join="");
        if(f!=1                     \\ constant outside the nums factors
           || matsize(nums)[1]==0,  \\ or numerator = 1 so no factors
           print1(f);
           join=" * ");
        for(i=1,matsize(nums)[1],
           my(p=nums[i,1],
              e=nums[i,2],
              want_parens=if(e>1,
                             recurrence_guess_INTERNAL_want_parens_for_power(p),
                             recurrence_guess_INTERNAL_want_parens_for_multiply(p)));
           print1(join,
                  if(want_parens,"(",""),
                  recurrence_guess_INTERNAL_ascending_str(p,0,'x),
                  if(want_parens,")",""),
                  if(e>1,Str("^",e),""));
           join=" * ");
        print1(" / ");
        join="";
        if(matsize(dens)[1]>1,print1("( "));
        for(i=1,matsize(dens)[1],
           my(p=dens[i,1],
              e=dens[i,2],
              want_parens=if(e>1,
                             recurrence_guess_INTERNAL_want_parens_for_power(p),
                             recurrence_guess_INTERNAL_want_parens_for_multiply(p)));
           print1(join,
                  if(want_parens,"(",""),
                  recurrence_guess_INTERNAL_ascending_str(p,0,'x),
                  if(want_parens,")",""),
                  if(e>1,Str("^",e),""));
           join=" * ");
        if(matsize(dens)[1]>1,print1(" )"));
        print("")));

  if(#gparts==1, print("  same in partial fractions"),
     print("  = partial fractions");
     for(i=1,#gparts,
        my(p=gparts[i]);
        print("  ",recurrence_guess_INTERNAL_ascending_str(p,i>1,'x))));
}

recurrence_guess_INTERNAL_order_and_sig(f,comma=",") =
{
  \\ in OEIS, an eventually all 0 sequence is reckoned as order 1
  \\ with coefficient 0, for example A000004
  while(#f && f[1]==0, f=f[^1]);
  f=Vecrev(f);
  if(#f==0,f=[0]);
  [#f, concat(vector(#f,i, Str(f[i], if(i<#f,comma,""))))];
}
recurrence_guess_INTERNAL_formula(f) =
{
  my(l=List(["a(n) = "]));
  forstep(i=#f,1,-1,
     if(f[i]==0, next);
     my(c=f[i]);
     if(#l==1, if(c==-1, listput(l,"-");c=1),
        \\ second and subsequent
        recurrence_guess_INTERNAL_is_negative(c), listput(l," - "); c=-c,
        listput(l," + "));
     if(c!=1,
        listput(l,Str(recurrence_guess_INTERNAL_parens_for_multiply(c),"*")));
     listput(l, Str("a(n-",#f-i+1,")")));
  if(#l==1,
     \\ all parts 0, write that as 0
     listput(l,"0"));
  concat(l);
}

\\-----------------------------------------------------------------------------

recurrence_guess_INTERNAL_values_to_matrix(v,len) = \
  matrix(len,len,i,j, v[i+j-1]);
recurrence_guess_INTERNAL_values_to_column(v,len) = \
  vectorv(len,i, v[i+len]);

\\ C for confirm so V-C for recurrence is 2*L terms,
\\ so L=floor((V-C)/2) biggest to try

recurrence_guess_values_to_factors(v) =
{
  for(len=1, floor((#v-recurrence_guess_minimum_confirm)/2),
     my(m = recurrence_guess_INTERNAL_values_to_matrix(v,len),
        a = recurrence_guess_INTERNAL_values_to_column(v,len));
     \\ print("m="m);
     \\ print("a="a);
     my(f = iferr(matsolve(m,a),
                  e,next(), errname(e)=="e_INV"));
     \\ f is a column, change to row and simplify down any t_POL terms
     f = simplify(Vec(f));
     if(recurrence_guess_INTERNAL_check(f,v),
        return(f)));
  [];
}
{
addhelp(recurrence_guess_values_to_factors,
"f = recurrence_guess_values_to_factors(v)
v is a vector of values.
Return a vector f of linear recurrence coefficients for the values.
Or if a recurrence cannot be found then return an empty vector [].

The coefficients are in ascending order the same order as the values v.
So for example if an order 3 recurrence is found then

   f[1]*v[1] + f[2]*v[2] + f[3]*v[3] == v[4]");
}


recurrence_guess_factors_and_values_to_gf(f,v) =
{
  my(f_pol = Pol(f),
     low_pol = Polrev(v[1 .. #f]),
     low_product_mod = (f_pol*low_pol) % ('x)^(#f - 1),
     g = ( 'x*low_product_mod - low_pol )/('x*f_pol-1));

  my(t=recurrence_guess_INTERNAL_gf_terms(g,#v,'x));
  if(t != v,
     error("oops, gf different from v\ngot  ",t,"\nwant ",v));
  g;
}
{
addhelp(recurrence_guess_factors_and_values_to_gf,
"gf = recurrence_guess_factors_and_values_to_gf(f,v)
v is a vector of values and f a vector of linear recurrence coefficients.
Return a polynomial generating function (\"t_RFRAC\") which is the linear
recurrence with initial values from v.

Must have lengths #v >= #f.  As a self-test, it is confirmed that the gf
returned does in fact give all of v, both the initial values and any extras
given (with an error() if not).");
}

recurrence_guess_values_to_gf(v) =
{
  my(f = recurrence_guess_values_to_factors(v));
  if(f == [], return(0));
  recurrence_guess_factors_and_values_to_gf(f,v);
}
{
addhelp(recurrence_guess_values_to_gf,
"gf = recurrence_guess_values_to_gf(v)
v is a vector of values.
Return a polynomial generating function (\"t_RFRAC\") for a linear recurrence
satisfying the values.  Or return 0 if no recurrence can be found.");
}

recurrence_guess(v) =
{
  my(f = recurrence_guess_values_to_factors(v));
  if(f == [],
     print("No linear recurrence found\n");
     return());

  print("Recurrence length=", #f);
  print(" coefficients");
  print1("  v["recurrence_guess_variable"-",#f"]* ");
  if(#f==1,
     print1(recurrence_guess_INTERNAL_parens_for_multiply(f[1])),
     print1(f," *v["recurrence_guess_variable"-1] "));
  print(" = v[",recurrence_guess_variable,"]");
  if(#f>=2 && f[1]==0,
     print("    leading 0 coeffs are initial exceptions before recurrence"));
  print1("  v[",recurrence_guess_variable,"] =  v["recurrence_guess_variable"-1]* ");
  if(#f==1,
     print(recurrence_guess_INTERNAL_parens_for_multiply(f[1])),
     print(Vecrev(f)," *v["recurrence_guess_variable"-",#f"]"));
  print("");

  print(" characteristic polynomial ");
  my(p = Polrev(concat(-f,[1])));
  print("  ",p);
  my(pfactors = iferr(factor(p), e,
                      \\ pari 2.9 cannot factorize multi-variable polynomials
                      print("  (cannot factorize: ",errname(e),")");
                      'cannot_factorize));
  if(pfactors!='cannot_factorize,
     my(pfactor_strs = vector(#pfactors[,1],i,
                              if(pfactors[i,2]==1,
                                 Str(pfactors[i,1]),
                                 Str("(",pfactors[i,1],")^",pfactors[i,2]))),
        width = 0,
        want_factors = (#pfactors[,1] > 1 || pfactors[1,2] > 1));
     if(want_factors,
        width = vecmax(apply(length, pfactor_strs));
        print("  = factors"));
     for(i=1,#pfactors[,1],
        if(want_factors,
           printf("  %-*s  ", width, pfactor_strs[i]));
        print1(if(#roots==1,"  root ","  roots "));
        my(pfactor=pfactors[i,1]);
        \\ print("\npfactor = ",pfactor);
        my(roots);
        if(poldegree(pfactor)==1,
           roots = [- polcoeff(pfactor,0) / polcoeff(pfactor,1)],
           iferr(roots=polroots(pfactor),
                 e,
                 print("[cannot extract roots]"); next));
        \\ print("roots ",#roots," unsorted = ",roots);
        roots = vecsort(roots, recurrence_guess_INTERNAL_lex_by_polar);
        for(j=1,#roots,
           if(j>1,print1(", "));
           iferr(if(imag(roots[j])==0, printf("%.6g",real(roots[j])),
                    real(roots[j])==0, printf("I*%.6g",imag(roots[j])),
                    printf(" %.6g+I*%.6g",real(roots[j]),imag(roots[j]))),
                 e,
                 print1(" ",roots[j])));
        print());
    );
  print();

  print(" generating function");
  my(g = recurrence_guess_factors_and_values_to_gf(f,v));
  my(t=recurrence_guess_INTERNAL_gf_terms(g,#v));
  if(t!=v, error("oops, gf different from values\ngot  ",t,"\nwant ",v));

  if(pol_partial_fractions=='pol_partial_fractions, read("pol-pfrac.gp"));
  my(gparts = iferr(pol_partial_fractions(g),  \\ over vecsum(0*v) maybe ?
                    e, 'cannot_factorize));
  recurrence_guess_INTERNAL_print_gf(g,gparts);
  print();

  recurrence_guess_INTERNAL_show_powers(f,v,g,gparts);
  print();   \\ undef return value so no result print interactively

  print(" OEIS");
  if(denominator(f)!=1,
     print("  coefficients not integers");
     ,
     my(ord,sig);[ord,sig]=recurrence_guess_INTERNAL_order_and_sig(f);
     \\ Not sure what length ought to put spaces to allow wrapping in HTML display.
     \\ Try 60 chars as roughly the table display width (maybe?).
     if(length(sig)>60,
        [ord,sig]=recurrence_guess_INTERNAL_order_and_sig(f,", "));
     printf("  %%H <a href=\"/index/Rec#order_%02d\">Index entries for linear recurrences with constant coefficients</a>, signature (%s).\n",
            ord,sig));
  print1("  %F ",recurrence_guess_INTERNAL_formula(f));
  if(#f && f[1]==0, print1(" for n>=",#f));
  print(".\n");
}
{
addhelp(recurrence_guess,
"recurrence_guess(v)
v is a vector of values.  Guess a linear recurrence for them and print a
report showing variously initial values, coefficients, generating function,
and powers.  Or print if a linear recurrence cannot be found.

See comments in recurrence-guess.gp for detailed notes and programmatic use.
Configuration variables include
    recurrence_guess_minimum_confirm
    recurrence_guess_variable");
}

\\-----------------------------------------------------------------------------
