--  Table for OEIS - basic information about b-files
--  @(#) $Id$
--  2019-01-24T07:39:01z: Georg Fischer - generated by extract_info.pl -jc, do not edit here!
--
DROP    TABLE  IF EXISTS asinfo;
CREATE  TABLE            asinfo
    ( aseqno    VARCHAR(10)   -- A322469
    , offset1   BIGINT        -- index of first term, cf. OEIS definition
    , offset2   BIGINT        -- sequential number of first term with abs() > 1, or 1
    , terms     VARCHAR(64)   -- first 8 terms if length <= 64
    , keyword   VARCHAR(64)   -- "hard,nice,more" etc.
    , author    VARCHAR(80)   -- of the sequence; allow for apostrophes
    , revision  INT           -- sequential version number
    , created   TIMESTAMP     -- creation     time in UTC
    , access    TIMESTAMP     -- modification time in UTC
    , PRIMARY KEY(aseqno)
    );
COMMIT;
