mongoose = require "mongoose"
fs = require "fs"
redis = require "redis"

host = "127.0.0.1"

mongoUrl = "mongodb://#{host}:27017/myntraDB"

mongoose.connect mongoUrl, (err) ->
  if err?
    console.log(err)

mongoose.connection.on 'error', (err) ->
  console.logger.error("MONGO ERROR1:",err)

client = redis.createClient(6379, host, {})

client.on "error", (err) ->
  console.log("Error " + err)

App = mongoose.model("App", {}, "brands_collection")

appStream = App.find().stream()

appStream.on "data", (doc) ->
  doc = doc.toJSON()
  brands = doc.list
  return unless brands?
  category = "myntra fashion"
  client.sadd("categories", category, (err) -> console.log(err) if err?)
  client.sadd("myntra_categories", category, (err) -> console.log(err) if err?)

  for brand in brands
    brand = brand.toLowerCase()
    client.sadd("brands", brand, (err) -> console.log(err) if err?)
    client.sadd("myntra_brands", brand, (err) -> console.log(err) if err?)
    client.sadd(brand, category, (err) -> console.log(err) if err?)

appStream.on "error", (err) ->
  console.log err

appStream.on "close", () ->
  console.log "stream is closed"