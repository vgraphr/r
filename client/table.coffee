{extend, reinsert, E, append, destroy, events, bindEvent, setStyle, spring, animation} = require './utils'

tableStyle =
  display: 'block'
  width: '100%'

cellStyle =
  background: 'white'
  display: 'inline-block'
  height: 40
  fontSize: 11

headerStyle = extend {}, cellStyle,
  borderTop: '1px solid #DDD'
  borderBottom: '1px solid #DDD'
  borderLeft: '1px dashed #EEE'
  borderRight: '1px dashed #EEE'
  fontSize: 20
  position: 'absolute'
  color: '#888'
  left: 0
  right: 0

headers = []

table = E tableStyle

sombodeyIsBeingDragged = false

leftX = 0
setTimeout -> leftX = table.getBoundingClientRect().left

tableWidth = 100

addHeader = (headerOrHeaders, isBatch) ->

  if Array.isArray headerOrHeaders
    return unless headerOrHeaders.length
    headerOrHeaders[0].width = tableWidth - headerOrHeaders.slice(1).reduce ((totalWidth, {width}) -> totalWidth + width - 1), 0
    headerOrHeaders.forEach (header) -> addHeader header, true
    return

  isNew = not isBatch
  header = headerOrHeaders

  if isNew
    totalWidth = 0
    headers.forEach (header) ->
      header.resize? header.width * 0.9
      totalWidth += header.width - 1
      header.putInPlace?()
    header.width = tableWidth - totalWidth + 1

  header.index = headers.length

  headers.push header

  element = E position: 'absolute', height: 200, background: 'white'

  headerElement = E headerStyle,
    span = E position: 'absolute', left: 30, right: 10, lineHeight: 40, overflow: 'hidden', color: '#888', transition: '0.15s', header.name
    bottomBorder = E position: 'absolute', bottom: -1, left: 0, right: 0, background: '#5BC0DE', transition: '0.15s'
    up = E position: 'absolute', top: 10, left: 10, fontSize: 11, cursor: 'pointer'
    down = E position: 'absolute', bottom: 10, left: 10, fontSize: 11, cursor: 'pointer'
  up.setAttribute 'class', 'fa fa-caret-up'
  down.setAttribute 'class', 'fa fa-caret-down'

  bindEvent headerElement, 'mousemove', (e) ->
    layerX = e.pageX - headerElement.getBoundingClientRect().left
    unless layerX < 5 or layerX > header.width - 5 or sombodeyIsBeingDragged
      setStyle span, color: '#5BC0DE'    
      setStyle bottomBorder, height: 2
    else
      setStyle span, color: '#888'
      setStyle bottomBorder, height: 0
  events.mouseout headerElement, ->
    setStyle span, color: '#888'
    setStyle bottomBorder, height: 0

  append element, headerElement

  getPlace = -> headers.slice(0, header.index).reduce ((left, {width}) -> left + width - 1), 0

  x = null
  xSpring = spring [300, 50], (a) ->
    x = a
    setStyle element, left: x
  downSpring = spring [300, 50], (a) ->
    shadow = a * 16
    scale = 1 + a * 0.1
    setStyle element,
      boxShadow: "rgba(0, 0, 0, 0.2) 0px #{shadow}px #{2 * shadow}px 0px"
      transform: "scale(#{scale})"
      WebkitTransform: "scale(#{scale})"
  widthSpring = spring [300, 50], (width) ->
    setStyle element, {width}

  place = getPlace()
  if isNew
    widthSpring header.width
    xSpring (place + header.width), 'goto'
    xSpring place
  else
    widthSpring header.width, 'goto'
    xSpring place, 'goto'

  header.fixZIndex = ->
    setStyle element, zIndex: 1
  header.putInPlace = (immediate) ->
    xSpring getPlace(), if immediate then 'goto'
  header.resize = (newWidth, immediate) ->
    widthSpring newWidth, if immediate then 'goto'
    header.width = newWidth
  header.destroy = ->
    destroy element

  down = null
  bindEvent headerElement, 'mousedown', ({pageX}) ->
    sombodeyIsBeingDragged = true
    setStyle element, zIndex: 1000
    headers.forEach (h) ->
      if h isnt header
        h.fixZIndex?()
    down = delta: pageX - x, pressX: x
    downSpring 1

  lastVictim = null
  events.mousemove ({pageX}) ->
    if down
      xSpring pageX - down.delta, 'goto'
      place = 0
      mouse = pageX - leftX
      headers.reduce ((start, {width}, i) ->
        end = start + width
        if start <= mouse < end
          place = i
        return end
      ), 0
      if mouse >= tableWidth
        place = headers.length - 1
      victim = headers[place]
      return if victim is lastVictim
      lastVictim = victim
      reinsert headers, header.index, place
      headers.forEach (h, index) ->
        h.index = index
        if h isnt header
          h.putInPlace?()
  events.mouseup(true) ->
    sombodeyIsBeingDragged = false
    down = null
    downSpring 0
    header.putInPlace()

  bindEvent element, 'mousemove', (e) ->
    if e.layerX < 5 or e.layerX > header.width - 5
      setStyle element, cursor: 'e-resize'
      setStyle headerElement, cursor: 'e-resize'
    else
      setStyle element, cursor: 'default'
      setStyle headerElement, cursor: 'move'

  append table, element

removeHeader = (index) ->
  header = headers[index]
  partialWidth = tableWidth - header.width
  totalWidth = 0
  header.destroy?()
  headers.splice index, 1
  headers.forEach (header, i) ->
    if header.index > index
      header.index--
    header.resize? if i < headers.length - 1 then header.width * tableWidth / partialWidth else tableWidth - totalWidth + 1
    totalWidth += header.width - 1
    header.putInPlace?()

resizeTable = (newWidth) ->
  return unless headers.length
  totalWidth = 0
  headers.slice(0, headers.length - 1).forEach (header) ->
    header.resize? (header.width * newWidth / tableWidth), true
    totalWidth += header.width - 1
    header.putInPlace? true
  tableWidth = newWidth
  headers[headers.length - 1].resize? (tableWidth - totalWidth), true
  headers[headers.length - 1].putInPlace? true

module.exports = {
  element: table
  addHeader
  removeHeader
  resizeTable
}
