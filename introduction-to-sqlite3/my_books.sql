PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS books(author TEXT,
                                  title TEXT,
                                   isbn TEXT PRIMARY KEY,
                              publisher TEXT);
INSERT INTO "books" VALUES('John Smith','Life','0-0-0-0-0-1','Bonnier');
INSERT INTO "books" VALUES('James Woody','Love','0-0-0-0-0-2','Bonnier');
INSERT INTO "books" VALUES('Joan Carmen','Guns','0-0-0-0-0-3','Bonnier');
INSERT INTO "books" VALUES('Johnanna Boyd','Code','0-0-0-0-0-4','Bonnier');
INSERT INTO "books" VALUES('Eva Peron','Cars','0-0-0-0-0-5','Books R us');
COMMIT;
