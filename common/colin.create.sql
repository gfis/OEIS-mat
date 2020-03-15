--  Table for OEIS - working table for conjectures of C.B.
--  @(#) \$Id\$
--  2020-03-14: Georg Fischer
--
DROP    TABLE  IF EXISTS colin;
CREATE  TABLE            colin
    ( aseqno  VARCHAR(10) NOT NULL  -- A322469
    , PRIMARY KEY(aseqno)
    );
COMMIT;

