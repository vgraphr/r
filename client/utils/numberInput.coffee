module.exports = (style) ->
  {E, bindEvent, toEnglish, toPersian} = require '.'
  
  input = E 'input', style
  prevValue = ''
  handler = ->
    value = input.value
    if /^[0-9]*$/.test toEnglish value
      prevValue = value
    else
      value = prevValue
    input.value = toPersian value
  bindEvent input, 'input', handler
  return input