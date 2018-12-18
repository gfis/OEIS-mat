-- @(#) $Id$
-- Select same filename and different status
-- 2018-12-18, Georg Fischer
SELECT 'brol'
	 , a.noccur, a.status, COALESCE(a.aseqno, 'Annnnnn'), a.replurl
	 , a.protocol || a.host || a.port || a.path || a.filename
--	 , '<br />'
--	 , '<br />'
	 , b.noccur, b.status, COALESCE(b.aseqno, 'Bnnnnnn'), b.replurl
	 , b.protocol || b.port || b.host || b.path || b.filename
--	 , '<br />'
--	 , '<br />'
FROM url1 a, url1 b 
WHERE a.filename = b.filename 
  AND a.status  <> b.status
  AND a.status   = '200' and b.status <> 'unknown'
  AND LENGTH(a.filename) > 10
ORDER BY a.noccur DESC, a.filename;
