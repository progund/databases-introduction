PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE cars (Make text,Color text, LicenseNumber text primary key);
INSERT INTO "cars" VALUES('Volvo','Green','ABC 123');
INSERT INTO "cars" VALUES('Honda','Silver','HND 900');
INSERT INTO "cars" VALUES('Porsche','Green','BBC 666');
INSERT INTO "cars" VALUES('Ferrari','Red','FST 667');
INSERT INTO "cars" VALUES('Honda','Gold','BLK 000');
COMMIT;
