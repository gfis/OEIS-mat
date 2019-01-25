--  Table for OEIS - working table for sequence numbers
--  @(#) \$Id\$
--  2019-01-24: Georg Fischer ,
--
DROP    TABLE  IF EXISTS seq;
CREATE  TABLE            seq
    ( aseqno  VARCHAR(10) NOT NULL  -- A322469
    , PRIMARY KEY(aseqno)
    );
COMMIT;
