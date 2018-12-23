PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS cars (make TEXT, color TEXT, licensenumber TEXT PRIMARY KEY);
INSERT INTO "cars" VALUES('Volvo','Green','ABC 123');
INSERT INTO "cars" VALUES('Honda','Blue','ABC 124');
INSERT INTO "cars" VALUES('Porsche','Green','BBC 666');
INSERT INTO "cars" VALUES('Ferrari','Red','FST 667');
COMMIT;
