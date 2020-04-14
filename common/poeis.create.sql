--  Table for OEIS - which sequences are prepared and packed for joeis
--  @(#) \$Id\$
--  2020-04-12, Georg Fischer: copied form joeis.create.sql
--
DROP    TABLE  IF EXISTS poeis;
CREATE  TABLE            poeis
    ( aseqno     VARCHAR(10) NOT NULL  -- A322469
    , superclass VARCHAR(64)
    , status     VARCHAR(8)  -- pass, FAIL, FATAL, timeout
    , PRIMARY KEY(aseqno)
    );
COMMIT;
