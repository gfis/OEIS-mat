--  OEIS-mat: lrindx - working table for index of linear recurrences
--  @(#) $Id$
--  2019-02-22 09:59:37, generated by extract_linrec.pl - DO NOT EDIT HERE!
--
DROP    TABLE  IF EXISTS lrindx;
CREATE  TABLE            lrindx
    ( aseqno    VARCHAR(10) NOT NULL  -- A322469
    , mode      VARCHAR(8)  NOT NULL  -- index, link, mmacall, xtract
    , style     VARCHAR(8)    -- for insertions, deletions
    , lorder    INT         NOT NULL  -- order = number of right terms
    , signature VARCHAR(1024) -- comma separated, without "( )"
    , termno    INT                   -- number of initial terms
    , initerms  VARCHAR(1024) -- dito
    , PRIMARY KEY(aseqno, mode, lorder)
    );
COMMIT;
--  OEIS-mat: lrlink - working table for index of linear recurrences
--  @(#) $Id$
--  2019-02-22 09:59:37, generated by extract_linrec.pl - DO NOT EDIT HERE!
--
DROP    TABLE  IF EXISTS lrlink;
CREATE  TABLE            lrlink
    ( aseqno    VARCHAR(10) NOT NULL  -- A322469
    , mode      VARCHAR(8)  NOT NULL  -- index, link, mmacall, xtract
    , style     VARCHAR(8)    -- for insertions, deletions
    , lorder    INT         NOT NULL  -- order = number of right terms
    , signature VARCHAR(1024) -- comma separated, without "( )"
    , termno    INT                   -- number of initial terms
    , initerms  VARCHAR(1024) -- dito
    , PRIMARY KEY(aseqno, mode, lorder)
    );
COMMIT;
