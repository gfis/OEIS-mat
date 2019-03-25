--  Table for OEIS - mine occurrences of long terms
--  @(#) \$Id\$
--  2019-03-22: Georg Fischer
--
DROP    TABLE  IF EXISTS milong;
CREATE  TABLE            milong
    ( id        INT 
    , nsame     INT
    , aseqno    VARCHAR(10)   -- A322469
    , bseqno    VARCHAR(10)   -- A322469
    , PRIMARY KEY(id)         -- aseqno, bseqno)
    );
