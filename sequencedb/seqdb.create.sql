--  Table for OEIS - working table for entries from sequencedb.net
--  @(#) $Id$
--  2021-06-25: Georg Fischer, copied from seq4.create.sql
--
DROP    TABLE  IF EXISTS seqdb;
CREATE  TABLE            seqdb
    ( aseqno   VARCHAR(10) NOT NULL
    , si       CHAR(2)
    , mt       INT
    , ix       VARCHAR(1024)
    , px       VARCHAR(1024)
    , PRIMARY KEY(aseqno, si)
    );
COMMIT;
