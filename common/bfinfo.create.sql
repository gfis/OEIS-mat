--  Table for OEIS - basic information about b-files
--  @(#) $Id$
--  2019-02-20T12:16:16z: Georg Fischer - generated by extract_info.pl -bc, do not edit here!
--
DROP    TABLE  IF EXISTS bfinfo;
CREATE  TABLE            bfinfo
    ( aseqno    VARCHAR(10)   -- A322469
    , bfimin    BIGINT        -- index in first data line
    , bfimax    BIGINT        -- index in last  data line
    , offset2   BIGINT        -- line number of first term with abs(term) > 1, or 1
    , terms     VARCHAR(64)   -- first 8 terms if length <= 64
    , tail      VARCHAR(8)    -- last 8 digits of last term
    , filesize  INT           -- size of the file in bytes, from the operating system 
    , message   VARCHAR(128)   -- "sign ninc[iline] ndig[iline]"
    , access    TIMESTAMP     -- b-file modification time in UTC
    , PRIMARY KEY(aseqno)
    );
COMMIT;
