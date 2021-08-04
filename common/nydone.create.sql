--  Table for OEIS - sequences that are not (yet) done, populated from joeis/notdone.dat
--  @(#) $Id$
--  2021-08-03, Georg Fischer
--
DROP    TABLE  IF EXISTS nydone;
CREATE  TABLE            nydone
    ( aseqno    VARCHAR(10)   -- A322469
    , info      VARCHAR(1024) -- reasons and hints
    , PRIMARY KEY(aseqno)
    );
COMMIT;
