-- @(#) $Id$
-- population of the unique URL table
-- 2018-12-13, Georg Fischer
--
INSERT INTO url1 (
SELECT       protocol, host, port, path, substr(filename, 1, 250)
    , count(*)
    , "unknown"
    , current_timestamp
    FROM brol 
    GROUP BY protocol, host, port, path, filename
);
COMMIT;

