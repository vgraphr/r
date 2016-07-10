
module.exports = ({headerNames, itemData, onData, onRowClick, deleteItem, deleteText, searchBoxes = [], wrapperStyle = null}) ->
  Q = require '../q'
  {E, destroy, append, toPersian, bindEvent, setStyle, collection, show, hide, addClass, removeClass} = require '../utils'
  modal = require '../modal'

  view = E position: 'relative',
    noData = E wrapperStyle, 'در حال بارگزاری...'
    hide yesData = E wrapperStyle,
      E 'table', class: 'table table-striped table-bordered',
        E 'thead', null,
          E 'tr', null,
            headerNames.map (headerName, index) ->
              E 'th', position: 'relative', minWidth: 100, (
                if searchBoxes.length
                  [
                    E position: 'absolute', top: 5, headerName
                    searchBoxes[index]
                  ]
                else
                  headerName
              )
            if deleteItem
              E 'th', width: 45
        body = E 'tbody', null
    coverE = E position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, background: 'white', transition: '0.5s'

  cover = ->
    setStyle coverE, opacity: 0.5, visibility: 'visible'
  do uncover = ->
    setStyle coverE, opacity: 0, visibility: 'hidden'

  deleteHandler = (item) -> ->
    if deleteText
      modal.display
        contents: E 'p', null, deleteText
        submitText: 'حذف'
        submitType: 'danger'
        closeText: 'انصراف'
        enabled: true
        onSubmit: ->
          modal.hide()
          cover()
          Q deleteItem item
          .fin uncover
    else
      cover()
      Q deleteItem item
      .fin uncover

  addRow = (item) ->
    append body, element = E 'tr', null,
      itemData.map (key) ->
        if typeof key is 'string'
          E 'td', cursor: (if onRowClick then 'pointer' else 'default'), toPersian item[key] ? ''
        else if typeof key is 'function'
          key item, E 'td', cursor: (if onRowClick then 'pointer' else 'default')
      if deleteItem
        deleteE = E 'td', cursor: 'pointer', color: 'red', 'حذف'

    bindEvent element, 'mousemove', ->
      addClass element, 'info'
    bindEvent element, 'mouseout', ->
      removeClass element, 'info'

    if onRowClick
      unbindClick = bindEvent element, 'click', (e) ->
        target = e.target
        while target isnt document.body
          return if target is deleteE
          target = target.parentNode
        onRowClick item
    if deleteItem
      unbindDelete = bindEvent deleteE, 'click', deleteHandler item
    {element, deleteE, unbindClick, unbindDelete}

  removeRow = ({element}) ->
    destroy element

  changeRow = (item, {element, deleteE, unbindClick, unbindDelete}) ->
    itemData.map (key, index) ->
      if typeof key is 'string'
        setStyle element.children[index], text: toPersian item[key] ? ''
      else if typeof key is 'function'
        key item, element.children[index]
    if onRowClick
      unbindClick()
      unbindClick = bindEvent element, 'click', (e) ->
        target = e.target
        while target isnt document.body
          return if target is deleteE
          target = target.parentNode
        onRowClick item
    if deleteItem
      unbindDelete()
      unbindDelete = bindEvent deleteE, 'click', deleteHandler item
    {element, deleteE, unbindClick, unbindDelete}

  handleRows = collection addRow, removeRow, changeRow

  filterData = undefined
  update = ->
    if filterData
      hide noData
      show yesData
      filteredData = filterData searchBoxes.map (searchBox) -> searchBox.value
    else 
      filteredData = []
    handleRows filteredData

  onData (_filterData) ->
    filterData = _filterData
    update()

  searchBoxes.forEach (searchBox) ->
    bindEvent searchBox, 'input', update

  return view
