--  Table for OEIS coordination sequences 
--  @(#) $Id$
--  2020-04-25: Georg Fischer
--
DROP    TABLE  IF EXISTS coors;
CREATE  TABLE            coors
    ( aseqno   VARCHAR(10) NOT NULL  -- A265035
    , callcode VARCHAR(32)           -- coors
    , offset   VARCHAR(8)            -- offset
    , tileid   VARCHAR(16)    -- without "GAL": 2.1
    , galv     VARCHAR(4)     -- vertex type number: 1  
    , stdnot   VARCHAR(128)   -- 4.6.12; 4.3.4.6
    , vtype    VARCHAR(64)    -- 12.6.44
    , tarots   VARCHAR(256)   -- A 180'; A120'; B90
    , sequence VARCHAR(4096)  -- 1,3,6,9,11,14,17,21,25,28,30,32,35
    , noflip   VARCHAR(8)     -- 'noflip'
    , parm7    VARCHAR(128)          
    , parm8    VARCHAR(128)          
    , name     VARCHAR(1024)  
    , PRIMARY KEY(aseqno, tileid, galv)
    );
COMMIT;
