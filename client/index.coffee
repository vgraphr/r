{addPageCSS, addPageStyle, setStyle, destroy} = require './utils'
page = require './page'

if module.dynamic
  prevOnerror = window.onerror
  window.onerror = ->
    prevOnerror?.apply window, arguments
    document.body.innerText = JSON.stringify [].slice.call arguments
    document.body.style.background = 'red'

if module.hot
  elements = document.body.children
  while elements.length
    destroy elements[0]

else
  addPageCSS 'font-awesome/css/font-awesome.css'
  addPageCSS 'iransans/css/iransans.css'
  addPageStyle "
  * {
    font-family: 'iransans';
    box-sizing: border-box;
    border: 0;
    outline: 0;
    padding: 0;
    margin: 0;
    position: relative;
    direction: rtl;
    -webkit-user-select: none; /* Chrome/Safari */        
    -moz-user-select: none; /* Firefox */
    -ms-user-select: none; /* IE10+ */
    -o-user-select: none;
    user-select: none;
  }
  body {
    height: 100%;
  }
  "
  document.title = 'رصد'

do render = ->
  page()

if module.dynamic
  unsubscribers = [
    page.onChanged module.reload
  ]
  module.onUnload -> unsubscribers.forEach (unsubscribe) -> unsubscribe()