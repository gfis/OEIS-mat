--  OEIS-mat/holrec/holrec.create.sql - holonomic recurrences
--  @(#) $Id$
--  2020-02-01: 2 tables combined
--  2019-12-11, Georg Fischer
--
DROP    TABLE  IF EXISTS holrec;
CREATE  TABLE            holrec
    ( aseqno    VARCHAR(8)  NOT NULL  -- e.g. A322469
    , signature VARCHAR(1024)         -- comma separated, without "[ ]"
    , initterms VARCHAR(1024)         -- comma separated, without "[ ]"
    , sigorder  INT                   -- number of signature elements, without const and a[n]
    , maxdegree INT                   -- 0 = linear
    , prefixno  INT                   -- number of terms prefixed to the recurrence
    , termpass  INT                   -- number of terms which passed
    , PRIMARY KEY(aseqno)
    );
COMMIT;
--
DROP    TABLE  IF EXISTS holatt;
CREATE  TABLE            holatt
    ( aseqno    VARCHAR(8)  NOT NULL  -- e.g. A322469 
    , attr      VARCHAR(8)  NOT NULL  -- "guess", "index", "pass", "fail" ...
    , PRIMARY KEY(aseqno, attr)
    );
COMMIT;
