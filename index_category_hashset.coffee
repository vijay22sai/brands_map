fs = require "fs"
redis = require "redis"

host = "127.0.0.1"

client = redis.createClient(6379, host, {})

client.on "error", (err) ->
  console.log("Error " + err)

obj = fs.readFileSync("./category_fashion_map.json").toString()

map = JSON.parse(obj)

for key of map
  client.hset "category_fashion_map", key, map[key], (err) ->
    console.log(err) if err?

console.log "done!"