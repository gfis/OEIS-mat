#!"C:/Program Files/Maple 2022/bin.X86_64_WINDOWS/cmaple.exe" -q 
# @(#) $Id$
# 2024-10-03, Georg Fischer: with initialisation
restart;
libname:="C:/User/work/gits/OEIS-mat/software/FPS.mla",libname;
with(FPS);
hfre:=proc(aseqno, ae, limit:=64);
timelimit(limit, printf("%a\tbva_0_%a__%a_%a_%a\n", aseqno, FindRE(ae,x,a(n),specialfunctions), 0, 0, ae));
end;
hfrex:=proc(aseqno, ae, limit:=64);
timelimit(limit, printf("%a_bva_0_%a__%a_%a_%a\n", aseqno, FindRE(ae,x,a(n),specialfunctions), 0, 1, ae));
end;
C:= proc(x) (1 - sqrt(1 - 4*x)) / (2*x) end: # A000108 Catalan's g.f.
Catlan:= proc(x) (1 - sqrt(1 - 4*x)) / (2*x) end:
schroeder:= proc(x) (1 + x - sqrt(1 - 6*x + x^2) )/(4*x) end:
halg:=proc(aseqno, ae, limit:=64);
timelimit(limit, printf("%a_bva_0_%a__%a_%a_%a\n", aseqno, diffeqtorec(AlgtoHolonomicDE(ae,A(x)),A(x),a(n)), 0, 0, ae));
end;

# halg(A278745, x*(1-x^2*A^2)-A*(1+x^2*A^2)^2);
# halg(A112807, (-A+1)*(1-x^2*A^5)+x*A^3);
