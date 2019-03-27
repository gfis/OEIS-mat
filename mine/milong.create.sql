--  Table for OEIS - mine occurrences of long terms
--  @(#) $Id$
--  2019-03-25: with counts, signature; cf. output of bfdiff.pl
--  2019-03-22: Georg Fischer
--
DROP    TABLE   IF EXISTS milong;
CREATE  TABLE             milong
    ( id        INT 
    , dummy     VARCHAR(4)    -- not used
    , nsame     INT           -- number of same long terms
    , aseqno    VARCHAR(10)   -- A322469
    , bseqno    VARCHAR(10)   -- A322469
    , ntotal    INT           -- no. terms diffed
    , nequal    INT           -- " " in diff -y
    , nleft     INT           -- "<"
    , nright    INT           -- ">"
    , ndiffer   INT           -- "|"
    , signature VARCHAR(130)  -- eg. ".2.2.2.2.2.2.2.2.2.2.2.2.2.2.2"
    , PRIMARY   KEY(id)         -- aseqno, bseqno)
    );
DROP    VIEW    IF EXISTS milong_view;
CREATE  VIEW    milong_view AS
    SELECT      id, nsame, aseqno, bseqno, ntotal, nequal, nleft, nright, ndiffer, signature
    FROM        milong
    WHERE nequal * 4 >= ntotal -- 1/4 are equal
    ;
COMMIT;
