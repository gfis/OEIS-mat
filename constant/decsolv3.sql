-- decsolv3.sql - patches for decsolv
-- 2021-08-01, Georg Fischer
--
UPDATE seq4 SET callcode = 'decsolvn' WHERE aseqno BETWEEN 'A316131' AND 'A316257';
-- UPDATE seq4 SET parm3=0.00340, parm4=0.00345 WHERE aseqno='A135800';
COMMIT;
