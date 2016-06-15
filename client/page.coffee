{E, setStyle, append, events, bindEvent} = require './utils'
table = require './table'

borderStyle =
  width: '94%'
  margin: '0 3%'
  background: 'white'
  border: '2px solid #AAA'
  borderRadius: 5
  height: 500

toolbarStyle =
  marginTop: 65
  height: 50

module.exports = ->
  setStyle document.body, background: '#F5F5F5'

  header = E 'img', width: '100%'
  header.setAttribute 'src', '/assets/header.png'

  tableInsance = table()

  border = E borderStyle,
    E toolbarStyle,
      timeE = E position: 'absolute', color: '#888', cursor: 'pointer', top: 5, left: 60, class: 'fa fa-calendar'
      searchE = E position: 'absolute', color: '#888', cursor: 'pointer', top: 5, left: 105, class: 'fa fa-search'
      changeE = E position: 'absolute', color: '#888', cursor: 'pointer', top: 5, left: 150, class: 'fa fa-arrows-alt'
    tableInsance.table

  columns = tableInsance.addColumn [1..5].map (x, i) ->
    title: x
    width: 10 + 5 * i

  columns.forEach (column) ->
    column.addData 'lorem'
    column.addData 'ipsum'
    column.addData 'dolor'
    column.addData 'sit'
    column.addData 'amet'

  isChangeMode = false
  bindEvent changeE, 'click', ->
    if isChangeMode
      columns.forEach (column) -> column.defaultMode()
    else
      columns.forEach (column) -> column.changeMode()
    isChangeMode = not isChangeMode

  resizeCallback = ->
    setTimeout ->
      tableInsance.resizeTable border.offsetWidth - 4
  events.load resizeCallback
  events.resize resizeCallback
  if module.hot
    resizeCallback()

  append [header, border]

if module.dynamic
  unsubscribers = [
    table.onChanged module.reload
  ]
  module.onUnload -> unsubscribers.forEach (unsubscribe) -> unsubscribe()
