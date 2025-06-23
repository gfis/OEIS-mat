halg:=proc(aseqno, ae, limit:=64);
timelimit(limit, printf("%a\tbva\t0\t%a\t\t%a\t%a\t%a\n", aseqno, diffeqtorec(AlgtoHolonomicDE(ae,A(x)),A(x),a(n)), 0, 0, ae));
end;

# halg(A278745, x*(1-x^2*A^2)-A*(1+x^2*A^2)^2);
# halg(A112807, (-A+1)*(1-x^2*A^5)+x*A^3);
