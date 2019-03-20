--  Table for OEIS - terms of sequences (from file 'stripped')
--  @(#) $Id$
--  2019-03-18, Georg Fischer
--
DROP    TABLE  IF EXISTS asdata;
CREATE  TABLE            asdata
    ( aseqno    VARCHAR(10)   -- A322469
    , data      VARCHAR(1024) -- wc -L 971 at 2019-03-18
    , PRIMARY KEY(aseqno)
    );
COMMIT;
