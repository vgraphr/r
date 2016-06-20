{E, setStyle, append, events, bindEvent, extend} = require './utils'
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
  height: 60

toolbarBorderStyle =
  marginTop: 10
  marginLeft: 20
  float: 'left'
  transition: '0.15s'
  borderRadius: 3

toolbarToggleStyle =
  float: 'right'
  color: '#888'
  cursor: 'pointer'
  lineHeight: 25
  height: 25
  display: 'block'

module.exports = ->
  setStyle document.body, background: '#F5F5F5'

  header = E 'img', width: '100%'
  header.setAttribute 'src', '/assets/header.png'

  tableInsance = table()

  border = E borderStyle,
    E toolbarStyle,
      changeBorder = E toolbarBorderStyle,
        timeE = E extend {}, toolbarToggleStyle, class: 'fa fa-calendar'
      changeBorder = E toolbarBorderStyle,
        searchE = E extend {}, toolbarToggleStyle, class: 'fa fa-search'
      changeBorderE = E toolbarBorderStyle,
        changeE = E extend {}, toolbarToggleStyle, class: 'fa fa-arrows-alt'
        changeSubmitE = E float: 'right', background: '#5CB85C', width: 0, height: 25, borderRadius: 3, transition: '0.15s', overflow: 'hidden', color: 'white', cursor: 'pointer', opacity: 0, paddingTop: 3,
          E float: 'right', fontSize: 16, class: 'fa fa-plus'
          E float: 'right', fontSize: 11, margin: '0 5px', 'افزودن ستون'
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
    column.setListItems ['lorem', 'ipsum', 'dolor', 'sit', 'amet']

  isChangeMode = false
  bindEvent changeE, 'click', ->
    if isChangeMode
      setStyle changeBorderE, marginTop: 10, padding: 0, background: '#FFF'
      setStyle changeSubmitE, width: 0, marginRight: 0, paddingRight: 0, opacity: 0
      columns.forEach (column) -> column.defaultMode()
    else
      setStyle changeBorderE, marginTop: 0, padding: '10px 10px', background: '#EEE'
      setStyle changeSubmitE, width: 100, marginRight: 10, paddingRight: 5, opacity: 1
      columns.forEach (column) -> column.changeMode()
    isChangeMode = not isChangeMode

  bindEvent changeSubmitE, 'click', ->
    columns.push newColumn = tableInsance.addColumn title: 'ali'
    newColumn.setListItems ['lorem', 'ipsum', 'dolor', 'sit', 'amet']
    newColumn.changeMode()

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
