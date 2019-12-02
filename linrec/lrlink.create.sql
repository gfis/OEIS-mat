--  OEIS-mat: lrlink - working table for index of linear recurrences
--  @(#) $Id$
--  2019-11-05 21:46:14, generated by extract_linrec.pl - DO NOT EDIT HERE!
--
DROP    TABLE  IF EXISTS lrlink;
CREATE  TABLE            lrlink
    ( lorder    INT         NOT NULL  -- order = number of right terms
    , compsig   VARCHAR(240)          -- blank separated, truncated, without "( )"
    , seqno     VARCHAR(8)  NOT NULL  -- 322469 without 'A'
    , sigorder  INT                   -- number of signature elements
    , signature VARCHAR(1020)         -- comma separated, without "( )"
    , mode      VARCHAR(8)
    , spec      VARCHAR(16)
    , termno    INT                   -- number of initial terms
    , initerms  VARCHAR(1024) -- dito
    , PRIMARY KEY(lorder, compsig, seqno, sigorder, mode)
    );
COMMIT;