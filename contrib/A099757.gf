# A099757

# g  := 1 + 16*t^4 + 18*t^5 + 143*t^6 + 170*t^7 + 696*t^8 + 1073*t^9 + 2786*t^10 + 4420*t^11 + 8881*t^12 + 13782*t^13 + 23018*t^14 + 33979*t^15 + 50086*t^16 + 69748*t^17 + 94127*t^18 + 123476*t^19 + 155400*t^20 + 192999*t^21 + 229352*t^22 + 270342*t^23 + 306276*t^24 + 343736*t^25 + 372818*t^26 + 399845*t^27 + 415884*t^28 + 425872*t^29;
# u1 := g + t^59*subs(t=t^(-1), g);
# u2 := ((1-t)*(1-t^2)^4*(1-t^4)^6*(1-t^6)^3*(1-t^12)^2) ;
# factor(simplify(u1/(u2)));

(t^50-2*t^49+t^48-t^47+20*t^46-19*t^45+126*t^44-118*t^43+553*t^42-309*t^41+1703*t^40-828*t^39+4186*t^38-1611
*t^37+8208*t^36-2913*t^35+13977*t^34-4286*t^33+20805*t^32-6186*t^31+27716*t^30-7378*t^29+33344*t^28-8770*t^
27+36816*t^26-8886*t^25+36816*t^24-8770*t^23+33344*t^22-7378*t^21+27716*t^20-6186*t^19+20805*t^18-4286*t^17+
13977*t^16-2913*t^15+8208*t^14-1611*t^13+4186*t^12-828*t^11+1703*t^10-309*t^9+553*t^8-118*t^7+126*t^6-19*t^5
+20*t^4-t^3+t^2-2*t+1)/(-1+t)^16/(t+1)^12/(t^2+t+1)^5/(t^2-t+1)^4/(t^2+1)^6/(t^4-t^2+1)^2