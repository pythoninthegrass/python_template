#!/usr/bin/env python3

# import dnspython
import pymongo
from icecream import ic
from pandas import DataFrame

# verbose icecream
ic.configureOutput(includeContext=True)

# TODO: ORM for mongo; last.fm API to generate data

# connect to mongodb
client = pymongo.MongoClient('mongodb://localhost:27017/')

# create database
db = client["music"]

# create collection (table in relational database)
collection = db["albums"]

# insert data
data = { "artist": "Grimes", "album": "Miss Anthropocene" }
collection.insert_one(data)

# find data
for x in collection.find():
    ic(x)

# query data
for x in collection.find({"artist": "Grimes"}):
    ic(x)

# delete album
collection.delete_one({"album": "Miss Anthropocene"})

# update album as 'Art Angels'
data = { "artist": "Grimes", "album": "Art Angels" }
collection.update_one({"album": "Miss Anthropocene"}, {"$set": data})

# insert data
data = { "artist": "Super Furry Animals", "album": "Phantom Power" }
collection.insert_one(data)

# sort data
for x in collection.find().sort("artist", pymongo.ASCENDING):
    ic(x)

# TODO: debug -- prefers SFA over Grimes
# remove duplicate artists and albums
collection.create_index([("artist", pymongo.ASCENDING), ("album", pymongo.ASCENDING)], unique=True)

# dataframe
df = DataFrame(list(collection.find()))
ic(df)

# drop collection
collection.drop()

# remove database
client.drop_database("music")

# close connection
client.close()
