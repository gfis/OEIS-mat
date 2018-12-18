-- Table for OEIS broken link maintenance
-- @(#) $Id$
-- 2018-12-12, Georg Fischer
DROP    TABLE  IF EXISTS brol;
CREATE  TABLE            brol
    ( aseqno        VARCHAR(8)  -- A322469
    , prefix        VARCHAR(32) --
    , postfix       VARCHAR(32) --
    , protocol      VARCHAR(8)  --
    , domain        VARCHAR(32) --
    , port          VARCHAR(8)  --
    , path          VARCHAR(32) --
    , filename      VARCHAR(32) --
    , status        VARCHAR(16) --
    , replurl       VARCHAR(64) --
    , PRIMARY KEY(aseqno)
    );
COMMIT;
