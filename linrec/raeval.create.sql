--  OEIS-mat/linrec/raeval.create.sql - recurrences found with LinearRecurrence -find
--  @(#) $Id$
--  2019-12-11, Georg Fischer
--
DROP    TABLE  IF EXISTS raeval;
CREATE  TABLE            raeval
    ( aseqno    VARCHAR(8)  NOT NULL  -- A322469 without
    , signature VARCHAR(1020)         -- comma separated, without "[ ]"
    , initterms VARCHAR(1020)         -- comma separated, without "[ ]"
    , keyword   VARCHAR(64)           -- "cand,indx,pass", "fail" ...
    , sigorder  INT                   -- number of signature elements
    , PRIMARY KEY(aseqno)
    );
COMMIT;
