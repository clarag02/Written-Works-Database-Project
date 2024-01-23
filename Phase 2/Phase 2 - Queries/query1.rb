require 'mongo'

# Connect to MongoDB
mongo_client = Mongo::Client.new('mongodb+srv://SOEN363:SOEN363@soen363project.hpxzpcy.mongodb.net/SOEN363') 
# Access the "works" collection
works_collection = mongo_client[:works]

# Query 1
# Search for documents with average_book_rating equal to 1.5
average_rating_to_search = "1.5"

result = works_collection.find(book_rating_average: average_rating_to_search)

result.each do |document|
  puts "Book average rating: #{document['book_rating_average']} => Title: #{document['title']}"
end

puts '--------------------------------------------------------------------------------'
