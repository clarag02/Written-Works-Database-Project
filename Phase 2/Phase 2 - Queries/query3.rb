require 'mongo'

# Connect to MongoDB
mongo_client = Mongo::Client.new('mongodb+srv://SOEN363:SOEN363@soen363project.hpxzpcy.mongodb.net/SOEN363') 


# 3)
# Find top 5 entities satisfying a criteria, sorted by an attribute.

# Access the "works" collection
works_collection = mongo_client[:works]

pipeline = [
  { "$match": { "work_type": "b" } }, # Filtering by work_type by book
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

result = works_collection.aggregate(pipeline).to_a

# Output the result
puts "Top 5 books:"
result.each_with_index do |document, index|
  puts "#{index + 1}. Title: #{document['title']}, Work Type: #{document['work_type']}, Rating: #{document['book_rating_average']}"
end
