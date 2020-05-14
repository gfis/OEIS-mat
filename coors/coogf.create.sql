--  Table for generating function of OEIS coordination sequences 
--  @(#) $Id$
--  2020-05-12: Georg Fischer
--
DROP    TABLE  IF EXISTS coogf;
CREATE  TABLE            coogf
    ( aseqno   VARCHAR(10) NOT NULL  -- A265035 - real OEIS A-number
    , denatt   VARCHAR(16)           -- attributes of denominator
    , compar   VARCHAR(8)            -- < or =
    , numatt   VARCHAR(16)           -- attributes of numerator
    , numv     VARCHAR(512)          -- coefficient vector for numerator
    , denv     VARCHAR(512)          -- coefficient vector for denominator
    , PRIMARY KEY(aseqno)
    );
COMMIT;
