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
  category = doc.categories[2]
  if category?
    category = category.toLowerCase()
  else
    console.log category
    console.log brands

  for brand in brands
    brand = brand.toLowerCase()
    client.sadd("brands", brand, (err) -> console.log(err) if err?)
    client.sadd("flipkart_brands", brand, (err) -> console.log(err) if err?)
    if category?
      client.sadd("categories", category, (err) -> console.log(err) if err?)
      client.sadd("flipkart_categories", category, (err) -> console.log(err) if err?)
      client.sadd(brand, category, (err) -> console.log(err) if err?)

appStream.on "error", (err) ->
  console.log err

appStream.on "close", () ->
  console.log "stream is closed"

