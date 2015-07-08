redis = require "redis"

host = "127.0.0.1"

client = redis.createClient(6379, host, {})

client.on "error", (err) ->
  console.log("Error " + err)


i = 0
client.keys "*", (err, keys) ->
  console.log(err) if err?
  for key in keys
    client.smembers key, (err, members) ->
      if err?
        console.log(err)
      if members.length == 1 and members[0]=="Snapdeal"
        i++
        console.log(i)
