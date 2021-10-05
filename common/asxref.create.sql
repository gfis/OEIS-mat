--  Table for OEIS - information about CROSSREFS in sequences
--  @(#) $Id$
--  2021-10-04T06:55:31z: Georg Fischer - generated by extract_info.pl -jxc, do not edit here!
--
DROP    TABLE  IF EXISTS asxref;
CREATE  TABLE            asxref
    ( aseqno    VARCHAR(10)   -- A322469
    , rseqno    VARCHAR(10)   -- referenced A-number
    , mask      INT           -- bit 1: in "xref", bit 0: in other properties
    , PRIMARY KEY(aseqno, rseqno, mask)
    );
CREATE  INDEX  asxrefa ON asxref
    (aseqno     ASC
    );
CREATE  INDEX  asxrefr ON asxref
    (rseqno     ASC
    );
COMMIT;
