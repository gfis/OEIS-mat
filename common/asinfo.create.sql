--  Table for OEIS - basic information about sequences
--  @(#) $Id$
--  2019-04-26T19:33:57z: Georg Fischer - generated by extract_info.pl -jc, do not edit here!
--
DROP    TABLE  IF EXISTS asinfo;
CREATE  TABLE            asinfo
    ( aseqno    VARCHAR(10)   -- A322469
    , offset1   BIGINT        -- index of first term, cf. OEIS definition
    , offset2   BIGINT        -- sequential number of first term with abs() > 1, or 1
    , terms     VARCHAR(64)   -- first 8 terms if length <= 64
    , termno    INT           -- number of terms in DATA section
    , datalen   INT           -- length of DATA section
    , keyword   VARCHAR(64)   -- "hard,nice,more" etc.
    , author    VARCHAR(80)   -- of the sequence; allow for apostrophes
    , revision  INT           -- sequential version number
    , created   TIMESTAMP     -- creation     time in UTC
    , access    TIMESTAMP     -- modification time in UTC
    , PRIMARY KEY(aseqno)
    );
COMMIT;
