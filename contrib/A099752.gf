# A099752

# f := 1 + 2*t^2 + 15*t^3 + 51*t^4 + 170*t^5 + 500*t^6 + 1136*t^7 + 2126*t^8 + 3439*t^9 + 4822*t^10 + 5908*t^11 + 6473*t^12 + 6325*t^13 + 5437*t^14 + 4124*t^15 + 2764*t^16 + 1596*t^17 + 764*t^18 + 305*t^19 + 95*t^20 + 20*t^21 + 5*t^22 + 2*t^23;
# u1 := subs(t=t^4,f);
# u2 := (1-t^4)^2*(1-t^8)^3*(1-t^12)^3*(1-t^20)^2;
# factor(simplify(u1/u2));
# 
(2*t^88+3*t^84+17*t^80+78*t^76+227*t^72+537*t^68+1059*t^64+1705*t^60+2419*t^56+3018*t^52+3307*t^48+3166*t^44
+2742*t^40+2080*t^36+1359*t^32+767*t^28+369*t^24+131*t^20+39*t^16+12*t^12+3*t^8-t^4+1)/(-1+t)^10/(t^4+t^3+t^
2+t+1)^2/(t+1)^10/(t^4-t^3+t^2-t+1)^2/(t^2+1)^10/(t^8-t^6+t^4-t^2+1)^2/(t^2+t+1)^3/(t^2-t+1)^3/(t^4-t^2+1)^3
/(t^4+1)^2
