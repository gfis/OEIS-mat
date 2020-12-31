--  OEIS-mat: laindx - view on lrindx with normal A-numbers
--  @(#) $Id$
--  2020-11-25, Georg Fischer
--
DROP    VIEW   IF EXISTS laindx;
CREATE  VIEW             laindx AS 
    SELECT 'A' || seqno AS aseqno    -- A322469 without
    , sigorder  -- number of signature elements
    , signature -- comma separated, without "( )"
    FROM lrindx WHERE signature <> '88888888'
     AND 'A' || seqno NOT IN (SELECT aseqno FROM asinfo WHERE keyword LIKE 'dead%');
COMMIT;
