{createPubSub} = require './utils'

[
  'alerts'
].forEach (x) ->
  exports[x] = createPubSub(x)


exports.all = (onlyOnce, keys, callback) ->
  values = {}
  unsubscribeAll = ->
    unsubscribes.forEach (unsubscribe) -> unsubscribe()
  unsubscribes = keys.map (key) ->
    exports[key].onChanged (value) ->
      return if not value? or value.loading

      values[key] = value
        
      if (keys.every (key) -> values[key]?)
        if onlyOnce
          setTimeout unsubscribeAll
        callback keys.map (key) -> values[key]

  return unsubscribeAll

exports.once = (key, callback) ->
  exports.all true, [key], ([x]) ->
    callback x

exports.ready = (key, callback) ->
  exports.all false, [key], ([x]) ->
    callback x
