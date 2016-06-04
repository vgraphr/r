{extend, reinsert, E, append, destroy, events, bindEvent, setStyle, spring, animation} = require './utils'

tableStyle =
  display: 'block'
  width: '100%'

columnStyle =
  position: 'absolute'
  height: 200
  background: 'white'

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

headerSpanStyle =
  position: 'absolute'
  left: 30
  right: 10
  lineHeight: 40
  overflow: 'hidden'
  color: '#888'
  transition: '0.15s'

headerBottomBorderStyle = 
  position: 'absolute'
  bottom: -1
  left: 0
  right: 0
  background: '#5BC0DE'
  transition: '0.15s'

headerUpButtonStyle =
  position: 'absolute'
  left: 10
  fontSize: 11
  cursor: 'pointer'
  top: 10
  class: 'fa fa-caret-up'

headerDownButtonStyle =
  position: 'absolute'
  left: 10
  fontSize: 11
  cursor: 'pointer'
  bottom: 10
  class: 'fa fa-caret-down'

module.exports = ->

  # table properties
  leftX = 0
  setTimeout -> leftX = table.getBoundingClientRect().left

  # table state
  tableWidth = 100
  headerOs = []
  sombodeyIsBeingDragged = false
  mouseIsDown = false
  lastVictim = null

  # table element
  table = E tableStyle

  addColumn = (headerOOrHeaderOs, isBatch) ->

    # handle Array
    if Array.isArray headerOOrHeaderOs
      return unless headerOOrHeaderOs.length
      headerOOrHeaderOs[0].width = tableWidth - headerOOrHeaderOs.slice(1).reduce ((totalWidth, {width}) ->
        totalWidth + width - 1), 0
      headerOOrHeaderOs.forEach (headerO) ->
        addColumn headerO, true
      return

    # column properties
    isNew = not isBatch
    headerO = headerOOrHeaderOs

    # column state
    down = null
    place = 0

    # column element
    append table, columnE = E columnStyle,
      headerE = E headerStyle,
        spanE = E headerSpanStyle, headerO.title
        bottomBorderE = E headerBottomBorderStyle
        upE = E headerUpButtonStyle
        downE = E headerDownButtonStyle

    # column helpers
    highlightHeader = ->
      setStyle spanE, color: '#5BC0DE'    
      setStyle bottomBorderE, height: 2
    unhighlightHeader = ->
      setStyle spanE, color: '#888'
      setStyle bottomBorderE, height: 0
    getPlace = ->
      headerOs.slice(0, headerO.index).reduce ((left, {width}) -> left + width - 1), 0
    mouseIsInDragLocation = (pageX) ->
      layerX = pageX - headerE.getBoundingClientRect().left
      layerX < 5 or layerX > headerO.width - 5

    # column animations
    xSpring = spring [300, 50], (x) ->
      place = x
      setStyle columnE, left: x
    widthSpring = spring [300, 50], (width) ->
      setStyle columnE, {width}
    downSpring = spring [300, 50], (x) ->
      shadow = x * 16
      scale = 1 + x * 0.1
      setStyle columnE,
        boxShadow: "rgba(0, 0, 0, 0.2) 0px #{shadow}px #{2 * shadow}px 0px"
        transform: "scale(#{scale})"
        WebkitTransform: "scale(#{scale})"

    # column initialization
    if isNew
      totalWidth = 0
      headerOs.forEach (headerO) ->
        headerO.resize? headerO.width * 0.9
        totalWidth += headerO.width - 1
        headerO.putInPlace?()
      headerO.width = tableWidth - totalWidth + 1

    headerO.index = headerOs.length

    headerOs.push headerO

    destination = getPlace()
    if isNew
      widthSpring headerO.width
      xSpring (destination + headerO.width), 'goto'
      xSpring destination
    else
      widthSpring headerO.width, 'goto'
      xSpring destination, 'goto'

    # column methods
    headerO.fixZIndex = ->
      setStyle columnE, zIndex: 1
    headerO.putInPlace = (immediate) ->
      xSpring getPlace(), if immediate then 'goto'
    headerO.resize = (newWidth, immediate) ->
      widthSpring newWidth, if immediate then 'goto'
      headerO.width = newWidth
    headerO.destroy = ->
      destroy columnE

    # column events
    bindEvent headerE, 'mousemove', ({pageX}) ->
      unless mouseIsDown or mouseIsInDragLocation pageX
        highlightHeader()
    events.mousemove ({pageX}) -> # NOTE: or mouse out     
      if mouseIsDown or mouseIsInDragLocation pageX
        unhighlightHeader()
    events.mouseout headerE, unhighlightHeader
    bindEvent document.body, 'mousedown', ->
      mouseIsDown = true
      unhighlightHeader()

    bindEvent columnE, 'mousemove', ({pageX}) ->
      if mouseIsInDragLocation pageX
        setStyle columnE, cursor: 'e-resize'
        setStyle headerE, cursor: 'e-resize'
      else
        setStyle headerE, cursor: 'move'
        unless down
          setStyle columnE, cursor: 'default'

    bindEvent headerE, 'mousedown', ({pageX}) ->
      sombodeyIsBeingDragged = true
      setStyle columnE, cursor: 'move', zIndex: 1000
      headerOs.forEach (ho) ->
        if ho isnt headerO
          ho.fixZIndex?()
      down = delta: pageX - place, pressX: place
      downSpring 1

    events.mousemove ({pageX}) ->
      if down
        xSpring pageX - down.delta, 'goto'
        place = 0
        mouse = pageX - leftX
        headerOs.reduce ((start, {width}, i) ->
          end = start + width
          if start <= mouse < end
            place = i
          return end
        ), 0
        if mouse >= tableWidth
          place = headerOs.length - 1
        victim = headerOs[place]
        return if victim is lastVictim
        lastVictim = victim
        reinsert headerOs, headerO.index, place
        headerOs.forEach (ho, index) ->
          ho.index = index
          if ho isnt headerO
            ho.putInPlace?()
    events.mouseup(true) ->
      sombodeyIsBeingDragged = false
      setStyle columnE, cursor: 'default'
      mouseIsDown = false
      down = null
      downSpring 0
      headerO.putInPlace()

  removeColumn = (index) ->
    headerO = headerOs[index]
    partialWidth = tableWidth - headerO.width
    totalWidth = 0
    headerO.destroy?()
    headerOs.splice index, 1
    headerOs.forEach (headerO, i) ->
      if headerO.index > index
        headerO.index--
      headerO.resize? if i < headerOs.length - 1 then headerO.width * tableWidth / partialWidth else tableWidth - totalWidth + 1
      totalWidth += headerO.width - 1
      headerO.putInPlace?()

  resizeTable = (newWidth) ->
    return unless headerOs.length
    totalWidth = 0
    headerOs.slice(0, headerOs.length - 1).forEach (headerO) ->
      headerO.resize? (headerO.width * newWidth / tableWidth), true
      totalWidth += headerO.width - 1
      headerO.putInPlace? true
    tableWidth = newWidth
    headerOs[headerOs.length - 1].resize? (tableWidth - totalWidth), true
    headerOs[headerOs.length - 1].putInPlace? true

  return {
    table
    addColumn
    removeColumn
    resizeTable
  }
