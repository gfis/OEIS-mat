--  Table for OEIS - working table for conjectures (mainly of C.B.)
--  @(#) \$Id\$
--  2020-04-16: renamed from ...
--  2020-03-14: Georg Fischer
--
DROP    TABLE  IF EXISTS cojec;
CREATE  TABLE            cojec
    ( aseqno  VARCHAR(10) NOT NULL  -- A322469
    , PRIMARY KEY(aseqno)
    );
COMMIT;

