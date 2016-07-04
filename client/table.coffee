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
  columnDataItemStyle
  columnChangeStyle
  columnChangeListStyle
  columnChangeBackStyle
  columnDeleteStyle
  columnListItemStyle
  columnSearchStyle
  columnSearchboxStyle
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
  headerDescriptors = undefined

  # table events
  events.mouseup ->
    mouseIsDown = false

  addColumn = (headerOOrHeaderOs, isBatch) ->
    # handle Array
    if Array.isArray headerOOrHeaderOs
      widthSum = headerOOrHeaderOs.reduce ((totalWidth, {width}) -> totalWidth + width - 1), 0
      headerOOrHeaderOs.forEach (headerO, i) ->
        if i is headerOOrHeaderOs.length - 1
          headerO.width = 0
          headerO.width = Math.floor tableWidth - headerOOrHeaderOs.reduce ((totalWidth, {width}) -> Math.floor totalWidth + width), 0
        else
          headerO.width = Math.floor (headerO.width * tableWidth / widthSum) - 1
      return headerOOrHeaderOs.map (headerO) ->
        addColumn headerO, true

    # column properties
    isNew = not isBatch
    headerO = headerOOrHeaderOs
    changeCallback = deleteCallback = searchCallback = sortCallback = undefined

    # column element
    append table, columnE = E columnStyle,
      borderE = E borderStyle,
        headerE = E headerStyle,
          spanE = E headerSpanStyle, headerO.descriptor.title
          bottomBorderE = E headerBottomBorderStyle
          upE = E headerUpButtonStyle
          downE = E headerDownButtonStyle
        changeE = E columnChangeStyle
        changeListE = E columnChangeListStyle,
          changeListItems = headerDescriptors.map ({title}) ->
            E columnListItemStyle, title
          deleteE = E columnDeleteStyle, 'حذف ستون'
        searchE = E columnSearchStyle,
          searchboxE = E 'input', columnSearchboxStyle
        dataE = E columnDataStyle

    # column state
    listIsOpen = false
    dragDown = null
    place = 0 #, headerO.width
    isDrifting = false
    borderHighlighted = false
    dataItemEs = []
    sortDirection = null
    # column animations
    placeSpring = spring [300, 50], (x, running) ->
      place = Math.floor x
      setStyle columnE, left: x
      isDrifting = running
    widthSpring = spring [300, 50], (width) -> # maybe these two
      setStyle columnE, {width}                # need to be checked
    downSpring = spring [300, 50], (x) ->      # if running to set isDrifting
      shadow = x * 16
      scaleX = 1 + x * 0.1
      scaleY = 1 + x * 1 / dataItemEs.length
      setStyle columnE,
        boxShadow: "rgba(0, 0, 0, 0.2) 0px #{shadow}px #{2 * shadow}px 0px"
        transform: "scaleX(#{scaleX}) scaleY(#{scaleY})"
        WebkitTransform: "scaleX(#{scaleX}) scaleY(#{scaleY})"

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
    openChangeList = ->
      headerOs.forEach (headerO) ->
        headerO.closeChangeList()
      setStyle changeE, columnChangeBackStyle
      setStyle changeListE, opacity: 1, visibility: 'visible'
      listIsOpen = true

    # column initialization
    if isNew
      totalWidth = 0
      headerOs.forEach (headerO) ->
        headerO.resize? headerO.width * 0.9
        totalWidth += headerO.width - 1
        headerO.putInPlace?()
      headerO.width = Math.floor tableWidth - totalWidth
      openChangeList()

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
    headerO.closeChangeList = ->
      setStyle changeE, extend {}, columnChangeStyle, height: 15, lineHeight: 15, opacity: 1
      setStyle changeListE, columnChangeListStyle
      listIsOpen = false
    headerO.unsort = ->
      sortDirection = null

    # column events
    bindEvent searchboxE, 'input', ->
      searchCallback? searchboxE.value

    bindEvent headerE, 'click', ({pageX, pageY}) ->
      layerX = pageX - headerE.getBoundingClientRect().left
      layerY = pageY - headerE.getBoundingClientRect().top
      if 10 <= layerX <= 15
        if 13 <= layerY <= 19
          if sortDirection is 'up'
            sortDirection = null
          else
            sortDirection = 'up'
        else if 20 <= layerY <= 26
          if sortDirection is 'down'
            sortDirection = null
          else
            sortDirection = 'down'

        if 13 <= layerY <= 26
          headerOs.forEach (ho, index) ->
            if ho isnt headerO
              ho.unsort?()
          sortCallback?()

    bindEvent columnE, 'mousedown', ->
      setStyle columnE, zIndex: 1000
      headerOs.forEach (ho) ->
        if ho isnt headerO
          ho.fixZIndex?()

    bindEvent changeE, 'click', ->
      if listIsOpen
        headerO.closeChangeList()
      else
        openChangeList()

    bindEvent changeE, 'mousemove', ->
      unless listIsOpen
        setStyle changeE, background: '#5BC0DE'
    bindEvent changeE, 'mouseout', ->
      unless listIsOpen
        setStyle changeE, extend {}, columnChangeStyle, height: 15, lineHeight: 15, opacity: 1

    changeListItems.forEach (item, i) ->
      headerDescriptor = headerDescriptors[i]
      bindEvent item, 'click', ->
        setStyle spanE, text: headerDescriptor.title
        headerO.descriptor = headerDescriptor
        headerO.closeChangeList()
        changeCallback?()

    bindEvent deleteE, 'click', ->
      deleteColumn headerO.index
      deleteCallback?()

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

    bindEvent headerE, 'mousedown', ({pageX, pageY}) ->
      layerX = pageX - headerE.getBoundingClientRect().left
      layerY = pageY - headerE.getBoundingClientRect().top
      return if (10 <= layerX <= 15) and (13 <= layerY <= 26)

      unless cursorSide pageX
        setStyle document.body, cursor: 'move'
        setStyle columnE, cursor: 'move'
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

    returnObject =
      getHeaderDescriptor: -> headerO.descriptor
      onChanged: (callback) -> changeCallback = callback
      onDelete: (callback) -> deleteCallback = callback
      onSearch: (callback) -> searchCallback = callback
      onSort: (callback) -> sortCallback = callback
      getSearchValue: -> searchboxE.value
      getSortDirection: -> sortDirection
      empty: -> empty dataE
      setHeight: (height) ->
        setStyle columnE, {height}
      addData: (data) ->
        dataItemE = E columnDataItemStyle, String data
        append dataE, dataItemE
        dataItemEs.push dataItemE
        return dataItemE
      getDataItems: -> dataItemEs
      removeDataItem: (dataItem) ->
        dataItemEs.splice dataItemEs.indexOf(dataItem), 1
        destroy dataItem
      changeMode: ->
        setStyle changeE, height: 15, lineHeight: 15, opacity: 1
        setStyle dataE, marginTop: 15
      searchMode: ->
        setStyle searchE, height: 30, lineHeight: 30, opacity: 1
        setStyle dataE, marginTop: 30
      defaultMode: ->
        listIsOpen = false
        setStyle changeE, columnChangeStyle
        setStyle changeListE, columnChangeListStyle
        setStyle searchE, columnSearchStyle
        setStyle dataE, columnDataStyle

  deleteColumn = (index) ->
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

  setHeaderDescriptors = (descriptors) ->
    headerDescriptors = descriptors

  return {
    table
    setHeaderDescriptors
    addColumn
    deleteColumn
    resizeTable
  }


if module.dynamic
  unsubscribers = [
    tableStylePage.onChanged module.reload
  ]
  module.onUnload -> unsubscribers.forEach (unsubscribe) -> unsubscribe()
