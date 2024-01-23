require 'mongo'

# Connect to MongoDB
mongo_client = Mongo::Client.new('mongodb+srv://SOEN363:SOEN363@soen363project.hpxzpcy.mongodb.net/SOEN363') # Replace with your MongoDB connection string

# 6)
# a) Demonstrate a full text search without indexes
# Access the "authors" collection
authors_collection = mongo_client[:authors]

# Search query using regex
search_query = /Paulin/i

# Perform the search using regex without an index
start_time = Time.now
result = authors_collection.find({ "name": search_query })
end_time = Time.now

# Output the results
result.each do |document|
  puts "id: #{document['_id']} name: #{document['name']}"

end
puts "Query 6 execution time without index: #{end_time - start_time} seconds"

puts "----------------------------------------------------------------------------------"

# 6)
# b) Demonstrate a full text search with indexes
authors_collection = mongo_client[:authors]

# Create a text index on the "name" field
authors_collection.indexes.create_one({ "name" => "text" })

# Perform a full-text search on the "name" field
search_query = "Paulin"

start_time = Time.now
result = authors_collection.find({ "$text" => { "$search" => search_query } })
end_time = Time.now

# Output the results
result.each do |document|
  puts "id: #{document['_id']} name: #{document['name']}"
end
puts "Query 6 execution time with index: #{end_time - start_time} seconds"
puts '--------------------------------------------------------------------------------'


# Close the MongoDB connection
mongo_client.close
