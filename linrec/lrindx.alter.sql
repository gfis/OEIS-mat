-- lrindx.alter.sql
-- 2019-12-11, Georg Fischer

-- ALTER TABLE lrindx ADD COLUMN (aseqno VARCHAR(8));
COMMIT;
UPDATE lrindx SET aseqno = 'A' || seqno;
COMMIT;
CREATE INDEX ASK ON lrindx ( aseqno   ASC );
