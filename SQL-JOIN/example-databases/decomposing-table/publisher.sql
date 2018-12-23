PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE publisher(publisher_id INTEGER PRIMARY KEY NOT NULL,
                               name TEXT UNIQUE NOT NULL);
INSERT INTO "publisher" VALUES(1,'Studentlitteratur');
INSERT INTO "publisher" VALUES(2,'Juneday');
INSERT INTO "publisher" VALUES(3,'Mayday! Mayday!');
INSERT INTO "publisher" VALUES(4,'Oh Really');
INSERT INTO "publisher" VALUES(5,'IT-Literature Inc');
INSERT INTO "publisher" VALUES(6,'Biology Books AB');
COMMIT;
