
{get, post, request, Q, readFile} = require './utils'

req = request

# sidQ = undefined
# do setSidQ = ->
#   sidQ = req.get 'http://10.20.8.91:9090/dashboardpage'
#   .then (res) ->
#     sid = res.headers['set-cookie'][0]
#     sid = sid.substr 0, sid.indexOf ';'
#     sid = sid.substr 11
#     request =
#       get: (url) -> req.get url, "JSESSIONID=#{sid}"
#       post: (url, data) -> req.post url, data, "JSESSIONID=#{sid}"

#     req.get res.headers.location
#     .then ->
#       req.post "http://10.20.8.91:9090/login;jsessionid=#{sid}?1-1.IFormSubmitListener-loginPanel-loginForm",
#         email: 'admin@maxa.ir', password: 'runner'
#   .then (res) ->
#     request.get 'http://10.20.8.91:9090/resourceexplorer'
#   .then (res) ->
#     request.get res.headers.location

# setInterval setSidQ, 30000

post 'alerts', ->
  sidQ.then ->
    request.get 'http://10.20.8.91:9090/api/webApi/alertsNow?startDate=1470480497278'
  .then ({body}) ->
    JSON.parse body

post 'sampleAlerts', ->
  readFile './sampleAlerts.json'
  .then (x) -> JSON.parse x.toString()
