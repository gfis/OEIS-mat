m=255; f:= gfun:-rectoproc({ a(n)=(m!/((m-n+1)!*(n-1)!)-a(n-1)-(m-n+2)*a(n-2))/n, a(0)=1, a(1)=0 }, a(n), remember): map(f, [$0..20]);

with(gfun):rectohomrec({ a(n)=(2*k-a(n-1)-(m-n+2)*a(n-2))/n, a(0)=1, a(1)=0 },a(n));

{(2*k*(m - n) a(n) + (n + - (m - 1)) a(n + 1) + (n + 1) a(n + 2) + (-n - 3) a(n + 3), a(0) = 1, a(1) = 0, a(2) = k - m/2}

m:=255; rt=RecurrenceTable[{n*a[n]==Binomial[m, n-1]-a[n-1]-(m-n+2)*a[n-2], a[0]==1, a[1]==0}, a, {n,0,m}]; Join[{1}, Table[rt[[i]]+rt[[i+1]],{i,2,m,2}], {1}]
