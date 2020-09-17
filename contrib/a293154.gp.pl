{
	ppp = prime(1);
	pp = prime(2);
	r = -oo;
	pi = 0;
	forprime (p=prime(3), 2^64, pi++; d2 = p-2*pp+ppp; if (r < d2, print(k++ " " r=d2);); [ppp,pp]=[pp,p]; );
}
