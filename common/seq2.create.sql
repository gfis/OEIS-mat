--  Table for OEIS - working table for sequence numbers and 2 fields
--  @(#) $Id$
--  2025-11-27: remove BINARY again
--  2023-07-25: INDEX
--  2020-11-14: BINARY aseqno for eta
--  2020-03-12: info was 1024
--  2019-06-13: Georg Fischer ,
--
DROP    TABLE  IF EXISTS seq2;
CREATE  TABLE            seq2
    ( aseqno  VARCHAR(10) NOT NULL  -- A322469
    , info    VARCHAR(4096)
    , PRIMARY KEY(aseqno)
    );
CREATE  INDEX  seq2d ON seq2
    ( info ASC
    );
COMMIT;
