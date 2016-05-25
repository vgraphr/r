{get, post, requestGet} = require './utils'

get 'alerts', ->
  requestGet 'http://10.20.19.203:8080/api/webApi/alerts?page=1&size=555'
  .then (x) ->
    try
      JSON.parse x[0].body
    catch
      []
