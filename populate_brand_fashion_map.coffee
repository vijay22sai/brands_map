fs = require "fs"
redis = require "redis"

host = "127.0.0.1"

client = redis.createClient(6379, host, {})

client.on "error", (err) ->
  console.log("Error " + err)

#obj = fs.readFileSync("./category_fashion_map.json").toString()

#map = JSON.parse(obj)
pos = 0
neg = 0

client.hgetall "category_fashion_map", (err, map) ->
  console.log(err) if err?
  client.smembers "brands", (err, brands) ->
    i = 0
    finishIteration = () ->
      i++
      if i < brands.length
        iterate()
      else
        console.log("Pos: " + pos)
        console.log("Neg: " + neg)
        console.log "done!"
    do iterate = () ->
      brand = brands[i]
      client.smembers brand, (err, categories) ->
        for category in categories
          if(map["#{category}"] == "1")
            return client.hset "brand_fashion_map", brand, true, (err) ->
              pos++
              console.log(err) if err?
              finishIteration()
        client.hset "brand_fashion_map", brand, false, (err) ->
          neg++
          console.log(err) if err?
          finishIteration()