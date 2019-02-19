--  Table for OEIS - working table for sequence numbers and remaining info
--  @(#) $Id$
--  2019-02-19: Georg Fischer ,
--
DROP    TABLE  IF EXISTS seq2;
CREATE  TABLE            seq2
    ( aseqno  VARCHAR(10) NOT NULL  -- A322469
    , info    VARCHAR(1024)
    , PRIMARY KEY(aseqno)
    );
COMMIT;
