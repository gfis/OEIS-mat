-- Manual updates for known problems
-- @(#) $Id$
-- 2018-12-13, Georg Fischer
UPDATE url1 SET status='special'           , access=CURRENT_TIMESTAMP WHERE host='somos.crg4.com';
UPDATE url1 SET status='special'           , access=CURRENT_TIMESTAMP WHERE host='jonathanwellons.com';
UPDATE url1 SET status='repaired Mathar'   , access=CURRENT_TIMESTAMP WHERE host='http';
COMMIT;
