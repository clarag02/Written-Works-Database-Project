require 'pg'
require 'mongo'

# Connect to PostgreSQL
pg_conn = PG.connect(
  dbname: 'works', #set it to what you named your postgres db
  user: 'postgres',
  password: 'Ahmad', #set your own postgres password
  host: 'localhost'
)

# Connect to MongoDB
mongo_client = Mongo::Client.new('mongodb+srv://SOEN363:SOEN363@soen363project.hpxzpcy.mongodb.net/SOEN363') #Put link to connect to the mongoDB here
works_collection = mongo_client[:works]
subjects_collection = mongo_client[:subjects]
publishers_collection = mongo_client[:publishers]
authors_collection = mongo_client[:authors]

#Drop collections if exist
# works_collection.drop
# authors_collection.drop
# publishers_collection.drop
# subjects_collection.drop

# Function to fetch records from PostgreSQL and insert into MongoDB
def populate_mongo(pg_conn, mongo_collection, pg_table, mongo_field=nil)
  mongo_data = {}
  pg_conn.exec("SELECT * FROM #{pg_table}") do |pg_result|
    pg_result.each do |row|
      name = mongo_field || pg_table.gsub(/s$/,'')
      mongo_collection.insert_one({ _id: row['id'], name: row[name]})
      mongo_data[row['id'].to_i] = row[name]
    end
  end
  mongo_data
end

# Populate subjects, publishers, and authors in MongoDB and store their IDs and names
subjects_data = populate_mongo(pg_conn, subjects_collection, 'subjects')
publishers_data = populate_mongo(pg_conn, publishers_collection, 'publishers')
authors_data = populate_mongo(pg_conn, authors_collection, 'authors', 'name')

# Retrieve data from PostgreSQL and insert into MongoDB
pg_conn.exec("SELECT * FROM works") do |works_result|
  works_result.each do |work|
    work_data = {
      year: work['year'],
      book_isbn: work['book_isbn'],
      journal_article_doi: work['journal_article_doi'],
      journal_article_journal_name: work['journal_article_journal_name'],
      title: work['title'],
      book_subtitle: work['book_subtitle'],
      book_rating_average: work['book_rating_average'],
      book_ddc: work['book_ddc'],
      work_type: work['work_type'],
      characters: [],
      authors: [],
      subjects: [],
      publishers: []
    }

    # Retrieve characters for each work
    pg_conn.exec_params("SELECT * FROM characters WHERE work_id = $1", [work['id']]) do |characters_result|
      characters_result.each do |character|
        work_data[:characters] << { name: character['name'] }
      end
    end

    # Retrieve authors for each work
    pg_conn.exec_params("SELECT author_id FROM work_authors WHERE work_id = $1", [work['id']]) do |authors_result|
      authors_result.each do |author|
        author_id = author['author_id'].to_i
        work_data[:authors] << { id: author_id, name: authors_data[author_id] }
      end
    end

    # Retrieve subjects for each work
    pg_conn.exec_params("SELECT subject_id FROM work_subjects WHERE work_id = $1", [work['id']]) do |subjects_result|
      subjects_result.each do |subject|
        subject_id = subject['subject_id'].to_i
        work_data[:subjects] << { id: subject_id, name: subjects_data[subject_id] }
      end
    end

    # Retrieve publishers for each work
    pg_conn.exec_params("SELECT publisher_id FROM work_publishers WHERE work_id = $1", [work['id']]) do |publishers_result|
      publishers_result.each do |publisher|
        publisher_id = publisher['publisher_id'].to_i
        work_data[:publishers] << { id: publisher_id, name: publishers_data[publisher_id] }
      end
    end

    # Insert the work data with embedded characters, authors, subjects, and publishers into MongoDB
    works_collection.insert_one(work_data)
  end
end

# Close connections
pg_conn.close
mongo_client.close
