mongoose = require "mongoose"
fs = require "fs"
redis = require "redis"

host = "127.0.0.1"

mongoUrl = "mongodb://#{host}:27017/flipkartDB"

mongoose.connect mongoUrl, (err) ->
  if err?
    console.log(err)

mongoose.connection.on 'error', (err) ->
  console.logger.error("MONGO ERROR1:",err)

client = redis.createClient(6379, host, {})

client.on "error", (err) ->
      console.log("Error " + err)

App = mongoose.model("App", {}, "category_brands")

appStream = App.find().stream()

appStream.on "data", (doc) ->
  doc = doc.toJSON()
  brands = doc.list
  unless doc.categories[2]?
    console.log doc.categories
    console.log brands
  for brand in brands
    client.sadd("brands", brand, (err) -> console.log(err) if err?)
    client.sadd("categories", doc.categories[2], (err) -> console.log(err) if err?)
    client.sadd(brand, doc.categories[2], (err) -> console.log(err) if err?)
#  process.exit()

appStream.on "error", (err) ->
  console.log err

appStream.on "close", () ->
  console.log "stream is closed"



#
#db = mongojs('local/anabelle')
#
#apps = db.collection('apps')
#
#apps.find (err, docs) ->
#  console.log err
#  console.log docs