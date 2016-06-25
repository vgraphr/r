isIn = (element, {pageX, pageY}) ->
  rect = element.getBoundingClientRect()
  minX = rect.left
  maxX = rect.left + rect.width
  minY = rect.top + window.scrollY
  maxY = rect.top + window.scrollY + rect.height
  minX < pageX < maxX and minY < pageY < maxY

load = (callback) ->
  {bindEvent} = require '.'
  bindEvent window, 'load', callback

resize = (callback) ->
  {bindEvent} = require '.'
  bindEvent window, 'resize', callback

mouseover = (element, callback) ->
  {bindEvent} = require '.'
  allreadyIn = false
  bindEvent document.body, 'mousemove', (e) ->
    if isIn element, e
      callback e unless allreadyIn
      allreadyIn = true
    else
      allreadyIn = false

mouseout = (element, callback) ->
  {bindEvent} = require '.'
  allreadyOut = false
  bindEvent document.body, 'mousemove', (e) ->
    unless isIn element, e
      callback e unless allreadyOut
      allreadyOut = true
    else
      allreadyOut = false
  bindEvent document.body, 'mouseout', (e) ->
    from = e.relatedTarget || e.toElement
    if !from || from.nodeName == 'HTML'
      callback e

mouseup = (callback) ->
  {bindEvent} = require '.'
  bindEvent document.body, 'mouseup', callback
  bindEvent document.body, 'mouseout', (e) ->
    from = e.relatedTarget || e.toElement
    if !from || from.nodeName == 'HTML'
      callback e

enter = (element, callback) ->
  {bindEvent} = require '.'
  bindEvent element, 'keydown', (e) ->
    if e.keyCode is 13
      callback()

module.exports = {
  load
  resize
  mouseover
  mouseout
  mouseup
  enter
}
