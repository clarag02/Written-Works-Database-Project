require 'mongo'

# Connect to MongoDB
mongo_client = Mongo::Client.new('mongodb+srv://SOEN363:SOEN363@soen363project.hpxzpcy.mongodb.net/SOEN363')

# Access the "works" collection
works_collection = mongo_client[:works]

# 5)
# Build the appropriate indexes for queries 1-4, report the index creation statement
# and the query execution time before and after you create the index.

puts '--------------------------------------------------------------------------------'

# 1)
# Search for documents with average_book_rating equal to 1.5
average_rating_to_search = "1.5"

start_time = Time.now
result = works_collection.find(book_rating_average: average_rating_to_search).to_a
end_time = Time.now
puts "Query 1 execution time without index: #{end_time - start_time} seconds"

# Create an index on the 'work_type' and 'book_rating_average' fields
works_collection.indexes.create_one({ work_type: 1, book_rating_average: -1 })

# Measure query execution time after creating the index
start_time = Time.now
result = works_collection.find(book_rating_average: average_rating_to_search).to_a
end_time = Time.now
puts "Query 1 execution time with index: #{end_time - start_time} seconds"

puts '--------------------------------------------------------------------------------'

# 2)
# A query that provides some aggregate data (i.e. number of entities satisfying a criteria)

# Aggregation pipeline
pipeline = [
  { "$match": { "work_type": "b" } },
  { "$group": { "_id": nil, "count": { "$sum": 1 } } }
]

# Measure query execution time before creating the index
start_time = Time.now
result = works_collection.aggregate(pipeline).to_a
end_time = Time.now
puts "Query 2 execution time without index: #{end_time - start_time} seconds"

# Create an index on the 'work_type' field
works_collection.indexes.create_one({ work_type: 1 })

# Measure query execution time after creating the index
start_time = Time.now
result = works_collection.aggregate(pipeline).to_a
end_time = Time.now
puts "Query 2 execution time with index: #{end_time - start_time} seconds"

puts '--------------------------------------------------------------------------------'

# 3)
# Find top 5 entities satisfying a criteria, sorted by an attribute.

pipeline = [
  { "$match": { "work_type": "b" } }, # Filtering by work_type as "fiction"
  { "$sort": { "book_rating_average": -1 } }, # Sorting by book_rating_average in descending order
  { "$limit": 5 }, # Limiting to the top 5 results
  {
    "$project": {
      "_id": 1,
      "title": 1,
      "work_type": 1,
      "book_rating_average": 1
    }
  }
]

# Measure query execution time before creating the index
start_time = Time.now
result = works_collection.aggregate(pipeline).to_a
end_time = Time.now
puts "Query 3 execution time without index: #{end_time - start_time} seconds"

# Create an index on the 'work_type' and 'book_rating_average' fields
works_collection.indexes.create_one({ work_type: 1, book_rating_average: -1 })

# Measure query execution time after creating the index
start_time = Time.now
result = works_collection.aggregate(pipeline).to_a
end_time = Time.now
puts "Query 3 execution time with index: #{end_time - start_time} seconds"

puts '--------------------------------------------------------------------------------'

# Access the "works" collection
works_collection = mongo_client[:works]

pipeline = [
  {
    '$unwind': '$subjects'
  },
  {
    '$group': {
      '_id': '$subjects.name',
      'count': { '$sum': 1 }
    }
  },
  {
    '$project': {
      '_id': 0,
      'subject': '$_id',
      'count': 1
    }
  }
]

# Measure query execution time before creating the index
start_time = Time.now
result = works_collection.aggregate(pipeline).to_a
end_time = Time.now
puts "Query 4 execution time without index: #{end_time - start_time} seconds"

# Create an index on the 'subjects.name' field
works_collection.indexes.create_one({ 'subjects.name': 1 })

# Measure query execution time after creating the index
start_time = Time.now
result = works_collection.aggregate(pipeline).to_a
end_time = Time.now
puts "Query 4 execution time with index: #{end_time - start_time} seconds"

puts '--------------------------------------------------------------------------------'




# Close the MongoDB connection
mongo_client.close
