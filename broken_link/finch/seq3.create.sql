--  Table for OEIS - working table for sequence numbers and remaining info
--  @(#) $Id$
--  2019-04-19: Georg Fischer ,
--
DROP    TABLE  IF EXISTS seq3;
CREATE  TABLE            seq3
    ( aseqno  VARCHAR(10) NOT NULL  -- A322469
    , pageno  INT         NOT NULL
    , section VARCHAR(256)
    , PRIMARY KEY(aseqno, pageno)
    );
COMMIT;
