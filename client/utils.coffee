`
var isOpera = !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0;
    // Opera 8.0+ (UA detection to detect Blink/v8-powered Opera)
var isFirefox = typeof InstallTrigger !== 'undefined';   // Firefox 1.0+
var isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0;
    // At least Safari 3+: "[object HTMLElementConstructor]"
var isChrome = !!window.chrome && !isOpera;              // Chrome 1+
var isIE = /*@cc_on!@*/false || !!document.documentMode; // At least IE6
`
isOpera   = isOpera
isFirefox = isFirefox
isSafari  = isSafari
isChrome  = isChrome
isIE      = isIE
isEdge    = (navigator.appName is 'Netscape') and navigator.appVersion.indexOf('Trident') is -1

createCookie = (name, value, days) ->
  if days
    date = new Date()
    date.setTime +date + (days * 24 * 60 * 60 * 1000)
    expires = "; expires=#{date.toGMTString()}"
  else
    expires = ''
  document.cookie = "#{name}=#{value}#{expires}; path=/"

readCookie = (name) ->
  nameEQ = "#{name}="
  resultArray = document.cookie.split ';'
  .map (c) ->
    while c.charAt(0) is ' '
      c = c.substring 1, c.length
    c
  .filter (c) ->
    c.indexOf(nameEQ) is 0
  [result] = resultArray
  result?.substring nameEQ.length

eraseCookie = (name) ->
  createCookie name, '', -1

generateId = do ->
  i = 0
  -> i++

without = (array, item) ->
  index = array.indexOf item
  result = array.slice()
  if ~index
    result.splice index, 1
  result

extend = (target, sources...) ->
  sources.forEach (source) ->
    Object.keys(source).forEach (key) ->
      value = source[key]
      unless key is 'except'
        target[key] = value
      else
        if Array.isArray value
          value.forEach (k) -> delete target[k]
        else if typeof value is 'object'
          Object.keys(value).forEach (k) -> delete target[k]
        else
          delete target[value]
  target

reinsert = (arr, from, to) ->
  return if from is to
  value = arr[from]
  arr.splice from, 1
  arr.splice to, 0, value

toEnglish = (value) ->
  value = '' + value
  '۰۱۲۳۴۵۶۷۸۹'.split ''
  .forEach (digit, i) ->
    value = value.replace (new RegExp digit, 'g'), i
  value.replace '/', '.'

toPersian = (value) ->
  value = '' + value
  '۰۱۲۳۴۵۶۷۸۹'.split ''
  .forEach (digit, i) ->
    value = value.replace (new RegExp '' + i, 'g'), digit
  value.replace(/ي/g, 'ی').replace /ك/g, 'ک'

addPageCSS = (url) ->
  cssNode = document.createElement 'link'
  cssNode.setAttribute 'rel', 'stylesheet'
  cssNode.setAttribute 'href', "/assets/#{url}"
  append document.head, cssNode

addPageStyle = (code) ->
  styleNode = document.createElement 'style'
  styleNode.type = 'text/css'
  styleNode.textContent = code
  append document.head, styleNode

bindEvent = (element, event, callback) ->
  element.addEventListener event, callback
  -> element.removeEventListener event, callback

append = ->
  if arguments.length is 1
    element = arguments[0]
    parent = document.body
  else if arguments.length is 2
    element = arguments[1]
    parent = arguments[0]
  if Array.isArray element
    element.forEach (element) ->
      append parent, element
  else
    if element
      parent.appendChild element

destroy = (element) -> element.parentNode.removeChild element

empty = (element) ->
  while element.children?.length
    destroy element.children[0]

pxToNum = (val) -> +val.substr 0, val.length - 2

setStyle = (element, style = {}) ->
  if Array.isArray element
    return element.forEach (element) -> setStyle element, style
  Object.keys(style).forEach (key) ->
    val = style[key]
    if key is 'text'
      if isFirefox
        element.innerHTML = val
      else
        element.innerText = val
    else if key is 'value'
      element.value = val
      element.dispatchEvent new Event 'input'
    else if key in ['class', 'type', 'placeholder', 'id', 'for']
      element.setAttribute key, val
    else
      if (typeof val is 'number') and not (key in ['opacity', 'zIndex'])
        val = Math.floor(val) + 'px' 
      element.style[key] = val
  return element

addClass = (element, klass) ->
  element.setAttribute 'class', ((element.getAttribute('class') ? '') + ' ' + klass).replace(/\ +/g, ' ').trim()
  return element

removeClass = (element, klass) ->
  previousClass = (element.getAttribute 'class') ? ''
  classIndex = previousClass.indexOf klass
  if ~classIndex
    element.setAttribute 'class', ((previousClass.substr 0, classIndex) + (previousClass.substr classIndex + klass.length)).replace(/\ +/g, ' ').trim()
  return element

show = (element) ->
  if Array.isArray element
    return element.map (element) -> show element
  removeClass element, 'hidden'
  return element

hide = (element) ->
  if Array.isArray element
    return element.map (element) -> hide element
  removeClass element, 'hidden'
  addClass element, 'hidden'
  return element

enable = (element) ->
  if Array.isArray element
    return element.map (element) -> enable element
  element.removeAttribute 'disabled'
  return element

disable = (element) ->
  if Array.isArray element
    return element.map (element) -> disable element
  element.setAttribute 'disabled', 'disabled'
  return element

E = do ->
  e = (tagName, style, children...) ->
    element = document.createElement tagName
    setStyle element, style
    do appendChildren = (children) ->
      children.forEach (x) ->
        if (typeof x is 'string') or (typeof x is 'number')
          setStyle element, text: x
        else if Array.isArray x
          appendChildren x
        else
          append element, x
    element

  ->
    firstArg = arguments[0]
    if typeof firstArg is 'string'
      e.apply null, arguments
    else if typeof firstArg is 'object' and not Array.isArray firstArg
      args = [].slice.call arguments
      args.splice 0, 0, 'div'
      e.apply null, args
    else
      args = [].slice.call arguments
      args.splice 0, 0, 'div', {}
      e.apply null, args

events = do ->
  isIn = (element, {pageX, pageY}) ->
    rect = element.getBoundingClientRect()
    minX = rect.left
    maxX = rect.left + rect.width
    minY = rect.top + window.scrollY
    maxY = rect.top + window.scrollY + rect.height
    minX < pageX < maxX and minY < pageY < maxY

  load: (callback) ->
    bindEvent window, 'load', callback

  resize: (callback) ->
    bindEvent window, 'resize', callback

  mouseover: (element, callback) ->
    allreadyIn = false
    bindEvent document.body, 'mousemove', (e) ->
      if isIn element, e
        callback e unless allreadyIn
        allreadyIn = true
      else
        allreadyIn = false

  mouseout: (element, callback) ->
    allreadyOut = false
    bindEvent document.body, 'mousemove', (e) ->
      unless isIn element, e
        callback e unless allreadyOut
        allreadyOut = true
      else
        allreadyOut = false
    bindEvent document.body, 'mouseout', (e) ->
      from = e.relatedTarget || e.toElement
      if !from || from.nodeName == "HTML"
        callback e

  mouseup: (callback) ->
    bindEvent document.body, 'mouseup', callback
    bindEvent document.body, 'mouseout', (e) ->
      from = e.relatedTarget || e.toElement
      if !from || from.nodeName == "HTML"
        callback e

animation = (rawCallback, wrapCallback) ->
  
  lastX = null
  callback = (x) ->
    unless lastX is x
      lastX = x
      rawCallback x, (start, end) -> start + (end - start) * x

  x = 0
  running = false
  xStart = null
  xDest = null
  startTime = null
  totalTime = null

  callback x
  
  animate = ->
    passedTime = performance.now() - startTime
    x = xStart + (xDest - xStart) * passedTime / totalTime

    if passedTime >= totalTime
      running = false
      callback xDest
    else
      callback x
      requestAnimationFrame animate

  (start, dest, time) ->
    xStart = x
    xDest = dest
    startTime = performance.now()
    totalTime = time * (xDest - xStart) / (dest - start)
    unless running or totalTime is 0
      running = true
      requestAnimationFrame animate

timeStep = 1 / 60
spring = ([k, m], rawCallback) ->
  
  lastX = null
  callback = (x) ->
    unless lastX is x
      lastX = x
      rawCallback x, running, (start, end) -> start + (end - start) * x
    
  x = xRest = 0
  v = 0
  running = false
  lastTime = null

  callback xRest

  animate = ->
    now = performance.now()
    deltaTime = now - lastTime
    stepsCount = Math.floor (deltaTime / 1000 / timeStep)
    lastTime = now
    for i in [0..stepsCount]
      a = -k * (x - xRest) - m * v
      v += a * timeStep
      x += v * timeStep
    remainingTime = ((deltaTime / 1000) - (stepsCount * timeStep))
    a = -k * (x - xRest) - m * v
    v += a * remainingTime
    x += v * remainingTime
    if Math.abs(a) <= 0.1
      running = false
      callback xRest
    else
      callback x
      requestAnimationFrame animate

  (arg, arg2) ->
    if typeof arg is 'function'
      rawCallback = arg
    else if typeof arg is 'object'
      [k, m] = arg
    else if arg2 is 'stretch'
      x = arg
      v = 0
      callback x
    else if arg2 is 'goto'
      x = xRest = arg
      v = 0
      running = false
      callback x
    else
      xRest = arg
      unless running
        running = true
        lastTime = performance.now()
        requestAnimationFrame animate

numberInput = (style) ->
  input = E 'input', style
  prevValue = ''
  handler = ->
    value = input.value
    if /^[0-9]*$/.test toEnglish value
      prevValue = value
    else
      value = prevValue
    input.value = toPersian value
  bindEvent input, 'input', handler
  return input

collection = (add, destroy, change) ->
  data = []
  (newData) ->
    if newData.length > data.length
      if data.length
        [0 .. data.length - 1].forEach (i) ->
          data[i] = change newData[i], data[i]
      [data.length .. newData.length - 1].forEach (i) ->
        data[i] = add newData[i]
    else if data.length > newData.length
      if newData.length
        [0 .. newData.length - 1].forEach (i) ->
          data[i] = change newData[i], data[i]
      while data.length > newData.length
        destroy data[data.length - 1]
        data.splice (data.length - 1), 1
    else if data.length
      [0 .. data.length - 1].forEach (i) ->
        data[i] = change newData[i], data[i]


emailIsValid = (email) -> /^.+@.+\..+$/.test email

passwordIsValid = (password) -> password.length >= 6

module.exports = {
  isOpera
  isFirefox
  isSafari
  isChrome
  isIE
  isEdge
  createCookie
  readCookie
  eraseCookie
  generateId
  without
  extend
  reinsert
  toEnglish
  toPersian
  addPageCSS
  addPageStyle
  bindEvent
  pxToNum
  E
  setStyle
  addClass
  removeClass
  show
  hide
  enable
  disable
  append
  destroy
  empty
  events
  animation
  spring
  numberInput
  collection
  emailIsValid
  passwordIsValid
}
