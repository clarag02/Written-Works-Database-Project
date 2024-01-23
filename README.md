# Project Title: Written Works Database

## Phase 1
Phase 1 entailed creating and designing a relational database and populating it with records from public API's. We used PostgreSQL and included some examples of queries.
All Phase 1 Code, Scripts and Documents are included in this submission. To access these, please refer to Phase 1 Folder.

## Phase 2 
Phase 2 entailed migrating the relational database to a MongoDB database. All Phase 2 Code, Scripts and Documents are included in Phase 2 folder.

## Overview
Our team has chosen to implement a relational database on the topic of written works. A
written work is considered any piece of writing, which can be either books or journal articles.
These are modeled as entities and have an IS-A relationship, such that a Book is a Written Work
and a Journal article is a Written Work. These relationships are modeled in our system by using
single table inheritance. This means that both the Book entity as well as the Journal article entity
are stored in the parent entity: Written Works. The works table contains some fields that are only
relevant for each of its child entities. For example, only books have ISBN’s while only journal
articles contain DOI. Furthermore, this type of inheritance model requires the table Works to
contain a field for the type of the entity of each row. In our system, the Works table has a field
called work_type which either contains a ‘b’ or a ‘j’ representing book and journal article
respectively.
The weak entity in our system is the Character entity. The Book entity, its owner entity
set, and Character entity participate in a one-to-many relationship, that is a book may have many
characters but a character only belongs to one book. Character entity also has a total participation
constraint and is uniquely identified by its partial key character_id. Thus, a Character entity can
be identified uniquely only by considering the primary key of the Book entity. There is a
whole-part relationship, in which if a record of a book is deleted, then the characters belonging to
that book must also be deleted.
A publisher, who can be uniquely identified by their publisher_id, can publish many
works and a work can have many publishers (many-to-many relationship). In addition to this,
every work must be published by a publisher (total participation). Furthermore, similar to the
publisher, an Author, who can be identified by their author_id, can write many Works and a
Work can be written by many authors (many-to-many relationship). Every work must have an
author. Finally, a work can touch on many Subjects, which can be identified by the subject_id,
while a Subject can also be in many different Works (many-to-many relationship). Each Work
has to have a subject, and thus Work has a total participation constraint in this relationship. We
have made relationship tables for all the many-to-many relationships, which include
work_publishers, work_authors, and work_subjects. All of these tables contain a foreign key
work_id, referencing the id in the Work table, and the foreign key subject_id, author_id,
subject_id referencing the corresponding primary key ‘id’ in the table of Publishers, Authors,
and Subjects respectively. Thus, the association tables in our system will hold two foreign keys.
Regarding the technical overview of our system, we used PostgreSQL as our sql
database. We also used Ruby to write a script that helped us alter the data into a usable and
consistent format throughout the system along with populating it into our postgres database.
Furthermore, we wrote a shell script for each public API we used that would simply call the API
and store the contents of the call in a JSON file. For the books API each page/file contained 100
entries while for the journal article API each contained 1000 entries. We ended up using
thousands of pages of data from each API, resulting in hundreds of thousands of records in our
database. The DDL’s for creating tables and triggers can be found in the sql file called
DDLPhase1.sql. The DDL for inserting into tables can be found in the Ruby script called
works.rb. Since all of the data we used amounted to almost 1 GB, we were unable to include all
of the files on our moodle submission. Instead we included a sample of about 100 files for both
journal articles and books to give you an idea of the functionality of our system.

## Presentation
You can view the presentation in the zip folder. it is an mp4 file. Below is a link as well. </br>
https://www.veed.io/view/09a511af-b037-48e1-9e6f-bb7cd0077302?sharingWidget=true&panel=share
