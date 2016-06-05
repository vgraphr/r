generateId = do ->
  i = 0
  -> i++

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
    parent.appendChild element

destroy = (element) -> element.parentNode.removeChild element

pxToNum = (val) -> +val.substr 0, val.length - 2

setStyle = (element, style = {}) ->
  Object.keys(style).forEach (key) ->
    val = style[key]
    if key is 'text'
      element.innerText = val
    else if key in ['class', 'type', 'value', 'placeholder']
      element.setAttribute key, val
    else
      if (typeof val is 'number') and not (key in ['opacity', 'zIndex'])
        val = Math.floor(val) + 'px' 
      element.style[key] = val

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

module.exports = {
  generateId
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
  append
  destroy
  events
  animation
  spring
}
