{reinsert, E, append, destroy, events, bindEvent, setStyle, spring, animation, extend, empty} = require './utils'
tableStylePage = require './tableStyle'
{
  tableStyle
  columnStyle
  borderStyle
  cellStyle
  headerStyle
  headerSpanStyle
  headerBottomBorderStyle
  headerUpButtonStyle
  headerDownButtonStyle
  headerHoverSpanStyle
  headerHoverBottomBorderStyle
  borderHoverColor
  columnDataStyle
  columnChangeStyle
  columnChangeListStyle
  columnChangeBackStyle
  columnDeleteStyle
  columnListItemStyle
} = tableStylePage 

module.exports = ->
  # table element
  table = E tableStyle

  # table properties
  leftX = 0
  setTimeout -> leftX = table.getBoundingClientRect().left

  # table state
  mouseIsDown = false
  tableWidth = 100
  headerOs = []
  lastVictim = null
  resizeDown = null

  # table events
  events.mouseup ->
    mouseIsDown = false

  addColumn = (headerOOrHeaderOs, isBatch) ->
    # handle Array
    if Array.isArray headerOOrHeaderOs
      return unless headerOOrHeaderOs.length
      headerOOrHeaderOs[0].width = Math.floor tableWidth - headerOOrHeaderOs.slice(1).reduce ((totalWidth, {width}) -> totalWidth + width - 1), 0
      return headerOOrHeaderOs.map (headerO) ->
        addColumn headerO, true

    # column properties
    isNew = not isBatch
    headerO = headerOOrHeaderOs

    # column element
    append table, columnE = E columnStyle,
      borderE = E borderStyle,
        headerE = E headerStyle,
          spanE = E headerSpanStyle, headerO.title
          bottomBorderE = E headerBottomBorderStyle
          upE = E headerUpButtonStyle
          downE = E headerDownButtonStyle
        changeE = E columnChangeStyle
        changeListE = E columnChangeListStyle,
          deleteE = E columnDeleteStyle, 'حذف ستون'
        dataE = E columnDataStyle

    # column state
    listItems = []
    listIsOpen = false
    dragDown = null
    place = 0 #, headerO.width
    isDrifting = false
    borderHighlighted = false
    # column animations
    placeSpring = spring [300, 50], (x, running) ->
      place = Math.floor x
      setStyle columnE, left: x
      isDrifting = running
    widthSpring = spring [300, 50], (width) -> # maybe these two
      setStyle columnE, {width}                # need to be checked
    downSpring = spring [300, 50], (x) ->      # if running to set isDrifting
      shadow = x * 16
      scale = 1 + x * 0.1
      setStyle columnE,
        boxShadow: "rgba(0, 0, 0, 0.2) 0px #{shadow}px #{2 * shadow}px 0px"
        transform: "scale(#{scale})"
        WebkitTransform: "scale(#{scale})"

    # column helpers
    highlightHeader = ->
      setStyle spanE, headerHoverSpanStyle
      setStyle bottomBorderE, headerHoverBottomBorderStyle
    unhighlightHeader = ->
      setStyle spanE, headerSpanStyle
      setStyle bottomBorderE, headerBottomBorderStyle
    getPlace = ->
      headerOs.slice(0, headerO.index).reduce ((left, {width}) -> left + width - 1), 0
    cursorSide = (pageX) ->
      layerX = pageX - headerE.getBoundingClientRect().left
      if layerX < 5
        return 1
      else if layerX > headerO.width - 5
        return 2
      return 0

    # column initialization
    if isNew
      totalWidth = 0
      headerOs.forEach (headerO) ->
        headerO.resize? headerO.width * 0.9
        totalWidth += headerO.width - 1
        headerO.putInPlace?()
      headerO.width = Math.floor tableWidth - totalWidth

    headerO.index = headerOs.length

    headerOs.push headerO

    destination = getPlace()
    if isNew
      widthSpring headerO.width
      placeSpring (destination + headerO.width), 'goto'
      placeSpring destination
    else
      widthSpring headerO.width, 'goto'
      placeSpring destination, 'goto'

    # column methods
    headerO.fixZIndex = ->
      setStyle columnE, zIndex: 1
    headerO.putInPlace = (immediate) ->
      placeSpring getPlace(), if immediate then 'goto'
    headerO.resize = (newWidth, immediate) ->
      widthSpring newWidth, if immediate then 'goto'
      headerO.width = Math.floor newWidth
    headerO.destroy = ->
      destroy columnE
    headerO.highlightResizeBorder = (side) ->
      setTimeout ->
        borderHighlighted = true
      switch side
        when 1
          setStyle borderE, borderLeft: borderHoverColor
        when 2
          setStyle borderE, borderRight: borderHoverColor

    # column events
    bindEvent changeE, 'click', ->
      if listIsOpen
        setStyle changeE, extend {}, columnChangeStyle, height: 10, lineHeight: 10
        setStyle changeListE, columnChangeListStyle
      else
        setStyle changeE, columnChangeBackStyle
        setStyle changeListE, opacity: 1, visibility: 'visible'
      listIsOpen = not listIsOpen

    bindEvent deleteE, 'click', ->
      removeColumn headerO.index

    bindEvent headerE, 'mousemove', ({pageX}) ->
      unless mouseIsDown or cursorSide pageX
        highlightHeader()

    events.mouseout headerE, unhighlightHeader

    bindEvent document.body, 'mousedown', ->
      mouseIsDown = true
      unhighlightHeader()

    bindEvent columnE, 'mousemove', ({pageX}) ->
      return if resizeDown
      if side = cursorSide pageX
        unless (side is 1 and headerO.index is 0) or (side is 2 and headerO.index is headerOs.length - 1) 
          setStyle columnE, cursor: 'e-resize'
          setStyle headerE, cursor: 'e-resize'
          switch side
            when 1
              headerO.highlightResizeBorder 1
              headerOs[headerO.index - 1].highlightResizeBorder 2
            when 2
              headerO.highlightResizeBorder 2
              headerOs[headerO.index + 1].highlightResizeBorder 1
      else
        unless resizeDown
          setStyle headerE, cursor: 'move'
        unless dragDown or resizeDown
          setStyle columnE, cursor: 'default'

    bindEvent headerE, 'mousedown', ({pageX}) ->
      unless cursorSide pageX
        setStyle document.body, cursor: 'move'
        setStyle columnE, cursor: 'move', zIndex: 1000
        headerOs.forEach (ho) ->
          if ho isnt headerO
            ho.fixZIndex?()
        dragDown = headerO: headerO, delta: pageX - place
        downSpring 1

    bindEvent columnE, 'mousedown', ({pageX}) ->
      if not isDrifting and side = cursorSide pageX
        setStyle document.body, cursor: 'e-resize'
        switch side
          when 1
            return if headerO.index is 0
            leftWidth = headerOs[headerO.index - 1]?.width
            rightWidth = headerO.width
          when 2
            return if headerO.index is headerOs.length - 1
            leftWidth = headerO.width
            rightWidth = headerOs[headerO.index + 1]?.width
        resizeDown = {headerO, pageX, side, leftWidth, rightWidth}

    bindEvent document.body, 'mousemove', ({pageX}) ->
      if mouseIsDown or cursorSide pageX
        unhighlightHeader()

      borderHighlighted = false
      setTimeout ->
        unless borderHighlighted or (resizeDown and ((resizeDown.side is 1 and (resizeDown.headerO.index is headerO.index)) or (resizeDown.side is 2 and (resizeDown.headerO.index is headerO.index - 1))))
          setStyle borderE, borderStyle

      if dragDown
        placeSpring pageX - dragDown.delta, 'goto'
        destinationIndex = 0
        mouse = pageX - leftX
        headerOs.reduce ((start, {width}, index) ->
          end = start + width
          if start <= mouse < end
            destinationIndex = index
          return end
        ), 0
        if mouse >= tableWidth
          destinationIndex = headerOs.length - 1
        victim = headerOs[destinationIndex]
        return if victim is lastVictim
        lastVictim = victim
        return if headerO.index is destinationIndex
        reinsert headerOs, headerO.index, destinationIndex
        headerOs.forEach (ho, index) ->
          ho.index = index
          if ho isnt headerO
            ho.putInPlace?()

      else if resizeDown?.headerO is headerO
        minimumColumnWidth = 60
        switch resizeDown.side
          when 1
            return if headerO.index is 0
            leftHeaderO = headerOs[headerO.index - 1]
            rightHeaderO = headerO
          when 2
            return if headerO.index is headerOs.index - 1
            leftHeaderO = headerO
            rightHeaderO = headerOs[headerO.index + 1]
        newLeftWidth = resizeDown.leftWidth + (pageX - resizeDown.pageX)
        newRightWidth = resizeDown.rightWidth - (pageX - resizeDown.pageX)
        if newLeftWidth < minimumColumnWidth
          newLeftWidth = minimumColumnWidth
          newRightWidth = resizeDown.leftWidth + resizeDown.rightWidth - minimumColumnWidth
        else if newRightWidth < minimumColumnWidth
          newRightWidth = minimumColumnWidth
          newLeftWidth = resizeDown.leftWidth + resizeDown.rightWidth - minimumColumnWidth
        leftHeaderO.resize newLeftWidth, true
        rightHeaderO.resize newRightWidth, true
        rightHeaderO.putInPlace true

    events.mouseup ->
      setStyle document.body, cursor: 'default'
      if dragDown?.headerO is headerO
        # headerO.fixZIndex()
        setStyle columnE, cursor: 'default'
        dragDown = null
        downSpring 0
        headerO.putInPlace()
      if resizeDown?.headerO is headerO
        resizeDown = null

    addData: (data) ->
      if typeof data is 'string'
        dataRowE = E null, data
      else
        dataRowE = data
      append dataE, dataRowE
      return dataRowE
    setListItems: (items) ->
      listItems = items
      empty changeListE
      append changeListE, items.map (item) ->
        E columnListItemStyle, item
      append changeListE, deleteE
    changeMode: ->
      setStyle changeE, height: 10, lineHeight: 10
    defaultMode: ->
      listIsOpen = false
      setStyle changeE, columnChangeStyle
      setStyle changeListE, columnChangeListStyle

  removeColumn = (index) ->
    headerO = headerOs[index]
    partialWidth = tableWidth - headerO.width
    totalWidth = 0
    headerO.destroy?()
    headerOs.splice index, 1
    headerOs.forEach (headerO, i) ->
      if headerO.index > index
        headerO.index--
      headerO.resize? if i < headerOs.length - 1 then headerO.width * tableWidth / partialWidth else tableWidth - totalWidth
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
    lastHeaderO = headerOs[headerOs.length - 1]
    lastHeaderO.resize? (tableWidth - totalWidth), true
    lastHeaderO.putInPlace? true

  return {
    table
    addColumn
    removeColumn
    resizeTable
  }


if module.dynamic
  unsubscribers = [
    tableStylePage.onChanged module.reload
  ]
  module.onUnload -> unsubscribers.forEach (unsubscribe) -> unsubscribe()
