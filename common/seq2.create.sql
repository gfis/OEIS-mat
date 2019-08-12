--  Table for OEIS - working table for sequence numbers and 2 fields
--  @(#) $Id$
--  2019-06-13: Georg Fischer ,
--
DROP    TABLE  IF EXISTS seq2;
CREATE  TABLE            seq2
    ( aseqno  VARCHAR(10) NOT NULL  -- A322469
    , info    VARCHAR(1024)
    , PRIMARY KEY(aseqno)
    );
COMMIT;
