--  Table for OEIS - definitions (names) of sequences
--  @(#) $Id$
--  2019-03-18, Georg Fischer
--
DROP    TABLE  IF EXISTS asname;
CREATE  TABLE            asname
    ( aseqno    VARCHAR(10)   -- A322469
    , name      VARCHAR(1024) -- wc -L 860 at 2019-03-18
    , PRIMARY KEY(aseqno)
    );
COMMIT;
