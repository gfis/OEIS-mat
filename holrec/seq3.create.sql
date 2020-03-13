--  Table for OEIS - working table for sequence numbers and 2 fields
--  @(#) $Id$
--  2020-03-13, Georg Fischer: copied from seq2
--
DROP    TABLE  IF EXISTS seq3;
CREATE  TABLE            seq3
    ( aseqno  VARCHAR(10) NOT NULL  -- A322469
    , info    VARCHAR(4096)
    , number  INT
    , PRIMARY KEY(aseqno)
    );
COMMIT;
