Q = require './q'
state = require './state'
utils = require './utils'

handle = (isGet) -> (url, params = {}) -> 
  url = "/#{url}?rand=#{Math.random()}&"
  url += Object.keys(params).map((param) -> "#{param}=#{params[param]}").join('&') if isGet
  prevUser = state.user.get()
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

get = exports.get = (args...) -> handle(true) args...
post = exports.post = (args...) -> handle(false) args...

changableDelay = ->
  defer = Q.defer()
  timeout = null
  (delay) ->
    if timeout?
      clearTimeout timeout
    timeout = setTimeout ->
      defer.resolve()
    return defer.promise

kfData = {}
keepFresh = (name, timeout = 0) ->
  kfData[name].timeout
  if kfData[name]?
    kfData[name].delay timeout ##############
    return ->
  kfData[name].delay = changableDelay() timeout ############
  do kf = ->
    Q.all [get(name), Q.delay kfData[name].timeout]
    .then ([data]) ->
      state[name].set data
    .fin ->
      if kfData[name]?
        kf()
  return -> delete kfData[name]

keepFresh 'alerts'
