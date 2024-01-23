require 'mongo'

# Connect to MongoDB
mongo_client = Mongo::Client.new('mongodb+srv://SOEN363:SOEN363@soen363project.hpxzpcy.mongodb.net/SOEN363') 

# 4)
# Aggregate query on an array field.

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
result = works_collection.aggregate(pipeline).to_a

# Output the result
puts "Subjects Count:"
result.each do |document|
  puts "Subject: #{document['subject']}, Count: #{document['count']}"
end
