{extend, E, append, mouseover, mouseout, mousemove, mouseup, bindEvent, setStyle, spring, animation} = require './utils'


headers = [1..10].map (x, i) ->
  name: x
  width: 155 + (i - 5) * 20
  values: [0..9].map (x) -> x * 10 + i + 1

addHeader = (header) ->
  prevTotalWidth = totalWidth = 0
  headers.forEach (header) ->
    prevTotalWidth += header.width
    newWidth = header.width * 0.9
    header.resize? newWidth
    header.width = newWidth
    totalWidth += header.width
    header.putInPlace?()
  header.width = prevTotalWidth - totalWidth
  headers.push header
  header.new = true
  append table, initializeHeader header, headers.length - 1

setTimeout (->
  addHeader
    name: 'new'
    values: [0..9].map (x) -> "$#{x}"
), 1000

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
  color: '#888'
  fontSize: 20
  transition: 'border 0.15s'
  position: 'absolute'

reinsert = (arr, from, to) ->
  return if from is to
  value = arr[from]
  arr.splice from, 1
  arr.splice to, 0, value

leftX = null
totalWidth = null

headerElements = headers.map initializeHeader = (header, i) ->
  header.index = i

  totalWidth += header.width

  style = extend {}, headerStyle
  if i is headers.length - 1
    extend style, borderLeft: '0'
  element = E style, header.name

  if i is 0
    setTimeout ->
      leftX = element.getBoundingClientRect().left

  mouseover element, (e) ->
    setStyle element, color: '#5BC0DE', borderBottom: '2px solid #5BC0DE'
  mouseout element, (e) ->
    setStyle element, color: '#888', borderBottom: '1px solid #DDD'

  getPlace = ->
    headers.slice(0, header.index).reduce ((left, {width}) -> left + width), 0

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

  place = getPlace()
  if header.new
    animation(((interpolate) ->
      width = interpolate 0, header.width
      setStyle element, {width}
      xSpring (place + header.width - width), 'goto'
    ), true) 0, 1, 150
  else
    setStyle element, width: header.width
    xSpring place, 'goto'

  header.fixZIndex = ->
    setStyle element, zIndex: 1
  header.putInPlace = ->
    xSpring getPlace()
  header.resize = (newWidth) ->
    animation(((interpolate) -> setStyle element, width: interpolate header.width, newWidth), true) 0, 1, 150

  down = null
  bindEvent element, 'mousedown', ({pageX}) ->
    setStyle element, zIndex: 1000
    headers.forEach (h) ->
      if h isnt header
        h.fixZIndex?()
    down = delta: pageX - x, pressX: x
    downSpring 1

  lastVictim = null
  mousemove ({pageX}) ->
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
      headers.forEach (h, i) ->
        h.index = i
        if h isnt header
          h.putInPlace?()
  mouseup (->
    down = null
    downSpring 0
    header.putInPlace()
  ), true

  element

table = E tableStyle, [headerElements]
module.exports = table

