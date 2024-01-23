require 'rest-client'
require 'json'
require 'pg'

# Constants
MAX_COUNT = 1500000

# Create database connection
db = PG.connect(
  dbname: 'works',
  user: 'postgres',
  password: '', # add your postgresql password here
  host: 'localhost',
  port: '5432'
)


# Helper methods
def insert_book_into_works(db, book)
  #making the date format consistant by just showing the year
  date = book.dig('publish_date',0)
  if date && date.size != 4
    if date.match?(/\b\d{4}\b/)
      date = date.match(/\b\d{4}\b/)[0]
    else
      date = nil
    end
  end
  resp = db.exec("INSERT INTO works
              (year, book_isbn, title, book_subtitle, book_rating_average, book_ddc, work_type)
              VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id",[
              date, book.dig('isbn',0), book['title'],
              book.dig('book_subtitle'), book[ "ratings_average" ], book.dig('ddc',0), 'b'])
  resp[0]['id']
end

def insert_author(db, name)
  author_id = db.exec("SELECT id FROM authors WHERE name = $1", [name])
  if author_id.ntuples.zero?
    resp = db.exec("INSERT INTO authors (name) VALUES ($1) RETURNING id", [name])
    resp[0]['id']
  else
    author_id[0]['id']
  end
end

def insert_subject(db, subject)
  subject_id = db.exec("SELECT id FROM subjects WHERE subject = $1", [subject])
  if subject_id.ntuples.zero?
    resp = db.exec("INSERT INTO subjects (subject) VALUES ($1) RETURNING id", [subject])
    resp[0]['id']
  else
    subject_id[0]['id']
  end
end

def insert_publisher(db, publisher)
  publisher_id = db.exec("SELECT id FROM publishers WHERE publisher = $1", [publisher])
  if publisher_id.ntuples.zero?
    resp = db.exec("INSERT INTO publishers (publisher) VALUES ($1) RETURNING id", [publisher])
    resp[0]['id']
  else
    publisher_id[0]['id']
  end
end

def insert_person(db, name, work_id)
  db.exec("INSERT INTO characters (name, work_id) VALUES ($1, $2)", [name, work_id])
end

def insert_books(db)
  # Fetch books
  page = 1
  count = 0
  while count < MAX_COUNT
    # response = RestClient.get("https://openlibrary.org/search.json?q=dog&page=#{page}")
    # data = JSON.parse(response.body)
    # read books.json instead of fetching data from openlibrary.org
     data = JSON.parse(File.read("C:\\Users\\ahmad\\Desktop\\Courses\\Fall2023\\SOEN 363\\Project\\ProjectPhase1\\data\\Books\\books-#{page.to_s.rjust(4,'0')}.json"))

    docs = data['docs']
    break if docs.nil? || docs.empty?

    docs.each do |book|
      break if count >= MAX_COUNT

      book_id = insert_book_into_works(db, book)

      # Insert first author name
      if name = book.dig('author_name',0)
        author_id = insert_author(db, name)
        db.exec("INSERT INTO work_authors (author_id, work_id) VALUES ($1, $2)", [author_id, book_id])
      end

      # Insert subjects
      if book['subject']
        book['subject'].uniq.each do |subject|
          subject_id = insert_subject(db, subject)
          db.exec("INSERT INTO work_subjects (work_id, subject_id) VALUES ($1, $2)", [book_id, subject_id])
        end
      end

      # Insert publishers
      if book['publisher']
        book['publisher'].uniq.each do |publisher|
          publisher_id = insert_publisher(db, publisher)
          db.exec("INSERT INTO work_publishers (publisher_id, work_id) VALUES ($1, $2)", [publisher_id, book_id])
        end
      end

      # Insert persons
      if book['person']
        book['person'].uniq.each do |person|
          insert_person(db, person, book_id)
        end
      end

      count += 1
    end

    page += 1
    sleep 2
  end
end

def insert_articles(db)
  # Retrieve articles using pagination
  cursor = '*'
  count = 0
  page = 1
  while count < MAX_COUNT
    #puts File.read("data\\articles-#{page.to_s.rjust(4,'0')}.json")
    #response = RestClient.get("https://api.crossref.org/works?filter=type%3Ajournal-article&cursor=#{cursor}&rows=1000").body
    response =File.read("C:\\Users\\ahmad\\Desktop\\Courses\\Fall2023\\SOEN 363\\Project\\ProjectPhase1\\data\\Articles\\articles-#{page.to_s.rjust(4,'0')}.json")
    results = JSON.parse(response)['message']['items']


    results.each do |result|
      date = result['created']['date-parts'][0]
      # convert date to consistent format by just choosing the year
      date = date[0]

      doi = result['DOI']
      title = result['title']
      journal_name = (result['container-title'] || [])[0] || ''
      publisher = result['publisher'] || ''

      next if title.nil? || title.empty?

      # Insert work record
      resp = db.exec('INSERT INTO works (year, journal_article_doi, title, journal_article_journal_name, work_type) VALUES ($1, $2, $3, $4, $5) RETURNING id', [date, doi, title.first, journal_name, 'j'])
      book_id = resp[0]['id']

      # Insert authors
      authors = result['author'] || []
      authors.collect {|a| "#{a['given']} #{a['family']}"}.uniq.each do |author|
        # Insert author and create join table record
        author_id = insert_author(db, author)
        db.exec("INSERT INTO work_authors (author_id, work_id) VALUES ($1, $2)", [author_id, book_id])
      end

      # Insert subject and create join table record for each subject
      subjects = result['subject'] || []
      subjects.uniq.each do |subject|
        subject_id = insert_subject(db, subject)
        db.exec("INSERT INTO work_subjects (work_id, subject_id) VALUES ($1, $2)", [book_id, subject_id])
      end

      # Insert publisher and create join table record
      publisher_id = insert_publisher(db, publisher)
      db.exec("INSERT INTO work_publishers (publisher_id, work_id) VALUES ($1, $2)", [publisher_id, book_id])

      count += 1
      break if count >= MAX_COUNT
    end

    page += 1
    cursor = response['message']['next-cursor']
  end

end

insert_books(db)
insert_articles(db)


# Close the database connection
db.close
