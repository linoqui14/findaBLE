# Import the python libraries
from pymongo import MongoClient
from pprint import pprint

# Choose the appropriate client
client = MongoClient('mongodb://localhost:27017')

# Connect to the test db 
db=client['findable']

# Use the employee collection
users = db['esps']
# users = db['room']
# mydict = { "name": "John", "address": "Highway 37" }
# users.insert_one(mydict)
all = users.find()
for x in all:
    print( type(x) )
