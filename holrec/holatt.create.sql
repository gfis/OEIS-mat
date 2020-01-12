--  OEIS-mat/holrec/holatt.create.sql - attributes of holonomic recurrences 
--  @(#) $Id$
--  2019-12-12, Georg Fischer
--
DROP    TABLE  IF EXISTS holatt;
CREATE  TABLE            holatt
    ( aseqno    VARCHAR(8)  NOT NULL  -- e.g. A322469 
    , attr      VARCHAR(8)  NOT NULL  -- "guess,index,pass", "fail" ...
    , PRIMARY KEY(aseqno, attr)
    );
COMMIT;
