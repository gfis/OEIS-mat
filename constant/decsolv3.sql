-- decsolv3.sql - patches for decsolv
-- 2021-08-01, Georg Fischer
--
DELETE FROM seq4                         WHERE aseqno IN (SELECT aseqno FROM joeis);
-- UPDATE seq4 SET callcode = 'decsolvn' WHERE aseqno BETWEEN 'A316131' AND 'A316257';
UPDATE seq4 SET callcode = 'decsolvn'    WHERE aseqno IN ('A202353','A305327','A316137','A316138');
UPDATE seq4 SET parm2    = '.inverse()'  WHERE aseqno IN ('A196503');
-- UPDATE seq4 SET parm3=0.00340, parm4=0.00345 WHERE aseqno='A135800';

COMMIT;
UPDATE seq4 SET offset =  0              WHERE aseqno IN ('A196829','A197283','A201938');
UPDATE seq4 SET offset =  -1             WHERE aseqno IN ('A202494');
--  UPDATE seq4 SET offset =  1 WHERE aseqno IN ('A316161');
COMMIT;
