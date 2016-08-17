{E, setStyle, append, events, bindEvent, extend, collection, empty} = require './utils'
jalaali = require './jalaali'
table = require './table'

borderStyle =
  width: '94%'
  margin: '0 3%'
  background: 'white'
  border: '1px solid #CCC'
  borderRadius: 5
  height: 1000

toolbarStyle =
  height: 45

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

toolbarSubmitStyle =
  float: 'right'
  background: '#5CB85C'
  width: 0
  height: 25
  borderRadius: 3
  transition: '0.15s'
  overflow: 'hidden'
  color: 'white'
  cursor: 'pointer'
  opacity: 0
  paddingTop: 3

module.exports = ->
  state = require './state'

  setStyle document.body, background: '#F5F5F5'

  header = E 'img', width: '100%'
  header.setAttribute 'src', '/assets/header.png'

  tableInsance = table()

  descriptors = [
    {name: 'acknowledged' , title: 'Ack'}
    {name: 'count'        , title: 'تعداد'}
    {name: 'condition'    , title: 'شرایط'}
    {name: 'actualValue'  , title: 'مقدار واقعی'}
    {name: 'fixed'        , title: 'وضعیت'}
    {name: 'endTime'      , title: 'زمان پایان', noSearch: true}
    {name: 'startTime'    , title: 'زمان شروع', noSearch: true}
    {name: 'priority'     , title: 'اولویت'}
    {name: 'alertKind'    , title: 'نوع'}
    {name: 'supportUnit'  , title: 'واحد پشتیبانی'}
    {name: 'resourceName' , title: 'منبع'}
    {name: 'name'         , title: 'نام'}
  ]
  tableInsance.setHeaderDescriptors descriptors
  border = E borderStyle,
    E toolbarStyle,
      E toolbarBorderStyle,
        timeE = E extend {}, toolbarToggleStyle, class: 'fa fa-calendar'
      E toolbarBorderStyle,
        searchE = E extend {}, toolbarToggleStyle, class: 'fa fa-search'
      changeBorderE = E toolbarBorderStyle,
        changeE = E extend {}, toolbarToggleStyle, class: 'fa fa-arrows-alt'
        changeSubmitE = E toolbarSubmitStyle,
          E float: 'right', fontSize: 13, marginTop: 3, class: 'fa fa-plus'
          E float: 'right', fontSize: 11, margin: '0 5px', 'افزودن ستون'
    tableInsance.table

  columns = tableInsance.addColumn descriptors.map (descriptor) -> {descriptor, width: 10}

  mode = 'default'

  defaultMode = ->
    setStyle changeBorderE, marginTop: 10, padding: 0, background: '#FFF'
    setStyle changeSubmitE, width: 0, marginRight: 0, paddingRight: 0, opacity: 0
    setStyle changeE, toolbarToggleStyle
    setStyle searchE, toolbarToggleStyle
    columns.forEach (column) -> column.defaultMode()
    mode = 'default'

  bindEvent changeE, 'click', ->
    isChange = mode is 'change'
    defaultMode()
    unless isChange
      setStyle changeE, color: '#5BC0DE'
      setStyle changeBorderE, marginTop: 5, padding: 5, background: '#EEE'
      setStyle changeSubmitE, width: 100, marginRight: 5, paddingRight: 5, opacity: 1
      columns.forEach (column) -> column.changeMode()
      mode = 'change'

  bindEvent searchE, 'click', ->
    isSearch = mode is 'search'
    defaultMode()
    unless isSearch
      setStyle searchE, color: '#5BC0DE'
      columns.forEach (column) -> column.searchMode()
      mode = 'search'

  resizeCallback = ->
    setTimeout ->
      tableInsance.resizeTable border.offsetWidth - 4
  events.load resizeCallback
  events.resize resizeCallback
  if module.hot
    resizeCallback()

  alerts = filteredAlerts = []

  columns.forEach (column) ->
    column.onSearch -> update()
    column.onSort -> update()
    column.onChanged -> update()

  bindEvent changeSubmitE, 'click', ->
    column = tableInsance.addColumn descriptor: descriptors[0]
    column.changeMode()
    columns.push column
    column.onSearch -> update()
    column.onSort -> update()
    column.onChanged -> update()
    filteredAlerts.forEach (alert) ->
      key = column.getHeaderDescriptor().name
      placeholder = E()
      append placeholder, getDataItem alert, key
      column.addDataItem placeholder

  getDataItem = (alert, key) ->
    switch key
      when 'priority'
        E null, [1..alert.priority].map -> E float: 'right', width: 2, height: 20, margin: 1, borderRadius: 10, background: switch alert.priority
          when 1
            '#5CB85C'
          when 2
            '#F0AD4E'
          when 3
            '#D9534F'
      when 'fixed'
        E color: (if alert.fixed then '#5CB85C' else '#D9534F'), fontWeight: (if alert.acknowledged then 'normal' else 'bold'), text: if alert.fixed then 'OK' else 'Problem'
      when 'acknowledged'
        E fontWeight: (if alert.acknowledged then 'normal' else 'bold'), text: if alert.acknowledged then '✓' else ''
      when 'startTime', 'endTime'
        date = new Date alert[key]
        hours = date.getHours()
        minutes = date.getMinutes()
        seconds = date.getSeconds()
        day = date.getDate()
        month = date.getMonth() + 1
        year = date.getFullYear()
        {jd: day, jm: month, jy: year} = jalaali.toJalaali(year, month, day)
        E fontWeight: (if alert.acknowledged then 'normal' else 'bold'),
          E display: 'inline-block', marginLeft: 15, text: "#{hours}:#{minutes}:#{seconds}"
          E display: 'inline-block', text: "#{String(year).substr(2)}/#{month}/#{day}"
      else
        E fontWeight: (if alert.acknowledged then 'normal' else 'bold'), text: alert[key] ? ''

  addRow = (alert) ->
    columns.map (column) ->
      {removeDataItem} = column
      key = column.getHeaderDescriptor().name
      placeholder = E()
      append placeholder, getDataItem alert, key
      column.addDataItem placeholder
      bindEvent placeholder, 'click', ->
        alert.acknowledged = true
        update()
      {column, placeholder, removeDataItem}

  removeRow = (data) ->
    data.forEach ({placeholder, removeDataItem}) ->
      removeDataItem placeholder

  changeRow = (alert, data) ->
    data.forEach ({column, placeholder}) ->
      key = column.getHeaderDescriptor().name
      empty placeholder
      append placeholder, getDataItem alert, key
    data

  handleRows = collection addRow, removeRow, changeRow

  update = ->
    filteredAlerts = []
    alerts.forEach (alert) ->
      similarAlerts = filteredAlerts.filter ({alertDefinitionId, fixed}) -> alertDefinitionId is alert.alertDefinitionId and fixed is alert.fixed
      lastAlert = similarAlerts[similarAlerts.length - 1]
      if lastAlert
        lastAlert.count++
      else
        alert.count = 1
        filteredAlerts.push alert

    sort = null
    columns.forEach (column) ->
      key = column.getHeaderDescriptor().name
      value = column.getSearchValue()
      filteredAlerts = filteredAlerts.filter (alert) -> not value or ~String(alert[key]).indexOf value
      sortDirection = column.getSortDirection()
      if sortDirection
        sort = key: key, direction: sortDirection

    if sort
      {key, direction} = sort
      compare = (a, b) -> if a > b then 1 else if a < b then -1 else 0
      filteredAlerts = filteredAlerts.sort (a, b) -> if direction is 'up' then compare(a[key], b[key]) else  compare(b[key], a[key])
    handleRows filteredAlerts

    setStyle border, height: filteredAlerts.length * 23  + 210
    resizeCallback()

  state.ready 'alerts', (_alerts) ->
    alerts = alerts.concat _alerts.filter (alert) -> not alerts.some ({id}) -> alert.id is id
    update()

  append [header, border]

if module.dynamic
  unsubscribers = [
    table.onChanged module.reload
  ]
  module.onUnload -> unsubscribers.forEach (unsubscribe) -> unsubscribe()
