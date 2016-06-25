{
  isOpera
  isFirefox
  isSafari
  isChrome
  isIE
  isEdge
} = require './platform'

{
  createCookie
  readCookie
  eraseCookie
} = require './cookies'

{
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
} = require './dom'

{
  animation
  spring
} = require './animation'

events = require './events'
numberInput = require './numberInput'
dropdown = require './dropdown'

createPubSub = (name, timeout = 30 * 1000) ->
  data = null
  lastUpdated = 0
  subscribers = []
  setTimeout: (t) -> timeout = t
  onChanged: (callback) ->
    callback data
    subscribers.push callback
    ->
      index = subscribers.indexOf callback
      if ~index
        subscribers.splice index, 1
  get: -> data

  set: set = (newData) ->
    time = +new Date()
    if (newData is data) or (!data and !newData)
      lastUpdated = time
    else if newData?.then?
      if (time - lastUpdated) > timeout
        set loading: true
      newData.then set
      .done()
    else
      lastUpdated = time unless newData?.loading
      d = data
      data = newData
      subscribers.forEach (subscriber) ->
        subscriber newData, d
    return newData

without = (array, item) ->
  index = array.indexOf item
  result = array.slice()
  if ~index
    result.splice index, 1
  result

extend = (target, sources...) ->
  sources.forEach (source) ->
    Object.keys(source).forEach (key) ->
      value = source[key]
      unless key is 'except'
        target[key] = value
      else
        if Array.isArray value
          value.forEach (k) -> delete target[k]
        else if typeof value is 'object'
          Object.keys(value).forEach (k) -> delete target[k]
        else
          delete target[value]
  target

reinsert = (arr, from, to) ->
  return if from is to
  value = arr[from]
  arr.splice from, 1
  arr.splice to, 0, value

toEnglish = (value) ->
  value = '' + value
  '۰۱۲۳۴۵۶۷۸۹'.split ''
  .forEach (digit, i) ->
    value = value.replace (new RegExp digit, 'g'), i
  value.replace '/', '.'

toPersian = (value) ->
  value = '' + value
  '۰۱۲۳۴۵۶۷۸۹'.split ''
  .forEach (digit, i) ->
    value = value.replace (new RegExp '' + i, 'g'), digit
  value.replace(/ي/g, 'ی').replace /ك/g, 'ک'

addPageCSS = (url) ->
  cssNode = document.createElement 'link'
  cssNode.setAttribute 'rel', 'stylesheet'
  cssNode.setAttribute 'href', "/assets/#{url}"
  append document.head, cssNode

addPageStyle = (code) ->
  styleNode = document.createElement 'style'
  styleNode.type = 'text/css'
  styleNode.textContent = code
  append document.head, styleNode

generateId = do ->
  i = 0
  -> i++

collection = (add, destroy, change) ->
  data = []
  (newData) ->
    if newData.length > data.length
      if data.length
        [0 .. data.length - 1].forEach (i) ->
          data[i] = change newData[i], data[i]
      [data.length .. newData.length - 1].forEach (i) ->
        data[i] = add newData[i]
    else if data.length > newData.length
      if newData.length
        [0 .. newData.length - 1].forEach (i) ->
          data[i] = change newData[i], data[i]
      while data.length > newData.length
        destroy data[data.length - 1]
        data.splice (data.length - 1), 1
    else if data.length
      [0 .. data.length - 1].forEach (i) ->
        data[i] = change newData[i], data[i]

emailIsValid = (email) -> /^.+@.+\..+$/.test email

passwordIsValid = (password) -> password.length >= 6

module.exports = {
  isOpera
  isFirefox
  isSafari
  isChrome
  isIE
  isEdge

  createCookie
  readCookie
  eraseCookie

  E
  bindEvent
  setStyle
  addClass
  removeClass
  show
  hide
  enable
  disable
  append
  destroy
  empty

  animation
  spring

  events

  dropdown

  numberInput

  createPubSub
  generateId
  without
  extend
  reinsert
  toEnglish
  toPersian
  addPageCSS
  addPageStyle
  emailIsValid
  passwordIsValid
  collection
}
