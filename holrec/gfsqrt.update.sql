-- gfsqrt.update.sql - corrections
-- @(#) $Id$
-- 2020-01-06, Georg Fischer

UPDATE seq4 SET parm1='[[0],[-4,8],[-2]]'                  WHERE aseqno = 'A001813'; 

UPDATE seq4 SET parm1='[[0],[-12,18],[-3]]', parm2='[1]'   WHERE aseqno = 'A012244';
UPDATE seq4 SET parm1='[[0],[-42,49],[-7]]'                WHERE aseqno = 'A045754';
UPDATE seq4 SET parm1='[[0],[-56,64],[-8]]'                WHERE aseqno = 'A045755';
UPDATE seq4 SET parm1='[[0],[-12,18],[-3]]', parm2='[1]'   WHERE aseqno = 'A047657';
UPDATE seq4 SET parm1='[[0],[-2,4],[-2]]'                  WHERE aseqno = 'A097801'; 
  -- (Maple) a:= proc(n) a(n):= `if`(n=0, 2, a(n-1)*(2*n-1)) end; seq(a(n), n=0..25);
-- ??? UPDATE seq4 SET parm1='[[0],[-6,6],[-2,4],[0,-2]]'  WHERE aseqno = 'A098460';
-- ??? UPDATE seq4 SET parm1='[[0],[-6,6],[-2,4],[0,-2]]'  WHERE aseqno = 'A098461';
UPDATE seq4 SET parm1='[[0],[-4,8],[0,-2]]', parm2='[1,6]' WHERE aseqno = 'A144706'; 
  -- G.f.: 3/sqrt(1-4x)-2
UPDATE seq4 SET parm1='[[0],[-90,100],[-10]]'              WHERE aseqno = 'A144773'; 
-- A178694: 1 + 1/2*x + 7/8*x^2 + 17/16*x^3 + 203/128*x^4 + 583/256*x^5 => /2^n ...?
UPDATE seq4 SET parm1='[[0],[-1,2,-1],[-2,4],[-1]]'        WHERE aseqno = 'A285199';
COMMIT;
