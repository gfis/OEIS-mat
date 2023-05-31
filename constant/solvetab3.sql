-- solvetab3.sql - patches for solvetab
-- 2023-05-08: offset -> offset1
-- 2021-07-28, Georg Fischer
--
UPDATE seq4 SET offset1 = -1 WHERE aseqno IN ('A197135','A197251','A197259');
UPDATE seq4 SET offset1 =  0 WHERE aseqno IN ('A197252','A197519','A198560','A198612','A198613');
UPDATE seq4 SET offset1 =  1 WHERE aseqno IN ('A197506','A198581');
DELETE FROM seq4             WHERE aseqno IN ('A195693','A195695');

UPDATE seq4 SET parm2 = '.divide(CR.THREE).multiply(CR.TWO)' WHERE aseqno = 'A336044';
UPDATE seq4 SET parm2 = '.divide(CR.PI)'                     WHERE aseqno = 'A336050';
UPDATE seq4 SET parm2 = '.divide(CR.PI).divide(CR.TWO)'      WHERE aseqno = 'A336058';
UPDATE seq4 SET callcode = 'decsolvn' WHERE aseqno IN ('A199053');
COMMIT;

-- TAB=67
UPDATE seq4 SET offset1 =  0 WHERE aseqno IN ('A201285','A199188','A202351');
UPDATE seq4 SET offset1 = -1 WHERE aseqno IN ('A201289');
UPDATE seq4 SET offset1 =  1 WHERE aseqno IN ('A199174');
COMMIT;
-- TAB=c
UPDATE seq4 SET callcode = 'decsolv'  WHERE aseqno IN ('A199609','A199618','A199619','A199618','A202351');
UPDATE seq4 SET callcode = 'decsolvn' WHERE aseqno IN ('A199600','A199621','A199625','A199662','A199666','A199667','A201750','A201769','A201895');
UPDATE seq4 SET offset1 =  1 WHERE aseqno IN ('A199618');
COMMIT;
-- TAB=d
UPDATE seq4 SET callcode = 'decsolv'  WHERE aseqno IN ('A198122','A198128','A198136','A198373','A198345','A198366');
UPDATE seq4 SET callcode = 'decsolvn' WHERE aseqno IN ('A198129');
UPDATE seq4 SET offset1 =  0 WHERE aseqno IN ('A198128','A198366');
UPDATE seq4 SET offset1 =  1 WHERE aseqno IN ('A198129');
COMMIT;
-- TAB=e
UPDATE seq4 SET offset1 =  1 WHERE aseqno IN ('A198840');
COMMIT;
-- TAB=f
UPDATE seq4 set parm1  = 'CR.TWO.multiply(x.pow(2)).add(CR.TWO.multiply(x.sin())).add(CR.THREE).subtract(REALS.tan(x))' 
    WHERE aseqno = 'A200365';
COMMIT;
    
-- TAB=k
UPDATE seq4 SET offset1 =  0 WHERE aseqno IN ('A197290','A316162','A316163','A316254','A316257');
UPDATE seq4 SET offset1 =  1 WHERE aseqno IN ('A316161');
COMMIT;
