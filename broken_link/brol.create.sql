-- Table for OEIS broken link maintenance
-- @(#) $Id$
-- 2018-12-13 17:52:03 - generated by brol_prepare.pl -c brol, do not edit here!
DROP    TABLE  IF EXISTS brol;
CREATE  TABLE            brol
    ( linetype   VARCHAR(2)  -- %H
    , aseqno     VARCHAR(8)      
    , key2       VARCHAR(4)      
    , prefix     VARCHAR(128)    
    , protocol   VARCHAR(8)      
    , host       VARCHAR(64)     
    , port       VARCHAR(8)      
    , path       VARCHAR(512)    
    , filename   VARCHAR(512)    
    , status     VARCHAR(32)     
    , access     TIMESTAMP       
    , replurl    VARCHAR(512)    
    , PRIMARY KEY(aseqno, key2)
    );
COMMIT;
