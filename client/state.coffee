createPubSub = (name, timeout = 30 * 1000) ->
  data = null
  lastUpdated = 0
  subscribers = []
  setTimeout: (t) -> timeout = t
  onChanged: (callback) ->
    callback data
    subscribers.push callback
    -> subscribers.splice subscribers.indexOf(callback), 1
  get: -> data

  set: set = (newData) ->
    time = +new Date()
    if (newData is data) or (!data and !newData)
      lastUpdated = time
    else if newData?.then?
      if (time - lastUpdated) > timeout
        set loading: true
      newData.then set
    else
      lastUpdated = time unless newData?.loading
      subscribers.forEach (subscriber) ->
        subscriber newData, data
      data = newData
    return newData

['alerts'].forEach (x) ->
  exports[x] = createPubSub x
