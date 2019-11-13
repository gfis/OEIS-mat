--  Table for OEIS - working table for sequence numbers and 2 fields
--  @(#) $Id$
--  2019-06-13: Georg Fischer ,
--
DROP    TABLE  IF EXISTS seq3;
CREATE  TABLE            seq3
    ( aseqno  VARCHAR(10) NOT NULL  -- A322469
    , status  VARCHAR(32)           -- cfsnum
    , info    VARCHAR(1024)         -- n
    , KEY(aseqno)
    );
COMMIT;
