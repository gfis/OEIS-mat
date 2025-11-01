--  Table for OEIS - definitions (names) of sequences
--  @(#) $Id$ 
--  2025-10-21: with timestamp in A000000
--  2019-03-18, Georg Fischer
--
DROP    TABLE  IF EXISTS asname;
CREATE  TABLE            asname
    ( aseqno    VARCHAR(10)   -- A322469
    , name      VARCHAR(1024) -- wc -L 860 at 2019-03-18
    , PRIMARY KEY(aseqno)
    );
INSERT INTO asname VALUES('A000000', CURRENT_TIMESTAMP);
COMMIT;
