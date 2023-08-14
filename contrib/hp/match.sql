-- match.sql - update matching sequences, and delete those that are not XREFed
-- @(#) $Id$
-- 2023-08-11, Georg Fischer
-- cf. match_align.pl:
-- (#oseqno, #occ, #ooff, #ogcd                           )) 
--                        parm1
-- (#nseqno, #ncc, #noff, #ngcd, substr(#ndata, 0, #width))) 
--  parm2    parm3 parm4  parm5  parm6
SELECT t.aseqno, t.callcode, t.offset1, t.parm1, t.parm2, t.parm3, t.parm4, t.parm5, t.odata, t.ndata, t.keyword
FROM (
  (
  SELECT  s.aseqno, s.callcode, i1.offset1, s.parm1, s.parm2, s.parm3, s.parm4, s.parm5
    , SUBSTR(d1.data, 1, 64) AS odata, SUBSTR(d2.data, 1, 64) AS ndata, i2.keyword
    FROM  seq4 s, asinfo i1, asinfo i2, asxref x, asdata d1, asdata d2
    WHERE s.aseqno = i1.aseqno
      AND s.aseqno = i2.aseqno
      AND s.aseqno = x.aseqno
      AND s.parm2  = x.rseqno
      AND s.aseqno = d1.aseqno
      AND s.parm2  = d2.aseqno
  ) UNION (
  SELECT  s.aseqno, s.callcode, i1.offset1, s.parm1, s.parm2, s.parm3, s.parm4, s.parm5
    , SUBSTR(d1.data, 1, 64) AS odata, SUBSTR(d2.data, 1, 64) AS ndata, i2.keyword
    FROM  seq4 s, asinfo i1, asinfo i2, asxref x, asdata d1, asdata d2
    WHERE s.aseqno = i1.aseqno
      AND s.aseqno = i2.aseqno
      AND s.aseqno = x.rseqno
      AND s.parm2  = x.aseqno
      AND s.aseqno = d1.aseqno
      AND s.parm2  = d2.aseqno
  ) 
) AS t
-- WHERE t.keyword NOT LIKE '%dead%'
--   AND t.parm1 <> t.parm5
;
