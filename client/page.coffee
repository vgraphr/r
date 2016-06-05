{E, setStyle, append, events, bindEvent} = require './utils'
table = require './table'

borderStyle =
  width: '94%'
  margin: '0 3%'
  background: 'white'
  border: '2px solid #AAA'
  borderRadius: 5
  padding: '50px 0'
  height: 500

module.exports = ->
  setStyle document.body, background: '#F5F5F5'

  header = E 'img', width: '100%'
  header.setAttribute 'src', '/assets/header.png'

  tableInsance = table()

  border = E borderStyle,
    tableInsance.table
    name  = E 'input', placeholder: 'name', top: 300
    add   = E 'input', type: 'button', value: 'add', top: 300

  tableInsance.addColumn [1..5].map (x, i) ->
    title: x
    width: 10 + 5 * i

  resizeCallback = ->
    setTimeout ->
      tableInsance.resizeTable border.offsetWidth - 4
  events.load resizeCallback
  events.resize resizeCallback
  if module.hot
    resizeCallback()

  bindEvent add, 'click', ->
    tableInsance.addColumn title: name.value

  append [header, border]

if module.dynamic
  unsubscribers = [
    table.onChanged module.reload
  ]
  module.onUnload -> unsubscribers.forEach (unsubscribe) -> unsubscribe()
