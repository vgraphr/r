
module.exports = (getId, getTitle, style) ->
  {E, bindEvent, empty, append, toPersian} = require '.'
  

  input = E 'select', style
  items = []
  showEmpty = false

  selectedId = null
  manuallySelected = false
  bindEvent input, 'input', ->
    selectedId = String input.value
    manuallySelected = true

  setIndex = ->
    if selectedId
      index = (items.map (item) -> String getId item).indexOf selectedId
      if ~index
        if showEmpty
          input.selectedIndex = index + 1
        else
          input.selectedIndex = index
      else
        input.selectedIndex = 0
    else
      input.selectedIndex = 0

  element: input
  reset: ->
    selectedId = null
    manuallySelected = false
    setIndex()
  setSelectedId: (x) ->
    unless manuallySelected
      selectedId = String x
      setIndex()
  update: (_items, _showEmpty) ->
    items = _items
    showEmpty = _showEmpty
    unless document.activeElement is input
      empty input
      append input, (if showEmpty then [-1].concat(items) else items).map (item) ->
        if item is -1
          E 'option', value: '', ''
        else
          E 'option', {value: getId item}, toPersian getTitle item
      setIndex()
