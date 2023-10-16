--  Table for OEIS - programs in sequences with their metadata
--  @(#) $Id$
--  2022-06-17T04:34:58z: Georg Fischer - generated by extract_info.pl -apc, do not edit here!
--
DROP    TABLE  IF EXISTS asprog;
CREATE  TABLE            asprog
    ( aseqno    VARCHAR(10)    -- A322469
    , lang      VARCHAR(16)    -- mma, maple, pari, gap etc.
    , curno     INT            -- current number of program for this language: 1, 2, ...
    , type      VARCHAR(16)    -- code for the wrapper pattern: "an" -> "a(n) = ..."
    , program   VARCHAR(16384) -- code lines started and separated by "~~"
    , author    VARCHAR(64)    -- author of the program or the sequence
    , created   TIMESTAMP DEFAULT '1971-01-01 00:00:01' -- time when the program was edited, in UTC
    , revision  INT            -- sequential version number (from JSON of the sequence)
    , PRIMARY KEY(aseqno, lang, curno)
    );
COMMIT;