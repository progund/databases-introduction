PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS cars (Make text,Color text, LicenseNumber text primary key);
INSERT INTO "cars" VALUES('Volvo','Green','ABC 123');
INSERT INTO "cars" VALUES('Honda','Blue','ABC 124');
INSERT INTO "cars" VALUES('Porsche','Green','BBC 666');
INSERT INTO "cars" VALUES('Ferrari','Red','FST 667');
COMMIT;
