--  Table for OEIS - working table for coordination sequences (copy of seq4)
--  @(#) $Id$
--  2020-04-17: Georg Fischer ,
--
DROP    TABLE  IF EXISTS coors;
CREATE  TABLE            coors
    ( aseqno   VARCHAR(10) NOT NULL  -- A322469
    , callcode VARCHAR(32)           -- cfsnum
    , offset   VARCHAR(16)           -- offset
    , parm1    VARCHAR(4096)
    , parm2    VARCHAR(1024)
    , parm3    VARCHAR(256)
    , parm4    VARCHAR(4096)          
    , parm5    VARCHAR(256)          
    , parm6    VARCHAR(128)          
    , parm7    VARCHAR(128)          
    , parm8    VARCHAR(128)          
    , name     VARCHAR(1024)  
    , status   VARCHAR(16)           -- pass, FAIL       
    , PRIMARY KEY(aseqno, callcode)
    );
COMMIT;
