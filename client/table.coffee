{extend, reinsert, E, append, destroy, events, bindEvent, setStyle, spring, animation} = require './utils'

tableStyle =
  display: 'block'
  width: '100%'

cellStyle =
  background: 'white'
  cursor: 'default'
  display: 'inline-block'
  height: 40
  lineHeight: 40
  paddingRight: 10
  fontSize: 11

headerStyle = extend {}, cellStyle,
  borderTop: '1px solid #DDD'
  borderBottom: '1px solid #DDD'
  borderLeft: '1px dashed #EEE'
  borderRight: '1px dashed #EEE'
  color: '#888'
  fontSize: 20
  transition: 'border 0.25s'
  position: 'absolute'
  overflow: 'hidden'

table = E tableStyle

createHeaderElement = (name) ->
  element = E headerStyle, name
  bindEvent element, 'mousemove', -> setStyle element, color: '#5BC0DE', borderBottom: '2px solid #5BC0DE'
  events.mouseout element, -> setStyle element, color: '#888', borderBottom: '1px solid #DDD'
  element

headers = []

leftX = 0
setTimeout -> leftX = table.getBoundingClientRect().left

totalWidth = 0

addHeader = (header) ->

  isNew = !header.width?

  if isNew
    prevTotalWidth = totalWidth
    totalWidth = 0
    headers.forEach (header) ->
      header.resize? header.width * 0.9
      totalWidth += header.width
      header.putInPlace?()
    header.width = prevTotalWidth - totalWidth

  header.index = headers.length

  headers.push header

  totalWidth += header.width

  element = createHeaderElement header.name

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
    xSpring place + header.width, 'goto'
    xSpring place
  else
    widthSpring header.width, 'goto'
    xSpring place, 'goto'

  header.fixZIndex = ->
    setStyle element, zIndex: 1
  header.putInPlace = ->
    xSpring getPlace()
  header.resize = (newWidth) ->
    widthSpring newWidth
    header.width = newWidth
  header.destroy = ->
    destroy element

  down = null
  bindEvent element, 'mousedown', ({pageX}) ->
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
      if mouse >= totalWidth
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
    down = null
    downSpring 0
    header.putInPlace()

  append table, element

removeHeader = (index) ->
  header = headers[index]
  partialWidth = totalWidth - header.width
  temp = 0
  header.destroy?()
  headers.splice index, 1
  headers.forEach (header, i) ->
    if header.index > index
      header.index--
    header.resize? if i < headers.length - 1 then header.width * totalWidth / partialWidth else totalWidth - temp
    temp += header.width
    header.putInPlace?()

[1..10].forEach (x, i) ->
  addHeader
    name: x
    width: 160 + (i - 5) * 20

module.exports = {
  element: table
  addHeader
  removeHeader
}
