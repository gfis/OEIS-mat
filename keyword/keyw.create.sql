--  Table for OEIS - working table for keywords
--  @(#) $Id$
--  2021-07-26, Georg Fischer: copied from seq2.create.sql
--
DROP    TABLE  IF EXISTS keyw;
CREATE  TABLE            keyw
    ( aseqno  VARCHAR(10) NOT NULL  -- A322469
    , keyword VARCHAR(10)
    , PRIMARY KEY(aseqno, keyword)
    );
COMMIT;
