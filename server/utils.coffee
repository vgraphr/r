unless module.dynamic

  clientDir = '../client'
  clientLoc = clientDir + '/index.coffee'

  req = require

  Q       = req "q"
  http    = req 'http'
  express = req 'express'
  request = req 'request'

  Q.longStackSupport = true
  exports.Q = Q

  app = express()
  server = http.Server app
  server.listen 80
  app.use '/assets', express.static clientDir + '/assets/'
  app.get '/', (req, res) ->
    res.send '
      <!doctype html>
      <html>
      <head>
      <title></title>
      <!--
      <link rel="stylesheet" href="assets/bootstrap.css" />
      <link rel="stylesheet" href="assets/bootstrap-rtl.css" />
      <script src="assets/jquery.js"></script>
      <script src="assets/bootstrap.js"></script>
      -->
      </head>
      <body>
      <!--
      <div id="content"></div>
      -->
      <script src="assets/scripts.js"></script>
      </body>
      </html>
    '

  exports.server = server
  exports.app    = app

  exports._data = {Q, http, express, app, request}

else

  {Q, http, express, app, request} = module._data

exports.jalaali = do ->
  toJalaali = (gy, gm, gd) -> d2j(g2d(gy, gm, gd))
  toGregorian = (jy, jm, jd) -> d2g(j2d(jy, jm, jd))
  isValidJalaaliDate = (jy, jm, jd) -> jy >= -61 && jy <= 3177 && jm >= 1 && jm <= 12 && jd >= 1 && jd <= jalaaliMonthLength(jy, jm)
  isLeapJalaaliYear = (jy) -> jalCal(jy).leap is 0
  jalaaliMonthLength = (jy, jm) ->
    return 31 if (jm <= 6)
    return 30 if (jm <= 11)
    return 30 if (isLeapJalaaliYear(jy))
    return 29
  jalCal = (jy) ->
    breaks =  [-61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178]
    bl = breaks.length
    gy = jy + 621
    leapJ = -14
    jp = breaks[0]
    jm = jump = leap = leapG = march = n = i = null
    if (jy < jp || jy >= breaks[bl - 1])
      throw new Error('Invalid Jalaali year ' + jy)
    i = 1
    while (i < bl)
      jm = breaks[i]
      jump = jm - jp
      if (jy < jm)
        break
      leapJ = leapJ + div(jump, 33) * 8 + div(mod(jump, 33), 4)
      jp = jm
      i += 1
    n = jy - jp
    leapJ = leapJ + div(n, 33) * 8 + div(mod(n, 33) + 3, 4)
    if (mod(jump, 33) is 4 && jump - n is 4)
      leapJ += 1
    leapG = div(gy, 4) - div((div(gy, 100) + 1) * 3, 4) - 150
    march = 20 + leapJ - leapG
    if (jump - n < 6)
      n = n - jump + div(jump + 4, 33) * 33
    leap = mod(mod(n + 1, 33) - 1, 4)
    if (leap is -1) 
      leap = 4
    {leap, gy, march}
  j2d = (jy, jm, jd) ->
    r = jalCal(jy)
    g2d(r.gy, 3, r.march) + (jm - 1) * 31 - div(jm, 7) * (jm - 7) + jd - 1
  d2j = (jdn) ->
    gy = d2g(jdn).gy
    jy = gy - 621
    r = jalCal(jy)
    jdn1f = g2d(gy, 3, r.march)
    jd = jm = k = null
    k = jdn - jdn1f
    if (k >= 0)
      if (k <= 185)
        jm = 1 + div(k, 31)
        jd = mod(k, 31) + 1
        return {jy, jm, jd}
      else
        k -= 186
    else
      jy -= 1
      k += 179
      if (r.leap is 1)
        k += 1
    jm = 7 + div(k, 30)
    jd = mod(k, 30) + 1
    return {jy, jm, jd}
  g2d = (gy, gm, gd) ->
    d = div((gy + div(gm - 8, 6) + 100100) * 1461, 4) + div(153 * mod(gm + 9, 12) + 2, 5)+ gd - 34840408
    d = d - div(div(gy + 100100 + div(gm - 8, 6), 100) * 3, 4) + 752
    return d
  d2g = (jdn) ->
    j = 4 * jdn + 139361631
    j = j + div(div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908
    i = div(mod(j, 1461), 4) * 5 + 308
    gd = div(mod(i, 153), 5) + 1
    gm = mod(div(i, 153), 12) + 1
    gy = div(j, 1461) - 100100 + div(8 - gm, 6)
    {gy, gm, gd}
  div = (a, b) -> ~~(a / b)
  mod = (a, b) -> a - ~~(a / b) * b  
  {
    toJalaali
    toGregorian
    isValidJalaaliDate
    isLeapJalaaliYear
    jalaaliMonthLength
    jalCal
    j2d
    d2j
    g2d
    d2g
  }

exports.extend = (target, sources...) ->
  for source in sources
    for key,value of source
      if key is 'except'
        if typeof value is 'object'
          if value.length?
            for k in value
              delete target[k]
          else
            for k of value
              delete target[k]
        else
          delete target[value]
      else
        target[key] = value
  target

Qdenodify = exports.Qdenodify = (owner, fn) ->
  (args...) ->
    Q.promise (resolve, reject) ->
      args.push (err, results...) ->
        if err?
          reject err
        else if results.length is 0
          resolve undefined
        else if results.length is 1
          resolve results[0]
        else
          resolve results
      try
        fn.apply owner, args
      catch err
        reject err

handle = (methodName) -> (route, handler) ->
  route = '/' + route
  appRoute = app._router.stack.filter (x) -> x.route?.path is route
  if appRoute.length > 0
    appRoute = appRoute[0]
    app._router.stack.splice app._router.stack.indexOf(appRoute), 1
  app[methodName] route, (req, res) ->
    Q().then ->
      if req.cookies?.user?
        try
          req.user = jwt.verify req.cookies.encodedUser, jwtSecret
        catch
          req.loggedOut = true
      handler req
    .then (response) ->
      if response?.setUser?
        response.setCookies = [{name: 'user', value: JSON.stringify response.setUser}
                               {name: 'encodedUser', value: jwt.sign response.setUser, jwtSecret, jwtOptions}]
      else if req.loggedOut?
        throw loggedOut: true
      response?.setCookies?.forEach (cookie) ->
        res.cookie cookie.name, cookie.value
      delete response.setUser
      delete response.setCookies
      res.json if methodName is 'get' then response else null
    .catch (err) ->
      console.log 'Error: ' + route + ': ' + err
      try
        err = JSON.stringify err
        console.log 'Error: ' + route + ': ' + err
      res.status(400).json null

exports.get = handle 'get'
exports.post = handle 'post'

exports.requestGet = Qdenodify request, request.get
