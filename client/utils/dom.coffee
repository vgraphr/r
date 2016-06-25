{isFirefox} = require '.'

bindEvent = (element, event, callback) ->
  if Array.isArray element
    unbinds = element.map (element) -> bindEvent element, event, callback
    return -> unbinds.forEach (unbind) -> unbind()
  element.addEventListener event, callback
  -> element.removeEventListener event, callback

append = ->
  if arguments.length is 1
    element = arguments[0]
    parent = document.body
  else if arguments.length is 2
    element = arguments[1]
    parent = arguments[0]
  if Array.isArray element
    element.forEach (element) ->
      append parent, element
  else if element
    parent.appendChild element

destroy = (element) -> element.parentNode.removeChild element

empty = (element) ->
  while element.children?.length
    destroy element.children[0]

setStyle = (element, style = {}) ->
  if Array.isArray element
    return element.map (element) -> setStyle element, style
  Object.keys(style).forEach (key) ->
    val = style[key]
    if key is 'text'
      if isFirefox
        element.innerHTML = val
      else
        element.innerText = val
    else if key is 'value'
      element.value = val
      element.dispatchEvent new Event 'input'
    else if key in ['class', 'type', 'placeholder', 'id', 'for']
      element.setAttribute key, val
    else
      if (typeof val is 'number') and not (key in ['opacity', 'zIndex'])
        val = Math.floor(val) + 'px' 
      element.style[key] = val
  return element

addClass = (element, klass) ->
  element.setAttribute 'class', ((element.getAttribute('class') ? '') + ' ' + klass).replace(/\ +/g, ' ').trim()
  return element

removeClass = (element, klass) ->
  previousClass = (element.getAttribute 'class') ? ''
  classIndex = previousClass.indexOf klass
  if ~classIndex
    element.setAttribute 'class', ((previousClass.substr 0, classIndex) + (previousClass.substr classIndex + klass.length)).replace(/\ +/g, ' ').trim()
  return element

show = (element) ->
  if Array.isArray element
    return element.map (element) -> show element
  removeClass element, 'hidden'
  return element

hide = (element) ->
  if Array.isArray element
    return element.map (element) -> hide element
  removeClass element, 'hidden'
  addClass element, 'hidden'
  return element

enable = (element) ->
  if Array.isArray element
    return element.map (element) -> enable element
  element.removeAttribute 'disabled'
  return element

disable = (element) ->
  if Array.isArray element
    return element.map (element) -> disable element
  element.setAttribute 'disabled', 'disabled'
  return element

E = do ->
  e = (tagName, style, children...) ->
    element = document.createElement tagName
    setStyle element, style
    do appendChildren = (children) ->
      children.forEach (x) ->
        if (typeof x is 'string') or (typeof x is 'number')
          setStyle element, text: x
        else if Array.isArray x
          appendChildren x
        else
          append element, x
    element

  ->
    firstArg = arguments[0]
    if typeof firstArg is 'string'
      e.apply null, arguments
    else if typeof firstArg is 'object' and not Array.isArray firstArg
      args = [].slice.call arguments
      args.splice 0, 0, 'div'
      e.apply null, args
    else
      args = [].slice.call arguments
      args.splice 0, 0, 'div', {}
      e.apply null, args

module.exports = {
  bindEvent
  append
  destroy
  empty
  setStyle
  addClass
  removeClass
  show
  hide
  enable
  disable
  E
}
