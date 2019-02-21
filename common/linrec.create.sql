--  Table for OEIS - working table for linear recurrences
--  @(#) $Id$
--  2019-02-20: Georg Fischer ,
--
DROP    TABLE  IF EXISTS linrec;
CREATE  TABLE            linrec
    ( aseqno    VARCHAR(10) NOT NULL  -- A322469
    , mode      VARCHAR(8)  NOT NULL
    , lorder    INT         NOT NULL
    , signature VARCHAR(720)
    , PRIMARY KEY(aseqno, mode, lorder)
    );
COMMIT;
