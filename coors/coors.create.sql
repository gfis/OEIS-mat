--  Table for OEIS coordination sequences 
--  @(#) $Id$
--  2020-05-05: rseqno is in key
--  2020-04-25: Georg Fischer
--
DROP    TABLE  IF EXISTS coors;
CREATE  TABLE            coors
    ( aseqno   VARCHAR(10) NOT NULL  -- A265035 - real OEIS A-number
    , callcode VARCHAR(32)           -- 'coors'
    , offset   VARCHAR(8)            -- offset = 0
    , galid    VARCHAR(16) NOT NULL  -- Gal.3.44.3
    , stdnot   VARCHAR(128)          -- 4.6.12; 4.3.4.6
    , vtype    VARCHAR(64)           -- BG: 12.6.4
    , tarots   VARCHAR(256)          -- A 180'; A120'; B90
    , sequence VARCHAR(512)          -- 1,3,6,9,11,14,17,21,25,28,30,32,35
    , tilingno INT                   -- sequential tiling number
    , newnot   VARCHAR(128)          -- letter-encoded new notation
    , rseqno   VARCHAR(128)          -- BG's version in a250120.html
    , name     VARCHAR(1024)         -- OEIS sequence name 
    , PRIMARY KEY(rseqno, galid)
    );
COMMIT;
