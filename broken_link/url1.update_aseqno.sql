-- @(#) $Id$
-- Fill aseqno with minimum aseqno from brol
-- 2018-12-18, Georg Fischer
--
UPDATE url1 u SET aseqno = 
    ( SELECT b.aseqno 
      FROM   brol b
      WHERE  b.protocol = u.protocol
        AND  b.host     = u.host
        AND  b.path     = u.path
        AND  b.filename = u.filename
    )
    WHERE    u.noccur   = 1
        AND  u.status   = 'unknown'
    --  AND  u.filename LIKE 'books%' 
    ;
COMMIT;
