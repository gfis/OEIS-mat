-- @(#) $Id$
-- Select same content and different status
-- 2019-01-02, Georg Fischer
SELECT 'brol'
	 , a.status, COALESCE(a.aseqno, 'Annnnnn'), a.replurl
	 , a.protocol || a.host || a.port || a.path || a.filename
--	 , '<br />'
--	 , '<br />'
	 , b.status, COALESCE(b.aseqno, 'Bnnnnnn'), b.replurl
	 , b.protocol || b.port || b.host || b.path || b.filename
--	 , '<br />'
--	 , '<br />'
FROM brol a, brol b 
WHERE a.content = b.content 
  AND a.status  <> b.status
  AND a.status  = '200' and b.status >= '400'
  AND LENGTH(a.content) > 10
  AND a.content like '%rimes%'
ORDER BY a.content, a.status DESC;
