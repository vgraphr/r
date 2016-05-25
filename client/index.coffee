content = document.getElementById 'content'

if module.dynamic

  prevOnerror = window.onerror
  window.onerror = ->
    prevOnerror?.apply window, arguments
    content.innerText = JSON.stringify [].slice.call arguments
    document.body.style.background = 'red'

if module.hot
  # console.clear()
  while content.children.length
    content.removeChild content.children[0]

else
  css = document.createElement 'link'
  css.setAttribute 'rel', 'stylesheet'
  css.setAttribute 'href', '/assets/font-awesome/css/font-awesome.css'
  document.head.appendChild css

  css = document.createElement 'link'
  css.setAttribute 'rel', 'stylesheet'
  css.setAttribute 'href', '/assets/iransans/css/iransans.css'
  document.head.appendChild css

  style = document.createElement 'style'
  style.innerText = style.innerHTML = "* { font-family: 'iransans' }"
  document.head.appendChild style

document.title = 'رصد'

# service = require './service'
# service.initialData()

do clearBody = ->
  # console.clear()
  document.body.style.background = 'rgb(245, 245, 245)'

{render, createElement: E} = require './react'
page = require './page'
do renderPage = ->
  render E(page), content

if module.dynamic
  module.onUnload page.onChanged (_page) ->
    page = _page
    clearBody()
    renderPage()