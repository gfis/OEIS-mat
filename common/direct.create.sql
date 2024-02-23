--  Table for OEIS - which jOEIS sequences implement DirectSequence 
--  @(#) \$Id\$
--  2023-10-19: Georg Fischer; KW=56?
--
DROP    TABLE  IF EXISTS direct;
CREATE  TABLE            direct
    ( aseqno     VARCHAR(10) NOT NULL  -- A322469
    , callcode   VARCHAR(16)
    , offset1    VARCHAR(16)
    , aint       VARCHAR(64) -- expression for a(int n), or empty
    , az         VARCHAR(64) -- expression for a(Z n),   or empty
    , PRIMARY KEY(aseqno)
    );
COMMIT;
