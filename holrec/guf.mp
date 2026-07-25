#!"C:/Program Files/Maple 2022/bin.X86_64_WINDOWS/cmaple.exe" -q 
# @(#) $Id$
# 2026-07-18, Georg Fischer: copied from hfre.mp
restart;
with(gfun); gfun:-version;
guf:=proc(aseqno, list, limit:=12);
timelimit(limit, printf("%a\tguf\t0\t%a\n", aseqno, listtorec(list, a(n), ['ogf','egf'])));
end;
# guf(A000045, [0,1,1,2,3,5,8,13,21,34,55]);
#----------------

