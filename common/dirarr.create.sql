--  Table for OEIS - which jOEIS sequences implement triangle.DirectArray
--  @(#) \$Id\$
--  2024-03-24: Georg Fischer
--
DROP    TABLE  IF EXISTS dirarr;
CREATE  TABLE            dirarr
    ( aseqno     VARCHAR(10) NOT NULL  -- A322469
    , superclass VARCHAR(16)
    , offset1    VARCHAR(16)
    , ank        VARCHAR(64) -- expression for a(int n, int k), or empty
    , PRIMARY KEY(aseqno)
    );
COMMIT;
