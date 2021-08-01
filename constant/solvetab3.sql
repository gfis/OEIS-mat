-- solvetab3.sql - patches for solvetab
-- 2021-07-28, Georg Fischer
--
DELETE FROM seq4            WHERE aseqno NOT IN (SELECT aseqno FROM joeis);
COMMIT;
UPDATE seq4 SET offset = -1 WHERE aseqno IN ('A197135','A197251','A197259');
UPDATE seq4 SET offset =  0 WHERE aseqno IN ('A197252','A197519','A198560','A198612','A198613');
UPDATE seq4 SET offset =  1 WHERE aseqno IN ('A197506','A198581');
DELETE FROM seq4            WHERE aseqno IN ('A195693','A195695');

UPDATE seq4 SET parm2 = '.divide(CR.THREE).multiply(CR.TWO)' WHERE aseqno = 'A336044';
UPDATE seq4 SET parm2 = '.divide(CR.PI)'                     WHERE aseqno = 'A336050';
UPDATE seq4 SET parm2 = '.divide(CR.PI).divide(CR.TWO)'      WHERE aseqno = 'A336058';
UPDATE seq4 SET callcode = 'decsolvn'                        WHERE aseqno IN ('A199053');

-- TAB=67
UPDATE seq4 SET offset =  0 WHERE aseqno IN ('A201285');
UPDATE seq4 SET offset = -1 WHERE aseqno IN ('A201289');
UPDATE seq4 SET offset =  1 WHERE aseqno IN ('nn');
UPDATE seq4 SET callcode = 'decsolvn'                        WHERE aseqno IN ('A201750','A201751','A201753');

COMMIT;
