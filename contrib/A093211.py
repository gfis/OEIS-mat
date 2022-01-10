divm = 11
n = 11
last = 10**n
ssts = []
debug = 0

def setgoodlist(len, adiv):
    atmp = [0,1,2,3,4,5,6,7,8,9]
    btmp = [0,1,2,3,4,5,6,7,8,9]
    for i in atmp:
        remain = (adiv - i*(10 **(len-1))) % adiv
        if (adiv - 10*remain) % adiv > 9:
            btmp.remove(i)
    if debug > 0:
        print("btmp=" + str(btmp));
    return btmp

def dropdigs(k,l):
    ktmp = (k // l) * l
    ktmp -= 1
    while (ktmp % divm) != 0:
        ktmp -= 1
    if debug >= 2:
        print("dropdigs(" + str(k) + "," + str(l) + " -> " + str(ktmp))
    return ktmp

def walking(k):
    aa = 0
    kt = k*10
    ktl = kt % last
    if debug >= 2:
        print("walk in(" + str(k) + "), last=" + str(last) + ", ktl=" + str(ktl))
    if ((ktl - 1) % divm) + 10 < divm:
        if debug >= 2:
            print("walk premature(" + str(k) + "), aa=" + str(aa))
        return aa
    if ktl % divm == 0:
        a = kt
    else:
        a = kt + (divm - (ktl % divm))

    al = a % last
    if al not in ssts:
        if debug >= 2:
            print("walk !contains(" + str(al) + "), a=" + str(a))
        ssts.append(al)
        aa = max(aa,a)
        atmp = walking(a)
        aa = max(aa,atmp)
        ssts.remove(al)
    else:
        if debug >= 2:
            print("walk contains(" + str(al) + "), a=" + str(a))
    if debug >= 2:
        print("walk out(" + str(k) + ") -> " + str(aa))
    return aa
    

for n in range(1,16):
    goodlist = setgoodlist(n,divm)
    last = 10**n
    beg = int(n*'9')
    end = int((n-1)*"9")
    i = beg
    while i % divm != 0:
        i -= 1
    if debug >= 2:
        print ("i=" + str(i) + ", n=" + str(n) + ", beg=" + str(beg) + ", end=" + str(end))
    an = i
    oldan = an
    anlen = n
    while i > end:
        ssts = [i]
        if i % 100000 == 0:
            anlen = len(str(an))
            if anlen > 2*n:
                anlen = 2*n - 1
        an = max(an,walking(i))
        i -= divm
        for j in range(anlen - n+1):
            jten = 10 ** (n - j-1)
            if jten < 1:
                break
            while (i // jten) % 10 not in goodlist:
                i = dropdigs(i,jten)
    print(str(n) + "   " + str(an))
