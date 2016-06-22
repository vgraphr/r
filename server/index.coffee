{get, post, requestGet, Q} = require './utils'

sidQ = Q()
setSidQ = ->
  sidQ = requestGet 'http://10.20.19.203:8080/dashboardpage'
  .then (res) ->
    sid = res.headers['set-cookie'][0]
    sid = sid.substr 0, sid.indexOf ';'
    sid = sid.substr 11
    QAll [sid, requestGet res.headers.location]
  .then ([sid]) ->
    Q.all [
      sid
      post "http://10.20.19.203:8080/login;jsessionid=#{sid}?1-1.IFormSubmitListener-loginPanel-loginForm",
        email: 'admin@maxa.ir', password: 'runner'
    ]
  .then ([sid]) ->
    sid
# setInterval setSidQ, 10 * 60 * 1000

get 'alerts', ->
  sidQ.then ->
    requestGet 'http://10.20.19.203:8080/api/webApi/test'
  .then (x) ->
    JSON.parse x[0].body
