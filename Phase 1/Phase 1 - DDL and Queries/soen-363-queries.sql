-- Basic select with simple where clause
select title
from works
where title like '%Time%';

-- Basic select with simple group by clause (without having clause)
-- Returns the total number of books that each publisher published in the database
SELECT p.publisher, COUNT(w.title) as number_of_books
FROM works w
JOIN work_publishers wp ON w.id = wp.work_id
JOIN publishers p ON wp.publisher_id = p.id
GROUP BY p.publisher;

-- Basic select with simple group by clause (with having clause)
-- Returns the total number of books pusblished in the same year whose average book rating is greater than 5 grouped by the year 
SELECT w.year, COUNT(w.book_rating_average) as number_of_books
FROM works w
GROUP BY w.year
HAVING AVG(CAST(w.book_rating_average AS FLOAT)) > 1.0;

-- A simple join select query using carteisian porduct and where clause vs. a join query using on
SELECT w.title, c.name 
FROM works w, characters c
WHERE w.id = c.work_id;

SELECT w.title, c.name
FROM works w
JOIN characters c ON w.id = c.work_id;

-- INNER vs. OUTER vs. LEFT vs RIGHT join
SELECT w.title, c.name
FROM works w
INNER JOIN characters c ON w.id = c.work_id;

SELECT w.title, c.name
FROM works w
LEFT JOIN characters c ON w.id = c.work_id;

SELECT w.title, c.name
FROM works w
RIGHT JOIN characters c ON w.id = c.work_id;

SELECT w.title, c.name
FROM works w
FULL JOIN characters c ON w.id = c.work_id;

SELECT works.title, authors.name
FROM works
INNER JOIN work_authors ON works.id = work_authors.work_id
INNER JOIN authors ON work_authors.author_id = authors.id;

SELECT works.title, authors.name
FROM works
LEFT JOIN work_authors ON works.id = work_authors.work_id
LEFT JOIN authors ON work_authors.author_id = authors.id;

SELECT works.title, authors.name
FROM works
RIGHT JOIN work_authors ON works.id = work_authors.work_id
RIGHT JOIN authors ON work_authors.author_id = authors.id;

SELECT works.title, authors.name
FROM works
FULL JOIN work_authors ON works.id = work_authors.work_id
FULL JOIN authors ON work_authors.author_id = authors.id;

-- Correlated queries

-- Find books that were published more recently than the average publication years of books by the same author
SELECT w1.title, w1.year
FROM works w1
JOIN work_authors wa1 ON wa1.work_id = w1.id
JOIN authors a1 ON a1.id = wa1.author_id
WHERE CAST(w1.year AS FLOAT) > (
  SELECT AVG(CAST(w2.year AS FLOAT))
  FROM works w2
  JOIN work_authors wa2 ON wa2.work_id = w2.id
  JOIN authors a2 ON a2.id = wa2.author_id
  WHERE a2.name = a1.name
);

-- Find the publishers that published more books than the average number of books
SELECT p1.id as publisher_id, p1.publisher as publisher_name
FROM works w1
JOIN work_publishers wp1 ON wp1.work_id = w1.id
JOIN publishers p1 ON wp1.publisher_id = p1.id
GROUP BY p1.id
HAVING COUNT(*) > (
  SELECT AVG(works_count)
  FROM (
    SELECT COUNT(*) as works_count
    FROM works w2
    JOIN work_publishers wp2 ON wp2.work_id = w2.id
    JOIN publishers p2 ON wp2.publisher_id = p2.id
    GROUP BY p2.id
  ) as SubQuery
);

-- Find all works that have more subjects than the average number of subjects per work:
SELECT w.title
FROM works w
WHERE (
  SELECT COUNT(*)
  FROM work_subjects ws
  WHERE ws.work_id = w.id
) > (
  SELECT AVG(sub_count)
  FROM (
    SELECT COUNT(*) as sub_count
    FROM work_subjects
    GROUP BY work_id
  )
);

-- With intersection
SELECT wa.work_id
FROM work_authors wa
JOIN authors a ON wa.author_id = a.id
WHERE a.name LIKE 'A%'
INTERSECT
SELECT work_id FROM work_subjects WHERE subject_id = 2;

-- Equivalence without set operations (intersect)
SELECT wa.work_id FROM work_authors wa
JOIN authors a ON wa.author_id = a.id
JOIN work_subjects s ON wa.work_id = s.work_id
WHERE a.name LIKE 'A%' AND s.subject_id = 2;

-- With Union
SELECT wa.work_id FROM work_authors wa
JOIN authors a ON wa.author_id = a.id
WHERE a.name LIKE 'A%'
UNION
SELECT work_id FROM work_subjects WHERE subject_id = 2;

-- Equivalence without set operations (union)
SELECT DISTINCT w.work_id 
FROM (
    SELECT wa.work_id 
    FROM work_authors wa
    JOIN authors a ON wa.author_id = a.id
    WHERE a.name LIKE 'A%'
    UNION ALL
    SELECT work_id 
    FROM work_subjects 
    WHERE subject_id = 2
) AS w;

-- With difference
SELECT wa.work_id FROM work_authors wa
JOIN authors a ON wa.author_id = a.id
WHERE a.name LIKE 'A%'
EXCEPT
SELECT work_id FROM work_subjects WHERE subject_id = 2;

-- Equivalence without set operations (difference)
SELECT DISTINCT wa.work_id FROM work_authors wa
JOIN authors a ON wa.author_id = a.id
LEFT JOIN work_subjects s ON wa.work_id = s.work_id AND s.subject_id = 2
WHERE a.name LIKE 'A%' AND s.work_id IS NULL;

-- create view high_rated_works
drop view if exists high_rated_books;

CREATE VIEW high_rated_books AS
SELECT 
  works.id, 
  works.year, 
  works.book_isbn,  
  works.title, 
  works.book_rating_average
FROM works
WHERE works.book_rating_average >= '4.0';

SELECT * FROM high_rated_books;

-- create general medecine jounals view
drop view if exists general_medicine_journals;

CREATE VIEW general_medicine_journals AS
SELECT 
  works.id, 
  works.year, 
  works.journal_article_doi, 
  works.journal_article_journal_name, 
  works.title
FROM works
JOIN work_subjects ON works.id = work_subjects.work_id
JOIN subjects ON work_subjects.subject_id = subjects.id
WHERE works.work_type = 'j' AND subjects.subject = 'General Medicine';

SELECT * FROM general_medicine_journals;

-- a) a regular nested query using NOT IN
SELECT a.name
FROM authors a
WHERE a.id NOT IN (
    SELECT wa.author_id
    FROM work_authors wa
    WHERE wa.work_id NOT IN (
        SELECT ws.work_id
        FROM work_subjects ws
        JOIN subjects s ON ws.subject_id = s.id
        WHERE s.subject = 'Philosophy'
    )
);

-- b) Correlated nested query using NOT EXISTS and EXCEPT:
SELECT a.name
FROM authors a
WHERE NOT EXISTS (
    (SELECT wa.work_id FROM work_authors wa WHERE wa.author_id = a.id)
    EXCEPT
    (SELECT ws.work_id FROM work_subjects ws JOIN subjects s ON ws.subject_id = s.id WHERE s.subject = 'Philosophy')
);


-- Covering constraint determines whether the entities in the subclasses collectively include all entities in the superclass
-- i.e. does every Works entity have to be within either the Books entity or Journal_Article entity?
SELECT
    NOT EXISTS (
        SELECT *
        FROM works
        WHERE
            work_type NOT IN ('b', 'j')
    ) AS is_covering_constraint;

-- Overlap constraint determines whether or not two subclasses can contain the same entity
-- i.e can there exist a work that is both a book and a journal article?
SELECT *
FROM works
WHERE book_isbn IS NOT NULL AND journal_article_doi IS NOT NULL;


