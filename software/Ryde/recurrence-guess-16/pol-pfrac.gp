\\ Copyright 2014, 2015, 2016 Kevin Ryde
\\
\\ This file is free software; you can redistribute it and/or modify it
\\ under the terms of the GNU General Public License as published by the Free
\\ Software Foundation; either version 3, or (at your option) any later
\\ version.
\\
\\ This file is distributed in the hope that it will be useful, but
\\ WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
\\ or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
\\ for more details.
\\
\\ You should have received a copy of the GNU General Public License along
\\ with this file.  See the file COPYING.  If not, see
\\ <http://www.gnu.org/licenses/>.


\\ Usage: read("pol-pfrac.gp")
\\        v = pol_partial_fractions(polyfrac)
\\        v = pol_partial_fractions(polyfrac, dens)
\\
\\ pol_partial_fractions() breaks a polynomial fraction f, of type "t_RFRAC"
\\ with exact coefficients, into a sum of partial fractions.  The return is
\\ a vector of new polynomial fractions which sum to the original f.  For
\\ example
\\
\\     f = 1/(x^2 - 1);
\\     v = pol_partial_fractions(f)
\\ gives
\\     v == [ 1/(2*x - 2),  -1/(2*x + 2) ]
\\     vecsum(v) == f
\\
\\ The numerator of each partial fraction has degree < its denominator.
\\
\\ Partial fractions can be helpful for seeing which terms occur in a
\\ polynomial fraction, or for polynomial generating functions where the
\\ terms show powers which occur, in particular linear terms correspond to
\\ powers numerator*root^k in the sequence.
\\
\\-----------------------------------------------------------------------------
\\ Denominator Factorization
\\
\\ The default for the partial fraction denominators is factor() on the f
\\ denominator.
\\
\\ If the numerator or denominator includes complex number or quad
\\ coefficients (types "t_COMPLEX" or "t_QUAD") then the factorization
\\ extends over that type, so some quadratics can be split.  For example
\\
\\     v = pol_partial_fractions( (1 + 2*I*x)/(x^2 + 1) )
\\ gives
\\     v == [I/(2*x - 2*I),  3*I/(2*x + 2*I)]
\\
\\ If there isn't (or might not be) a coefficient of the desired type then
\\ give a complex or quad constant as the "dens" parameter to show the
\\ breakdown desired.  For example
\\
\\     w = quadgen(-3)    \\ sixth root of unity
\\     v = pol_partial_fractions( 1/(1+x^3), w )
\\ gives
\\     v == [1/(3*x + 3),  -w/(3*x - 3*w),  (-1 + w)/(3*x + (-3 + 3*w))]
\\
\\ Generally complex, quad, and quads of different discriminant cannot be
\\ intermingled.  Expect an error if the dens parameter is not compatible
\\ with the coefficients of f.
\\
\\-----------------------------------------------------------------------------
\\ Some Denominators
\\
\\ To break out only selected partial fractions from f give desired
\\ denominators as a vector in the dens parameter.  For example to break out
\\ a single term,
\\
\\     v = pol_partial_fractions( 1/(x^4+10*x^3+35*x^2+50*x+24),  [x+4] )
\\     v == [ -1/(6*x + 24),
\\            (x^2 + 2*x + 3)/(6*x^3 + 36*x^2 + 66*x + 36) ]
\\
\\ If a given denominator doesn't divide the denominator of f then it's
\\ ignored.
\\
\\ The default dens by factor() is roughly equivalent to the following,
\\ except that a complex or quad from the numerator is incorporated if not
\\ already in denominator(f).
\\
\\     \\ factors column extracted from the factor() return
\\     v = pol_partial_fractions(f, factor(denominator(f))[,1])
\\
\\ If factor() is slow on a large poly or you already know the possible
\\ factors then supplying dens might be a speedup.
\\
\\-----------------------------------------------------------------------------
\\ Quotient Part
\\
\\ If the numerator has degree >= denominator then a non-fraction term is
\\ included in the return.
\\ 
\\     v = pol_partial_fractions( x^6/(x^2-1) )
\\     v == [  x^4 + x^2 + 1,  1/(2*x - 2),  -1/(2*x + 2) ]
\\
\\ This term is simply quotient numerator(f) \/ denominator(f) and the
\\ remaining fraction is then broken into partial fractions.  The sum of the
\\ return is the original f.
\\
\\ A fraction with numerator degree < denominator degree is called a proper
\\ rational function, and numerator degree >= denominator an improper
\\ rational function.  Both are treated the same by gp.
\\
\\-----------------------------------------------------------------------------
\\ Repeated Factors
\\
\\ If the denominator of f has a repeated factor then the partial fractions
\\ have powers of that factor.  For example
\\
\\     v = pol_partial_fractions( (1+x+x^2)/(x+1)^3 )
\\     v == [  1 / (x + 1),
\\            -1 / (x^2 + 2*x + 1),              \\ (x+1)^2
\\             1 / (x^3 + 3*x^2 + 3*x + 1) ]     \\ (x+1)^3
\\
\\ There might be only some of the powers in the return.  Any zeros are
\\ omitted.  For these powers each partial fraction numerator has degree
\\ < the base (not merely less than the power of the base).
\\
\\ In the usual print() a power like (x+1)^2 shows as x^2 + 2*x + 1 and it
\\ might not be immediately obvious that it's a power.  That's something for
\\ a fancy print to notice.
\\
\\ A constant over a power cannot be broken down any further and is returned
\\ unchanged.
\\
\\     v = pol_partial_fractions( 1/(x+1)^3 )
\\     v == [ 1/(x^3 + 3*x^2 + 3*x + 1) ]   \\ f unchanged
\\
\\ For a supplied dens vector, the base such as x+1 should be given.  Any
\\ dens term is powered as necessary to fully divide out of f.
\\
\\ If a dens vector has a power such as (x+1)^2 then usually f must have
\\ have powers of that, not for example odd powers, otherwise such a
\\ denominator can't be broken out.
\\
\\-----------------------------------------------------------------------------
\\ Merging Fractions
\\
\\ As an extra helper, pol_partial_fractions_merge() can merge polynomial
\\ fractions in a vector.  Entries with same denominator are added together.
\\ For example,
\\
\\     v = [ 1/(x^2-1), 1/(x+1), (3*x+1)/(x^2-1), 7/(x^5-2) ]
\\     v = pol_partial_fractions_merge(v)
\\ gives
\\     v == [ (3*x+2)/(x^2-1), 1/(x+1), 7/(x^5-2) ]
\\
\\ Any zeros are discarded, both zeros in the input and any zeros from terms
\\ which cancel out.
\\
\\ A polynomial fraction has numerator() and denominator() with integer
\\ coefficients.  Denominators which are the same to a rational multiple are
\\ noticed and combined.
\\
\\ pol_partial_fractions() always has distinct terms and so doesn't need to
\\ be merged.  But partial fractions from different calculations can be
\\ combined by concat() to "add" and then terms of the resulting vector
\\ merged.
\\
\\-----------------------------------------------------------------------------
\\ Compatibility:
\\
\\ Written with gp 2.7.2 but believe can work with gp 2.5.5 too if you
\\ supply gcdext() and vecsum().  Definitions could be conditionalized like
\\
\\     if(type(gcdext)!="t_CLOSURE", eval("gcdext(x,y)=bezout(x,y)"));
\\     if(type(vecsum)!="t_CLOSURE", eval("vecsum(v)=sum(i=1,#v,v[i])"));
\\
\\-----------------------------------------------------------------------------
\\ gp2c
\\
\\ pol-pfrac.gp Works when compiled by gp2c.  The use of t_LIST is minimal
\\ enough for the limitations on that type in gp2c circa 0.0.9pl2-1.  But
\\ any speedup from compiling is likely to be modest as the real work is in
\\ factor() and gcdext().
\\
\\-----------------------------------------------------------------------------
\\ Limitations:
\\
\\ Both pol_partial_fractions() and pol_partial_fractions_merge() are
\\ designed to operate on exact polynomials, meaning coefficients which are
\\ integers or rationals or complex or quad integers or rationals.  The
\\ partial fractions found are checked by adding back to see they equal the
\\ original f and that is likely to fail on inexact coefficients.
\\
\\ For a multi-variable polynomial the variable to operate with is the
\\ highest priority one.  This is usually what's wanted, and might be the
\\ only way to make a t_RFRAC.  A var parameter would probably need a
\\ corresponding parameter in denominator().

\\-----------------------------------------------------------------------------
\\ Algorithm:
\\
\\ The partial fractions are found a polynomial modular inverse as
\\ recommended by Karim, done by explicit gcdext() which is what underlies
\\ "t_POLMOD".
\\
\\ The aim is to break an f=n/d into a/x + b/y for some given x,y.  In the
\\ code x is a term from dens and y=d/x the rest of d.
\\
\\          n      a     b      a*y + b*x  
\\     f = ---  = --- + ---  =  ---------      poldegree(n) < poldegree(d)
\\          d      x     y         x*y
\\
\\ To find a,b satisfying a*y+b*x=n, gcdext(y,x) gives A and B satisfying
\\
\\     A*y + B*x = g
\\
\\ If g!=1 then x and y have a common factor.  Usually this is a given dens
\\ like x=(t+1)^2 when d=(t+1)^3 so y=t+1 and x,y common factor g=t+1.  Such
\\ an x cannot be split out.  (g can't be handled by dividing into the
\\ numerator since n and d are in least terms.)  It'd be possible to take
\\ the gcd as a denominator, but think for now that a supplied dens should
\\ be applied only as given, not with more denominators discovered.
\\
\\ With g=1 multiply by n to give
\\
\\     (A*n)*y + (B*n)*x = n
\\
\\ Want poldegree(a)<poldegree(x) so divide
\\
\\     [q,r] = divrem(A*n, x)    so A*n = q*x + r
\\
\\ Subtract q*x from A*n and add a corresponding q*y to B*n.  This is adding
\\ and subtracting q*x*y so no change.
\\
\\     (A*n - q*x)*y + (B*n + q*y)*x = n
\\              r*y  + (B*n + q*y)*x = n
\\
\\ which is result
\\
\\     a = r
\\     b = B*n + q*x
\\
\\ poldegree(a) < poldegree(x) from the divrem so with
\\
\\     poldegree(a*y) < poldegree(x)+poldegree(y) = poldegree(d)
\\     poldegree(n)   < poldegree(d)
\\
\\ and a*y+b*x=n this means b is in the desired degree range too,
\\
\\     poldegree(b) < poldegree(y)
\\
\\ When x is a power x=p^e the a which results is reduced to power terms
\\
\\      a    a[1]   a[2]   a[3]         a[e]
\\     --- = ---- + ---- + ---- + ... + ----    poldegree(a[i]) < poldegree(p)
\\     p^e    p     p^2    p^3          p^e
\\
\\ These parts are found dividing out p successively
\\
\\     [q,r] = divrem(a,p)
\\       so a = q*p + r    with poldegree(r) < poldegree(p)
\\     a/p^e = q/p^(e-1) + r/p^e
\\ so
\\     a[e] = r   = high term
\\     q/p^(e-1)  = remaining terms, repeat division on them

\\-----------------------------------------------------------------------------
\\
\\ Version 1 - the first version.
\\ Version 2 - avoid 0 from a constant multi-variable numerator.


\\----------------------------------------------------------------------------

\\ Internal helper.
\\ p is a polynomial
\\ If a coefficient of p is a t_COMPLEX or t_QUAD then return it.
pol_partial_fractions__find_factor(p) =
{
  for(i=0,poldegree(p),
     my(c = polcoeff(p,i));
     if(c && (type(c) == "t_COMPLEX" || type(c) == "t_QUAD"),
        return(if(c==0,c+1,c))));
  0;
}

pol_partial_fractions(f, dens=0) =
{
  if(f==0, return([]));
  my(n = numerator(f));

  \\ dens by factor(), and possible complex or quad
  if(dens == 0 || type(dens) == "t_COMPLEX" || type(dens) == "t_QUAD",
     dens*f;  \\ check dens complex or quad is compatible with f
     my(d = denominator(f));
     if(! pol_partial_fractions__find_factor(d),
        \\ no quad in denominator
        if(dens,
           d *= dens, \\ given dens
           my(q = pol_partial_fractions__find_factor(n));
           if(q, d*=q)));   \\ otherwise quad from numerator
     dens = factor(d));

  \\ if dens is a factor() matrix then take its factors column
  if(type(dens)=="t_MAT", dens=dens[,1]);
  \\ print("dens="dens);

  \\ dens type check
  for(i=1,#dens,
     my(p = dens[i]);
     if(type(p) != "t_POL", error("dens entry not a polynomial"));
     if(poldegree(p) < 1, error("dens entry is a constant")));

  my(ret:list = List([]),
     d = denominator(f));     \\ n/d reduced progressively

  \\ Quotient n/d for initial non-fraction terms.  This is 0 if
  \\ poldegree(n,var)<poldegree(d,var) but let divrem() notice that rather
  \\ than picking out var=variable(d) and anticipating its behaviour.
  my(v = divrem(n,d));
  if(v[1], listput(ret,v[1])); \\ quotient
  n = v[2];                    \\ remainder
  \\ print("num higher degree q=",v[1]," remaining num=",n);

  for(i=1,#dens,
     my(p = dens[i],
        e = valuation(d, p));
     if(e<1, next());  \\ p is not a factor of denominator d
     my(x = p^e,
        y = d/x);      \\ x*y = d
     \\ print("i=",i," p="p"  e="e"  x="x"  y="y);
     \\ print("  n="n"  d="d);

     \\ find a*y + b*x = g
     v = gcdext(y, x);           \\ my(v) above
     my(a = v[1],
        b = v[2]);
     \\ print("  a="a" b="b"  g="g);
     \\ if(a*y+b*x != g, error("oops gcd"));

     \\ If g!=1 then x and y have a common factor due to p a power like
     \\ (x+1)^2 but denominator(f) is a power not a multiple of that like
     \\ (x+1)^3.  So gcd((x+1)^2, (x+1)^3) == x+1.  Cannot break out this p.
     \\ (Since n and d have no common factor cannot multiply n/g to give n.)
     \\
     if(v[3]!=1,next());

     \\ multiply by n to give a*y + b*x = n
     a *= n;
     b *= n;

     \\ reduce a to poldegree(a) < poldegree(x) by mod x
     v = divrem(a,x);
     b += v[1]*y;  \\ quotient for  b = b+q*y  q=v[1]
     a = v[2];     \\ remainder for a = a-q*x
     \\ print("  mul a="a" b="b);
     \\ if(a/x+b/y != n/d, error("oops pfrac sum ",a/x," ",b/y));

     \\ now have a/x + b/y = n/d with suitable poldegree() of a and b
     n = b;
     d = y;

     \\ If e==1 then a/x is the partial fraction.
     \\ If e>1 then break further a[e]/p^e, ..., a[2]/p^2, a[1]/p.
     my(pos = #ret+1);  \\ insert so return ascending powers
     while(a && e>1,
           v = divrem(a,p);
           a = v[1];  \\ quotient
           if(v[2], listinsert(ret, v[2]/x, pos)); \\ remainder r=v[2]
           x /= p;
           e--);
     \\ print("  pfrac a="a" / x="x);
     if(a, listinsert(ret, a/x, pos)));


  \\ final remaining n/d, if any
  if(n, listput(ret,n/d));
  n = Vec(ret);

  \\ add-back as a check
  my(s = vecsum(n));
  if(s != f,
     error("pol_partial_fractions() oops, partial fractions don't sum\nret=",n,"\nsum got   ",s,"\nwant orig ",f));

  n;
}

{
addhelp(pol_partial_fractions,
"v = pol_partial_fractions(f, dens=0)
Return a vector which is polynomial fraction f broken into partial fractions.

\tf = 2*x/(x^2 - 1);
\tv = pol_partial_fractions(f);
gives
\tv == [1/(x-1), 1/(x+1)]
\tvecsum(v) == f

Optional argument dens is either a constant like I or quadgen(-3) to
factorize over, or a vector of denominators to try to break out as partial
fractions.  The denominators are factor() on the denominator of f.

See comments at the start of pol-pfrac.gp for more.");
}

\\-----------------------------------------------------------------------------

\\ If a lot of terms might cancel out to zeros then holding the result in a
\\ List() or copying down vector elements to eliminate the zeros might be a
\\ speedup.  Sorting by poldegree or even a setsearch for normalized
\\ denominator would be possible too.  But keep it simple for now.
\\
\\ (ret=List([]) and listpop to delete zeros isn't enjoyed by gp2c circa its
\\ 0.0.9pl2-1.)
\\
pol_partial_fractions_merge(v) =
{
  my(orig_v = v);
  for(i=2,#v,
     my(p=v[i]);
     for(j=1,i-1,
        if(v[j] && poldegree(denominator(p)) == poldegree(denominator(v[j])),
           my(s = p + v[j]);
           if(poldegree(denominator(s)) <= poldegree(denominator(p)),
              v[j] = s;      \\ merge v[i] into earlier entry v[j]
              v[i] = 0;
              next(2)))));   \\ next v[i]

  v = select((elem)->elem,v); \\ keep non-zero elements

  \\ add-back as a check
  if(vecsum(v) != vecsum(orig_v),
     error("oops merged fractions don't sum, new v=",v,
           " sum got ",vecsum(v)," want ",vecsum(orig_v)));
  v;
}
{
addhelp(pol_partial_fractions_merge,
"v = pol_partial_fractions_merge(v)
v is a vector of polynomial fractions.
Return a new vector which has fractions with the same denominators summed
together, and any zeros deleted.  For example,

\tpol_partial_fractions_merge([1/(x-1), x/(x-1), 1/(x+1)])
gives
\t[(x+1)/(x-1), 1/(x+1)]

See comments at the start of pol-pfrac.gp for more.");
}

\\-----------------------------------------------------------------------------
