--  Table for OEIS - working table for stripped terms
--  @(#) \$Id\$
--  2019-01-25: Georg Fischer ,
--
DROP    TABLE  IF EXISTS stripped;
CREATE  TABLE            stripped
    ( aseqno     VARCHAR(10) NOT NULL  -- A322469
    , terms      VARCHAR(64)
    , PRIMARY KEY(aseqno)
    );
COMMIT;
