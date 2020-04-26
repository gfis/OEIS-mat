--  Table for OEIS coordination sequences 
--  @(#) $Id$
--  2020-04-25: Georg Fischer
--
DROP    TABLE  IF EXISTS coors;
CREATE  TABLE            coors
    ( aseqno   VARCHAR(10) NOT NULL  -- A322469
    , callcode VARCHAR(32)           -- coors
    , offset   VARCHAR(4)            -- offset
    , galid    VARCHAR(16)
    , stdnot   VARCHAR(128)
    , vertex   VARCHAR(64)
    , tarots   VARCHAR(256)          
    , sequence VARCHAR(4096)          
    , parm6    VARCHAR(128)          
    , parm7    VARCHAR(128)          
    , parm8    VARCHAR(128)          
    , name     VARCHAR(1024)  
    , PRIMARY KEY(aseqno, galid)
    );
COMMIT;
