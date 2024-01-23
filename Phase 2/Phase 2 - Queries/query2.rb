require 'mongo'

# Connect to MongoDB
mongo_client = Mongo::Client.new('mongodb+srv://SOEN363:SOEN363@soen363project.hpxzpcy.mongodb.net/SOEN363')

# Access the "works" collection
works_collection = mongo_client[:works]

# 2)
# A query that provides some aggregate data (i.e. number of entities satisfying a criteria)

# Aggregation pipeline
pipeline = [
  { "$match": { "work_type": "b" } },
  { "$group": { "_id": nil, "count": { "$sum": 1 } } }
]

result = works_collection.aggregate(pipeline).to_a

puts "Count of all works of type book: #{result.first['count']}"
