f:= gfun:-rectoproc({a(n)=a(n-1)+`if`(isprime(abs(a(n-1))+n),1,-1)*n, a(1)=1}, a(n), remember): map(f, [$1..40]);

a(n)=if(n==1,1,a(n-1)+if(isprime(abs(a(n-1))+n),n,-n));

f:= gfun:-rectoproc({a(n)[-96,1000,-3500,5000,-2500 = 0, a(0)=1,a(1)=96}, a(k), remember): map(f, [$0..n-1]);

rec:={a(n)+(sum([-96,1000,-3500,5000,-2500][i+1]*n^i,i=0..4)*a(n-1))=0,a(0)=1};
f:= gfun:-rectoproc(rec, a(n), remember): map(f, [$0..10]);
