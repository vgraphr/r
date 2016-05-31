{E, setStyle, append, bindEvent} = require './utils'
table = require './table'

borderStyle =
  width: '94%'
  margin: '0 3%'
  background: 'white'
  border: '2px solid #AAA'
  borderRadius: 5
  padding: '50px 0'

module.exports = ->
  setStyle document.body, background: '#F5F5F5'

  header = E 'img', width: '100%'
  header.setAttribute 'src', '/assets/header.png'

  border = E borderStyle,
    table.element
    name  = E 'input', top: 300
    add   = E 'input', top: 300

  name.setAttribute 'placeholder', 'name'
  add.setAttribute 'type', 'button'
  add.setAttribute 'value', 'add'
  bindEvent add, 'click', ->
    table.addHeader name: name.value

  append [header, border]

if module.dynamic
  unsubscribers = [
    table.onChanged module.reload
  ]
  module.onUnload -> unsubscribers.forEach (unsubscribe) -> unsubscribe()
