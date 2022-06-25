--  Table for OEIS - new sequences that are prepared and packed for joeis
--  @(#) \$Id\$
--  2022-06-22, Georg Fischer: copied form poeis.create.sql
--
DROP    TABLE  IF EXISTS noeis;
CREATE  TABLE            noeis
    ( aseqno     VARCHAR(10) NOT NULL  -- A322469
    , superclass VARCHAR(64)
    , status     VARCHAR(8)  -- pass, FAIL, FATAL, timeout
    , PRIMARY KEY(aseqno)
    );
COMMIT;
