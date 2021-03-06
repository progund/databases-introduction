CREATE VIEW ALL_ABOUT_BOOK AS
      SELECT title, book.isbn,
             a.name AS author_name,
             publisher.name AS pub
        FROM book
NATURAL JOIN book_author
NATURAL JOIN author a
NATURAL JOIN book_publisher
        JOIN publisher
          ON book_publisher.publisher_id = publisher.publisher_id;
