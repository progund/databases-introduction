PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE persons (last_name TEXT, first_name TEXT, born TEXT, sex TEXT);
INSERT INTO "persons" VALUES('Nilsson','Tommy','1960-03-11','Man');
INSERT INTO "persons" VALUES('Norum','John','1964-02-23','Man');
INSERT INTO "persons" VALUES('Jett','Joan','1958-09-22','Woman');
INSERT INTO "persons" VALUES('Wilson','Ann','1950-06-19','Woman');
COMMIT;
