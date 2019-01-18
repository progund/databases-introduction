PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE employees(emp_id INTEGER PRIMARY KEY NOT NULL, first_name TEXT NOT NULL, last_name TEXT NOT NULL, email TEXT);
INSERT INTO "employees" VALUES(1,'Dale','Cooper',NULL);
INSERT INTO "employees" VALUES(2,'Laura','Palmer',NULL);
INSERT INTO "employees" VALUES(3,'Harry','Truman',NULL);
INSERT INTO "employees" VALUES(4,'Audrey','Horne',NULL);
COMMIT;
