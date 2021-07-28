-- solv_tabs_patch.sql - patches for solv_tabs
-- 2021-07-28, Georg Fischer
--
UPDATE seq4 SET offset = -1 WHERE aseqno IN ('A197135','A197251','A197259');
UPDATE seq4 SET offset =  0 WHERE aseqno IN ('A197252','A197519');
UPDATE seq4 SET offset =  1 WHERE aseqno IN ('A197506');
DELETE FROM seq4            WHERE aseqno IN ('A195693','A195695');
COMMIT;
