--  Table for OEIS - directory listing of b-files
--  @(#) $Id$
--  2019-03-25T07:56:10z: Georg Fischer - generated by bfdir.pl -c, do not edit here!
--
DROP    TABLE  IF EXISTS bfdir;
CREATE  TABLE            bfdir
    ( aseqno    VARCHAR(10)   -- A322469
    , created   TIMESTAMP     -- creation time in UTC
    , filesize  BIGINT        -- number of bytes
    , PRIMARY KEY(aseqno)
    );
COMMIT;
