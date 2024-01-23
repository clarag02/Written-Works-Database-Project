-- DROP TABLE IF EXISTS works CASCADE;
-- DROP TABLE IF EXISTS authors CASCADE;
-- DROP TABLE IF EXISTS subjects CASCADE;
-- DROP TABLE IF EXISTS publishers CASCADE;
-- DROP TABLE IF EXISTS work_authors CASCADE;
-- DROP TABLE IF EXISTS work_subjects CASCADE;
-- DROP TABLE IF EXISTS work_publishers CASCADE;
-- DROP TABLE IF EXISTS characters CASCADE;


CREATE TABLE works (
	id BIGSERIAL PRIMARY KEY,
	year TEXT,
	book_isbn TEXT,
	journal_article_doi TEXT,
	journal_article_journal_name TEXT,
	title TEXT,
	book_subtitle TEXT,
	book_rating_average TEXT,
	book_ddc TEXT, 
	work_type TEXT
);

CREATE TABLE authors (
	id BIGSERIAL PRIMARY KEY,
	name TEXT
);

CREATE TABLE subjects (
	id BIGSERIAL PRIMARY KEY,
	subject TEXT
);

CREATE TABLE publishers (
	id BIGSERIAL PRIMARY KEY,
	publisher TEXT
);

CREATE TABLE characters (
	id BIGSERIAL PRIMARY KEY,
	name TEXT,
	work_id INTEGER,
	FOREIGN KEY (work_id) REFERENCES works(id)
);

CREATE TABLE work_authors (
	work_id INTEGER,
	author_id INTEGER,
	PRIMARY KEY (work_id, author_id)
);

CREATE TABLE work_subjects (
	work_id INTEGER,
	subject_id INTEGER,
	PRIMARY KEY (work_id, subject_id)
);

CREATE TABLE work_publishers (
	work_id INTEGER,
	publisher_id INTEGER,
	PRIMARY KEY (work_id, publisher_id)
);

-- Trigger function to handle deletion from the works table
-- handling cascading updates or deletes, checking complex conditions before allowing an update or delete, 
-- or enforcing referential integrity across multiple tables.
CREATE OR REPLACE FUNCTION delete_work_cascade()
RETURNS TRIGGER AS $$
BEGIN
  -- Delete corresponding records from work_authors
  DELETE FROM work_authors WHERE work_id = OLD.id;

  -- Delete corresponding records from work_subjects
  DELETE FROM work_subjects WHERE work_id = OLD.id;

  -- Delete corresponding records from work_publishers
  DELETE FROM work_publishers WHERE work_id = OLD.id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger to activate the cascade on deletion from the works table
CREATE TRIGGER trigger_delete_work_cascade
BEFORE DELETE ON works
FOR EACH ROW
EXECUTE FUNCTION delete_work_cascade();



