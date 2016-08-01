Q = require './q'

handle = (isGet) -> (url, params = {}) -> 
  url = "/#{url}?rand=#{Math.random()}&"
  url += Object.keys(params).map((param) -> "#{param}=#{params[param]}").join('&') if isGet
  Q.promise (resolve, reject) ->
    xhr = new XMLHttpRequest()
    xhr.onreadystatechange = ->
      if xhr.readyState is 4
        if xhr.status is 200
          resolve JSON.parse xhr.responseText
        else
          reject xhr.responseText
    methodType = if isGet then 'GET' else 'POST'
    xhr.open methodType, url, true
    if isGet
      xhr.send()
    else
      xhr.setRequestHeader 'Content-Type', 'application/json'
      xhr.send JSON.stringify params    
  .catch (x) -> throw JSON.parse x

get = exports.get = handle true
post = exports.post = handle false

isKeptFresh = {}
exports.keepFresh = (fnName, callback) ->
  return if isKeptFresh[fnName]
  isKeptFresh[fnName] = true
  fn = exports[fnName]
  do kf = (fn) ->
    resultQ = fn()
    callback? resultQ
    Q.all [resultQ, Q.delay 5 * 1000]
    .fin ->
      if isKeptFresh[fnName]
        kf fn
  -> delete isKeptFresh[fnName]

[
  'alerts'
  'sampleAlerts'
]
.forEach (x) ->
  exports[x] = post.bind null, x
