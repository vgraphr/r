{E, setStyle, append, events, bindEvent, extend, collection} = require './utils'
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
    {name: 'condition'         , title: 'وضعیت'}
    {name: 'actualValue'       , title: 'مقدار واقعی'}
    {name: 'fixed'             , title: 'fixed'}
    {name: 'startTime'         , title: 'زمان شروع'}
    {name: 'alertDefinitionId' , title: 'زمان تعریف'}
    {name: 'endTime'           , title: 'زمان پایان'}
    {name: 'priority'          , title: 'اولویت'}
    {name: 'alertKind'         , title: 'نوع'}
    {name: 'resourceName'      , title: 'منبع'}
    {name: 'repeat'            , title: 'تکرار'}
    {name: 'name'              , title: 'نام'}
    {name: 'id'                , title: 'شناسه'}
  ]
  tableInsance.setHeaderDescriptors descriptors
  border = E borderStyle,
    E toolbarStyle,
      changeBorder = E toolbarBorderStyle,
        timeE = E extend {}, toolbarToggleStyle, class: 'fa fa-calendar'
      searchBorderE = E toolbarBorderStyle,
        searchE = E extend {}, toolbarToggleStyle, class: 'fa fa-search'
        searchSubmitE = E toolbarSubmitStyle,
          E float: 'right', fontSize: 13, marginTop: 1, class: 'fa fa-check'
          E float: 'right', fontSize: 11, margin: '0 5px', 'اعمال'
      changeBorderE = E toolbarBorderStyle,
        changeE = E extend {}, toolbarToggleStyle, class: 'fa fa-arrows-alt'
        changeSubmitE = E toolbarSubmitStyle,
          E float: 'right', fontSize: 13, marginTop: 3, class: 'fa fa-plus'
          E float: 'right', fontSize: 11, margin: '0 5px', 'افزودن ستون'
    tableInsance.table

  columns = tableInsance.addColumn descriptors.map (x) ->
    descriptor: x
    width: 10

  mode = 'default'

  defaultMode = ->
    setStyle changeBorderE, marginTop: 10, padding: 0, background: '#FFF'
    setStyle searchBorderE, marginTop: 10, padding: 0, background: '#FFF'
    setStyle changeSubmitE, width: 0, marginRight: 0, paddingRight: 0, opacity: 0
    setStyle searchSubmitE, width: 0, marginRight: 0, paddingRight: 0, opacity: 0
    columns.forEach (column) -> column.defaultMode()
    mode = 'default'

  bindEvent changeE, 'click', ->
    isChange = mode is 'change'
    defaultMode()
    unless isChange
      setStyle changeBorderE, marginTop: 5, padding: 5, background: '#EEE'
      setStyle changeSubmitE, width: 100, marginRight: 5, paddingRight: 5, opacity: 1
      columns.forEach (column) -> column.changeMode()
      mode = 'change'

  bindEvent searchE, 'click', ->
    isSearch = mode is 'search'
    defaultMode()
    unless isSearch
      setStyle searchBorderE, marginTop: 5, padding: 5, background: '#EEE'
      setStyle searchSubmitE, width: 100, marginRight: 10, paddingRight: 5, opacity: 1
      columns.forEach (column) -> column.searchMode()
      mode = 'search'

  resizeCallback = ->
    setTimeout ->
      tableInsance.resizeTable border.offsetWidth - 4
  events.load resizeCallback
  events.resize resizeCallback
  if module.hot
    resizeCallback()


  bindEvent searchSubmitE, 'click', defaultMode

  alerts = undefined

  setColumnData = (column) ->
    column.empty()
    key = column.getHeaderDescriptor().name
    alerts.forEach (alert) ->
      column.addData alert[key]


  bindEvent changeSubmitE, 'click', ->
    newColumn = tableInsance.addColumn descriptor: descriptors[0]
    newColumn.changeMode()
    newColumn.onChanged ->
      setColumnData newColumn
    setColumnData newColumn
    columns.push newColumn

  columns.forEach (column) ->
    column.onChanged ->
      setColumnData column

  addRow = (alert) ->
    columns.map (column) ->
      {removeDataItem} = column
      key = column.getHeaderDescriptor().name
      element = column.addData alert[key]
      {key, element, removeDataItem}

  removeRow = (data) ->
    data.forEach ({element, removeDataItem}) ->
      removeDataItem element

  changeRow = (alert, data) ->
    data.forEach ({key, element}) ->
      setStyle element, text: alert[key]
    data

  handleRows = collection addRow, removeRow, changeRow

  state.ready 'alerts', (_alerts) ->

    alerts = _alerts

    do update = ->
      filteredAlerts = alerts
      sort = null
      columns.forEach (column) ->
        key = column.getHeaderDescriptor().name
        value = column.getSearchValue()
        filteredAlerts = filteredAlerts.filter (alert) -> not value or ~String(alert[key]).indexOf value
        sortDirection = column.getSortDirection()
        if sortDirection
          sort = key: key, direction: sortDirection

        column.onSearch update
        column.onSort update

      if sort
        {key, direction} = sort
        compare = (a, b) -> if a > b then 1 else if a < b then -1 else 0
        filteredAlerts = filteredAlerts.sort (a, b) -> if direction is 'up' then compare(a[key], b[key]) else  compare(b[key], a[key])
      handleRows filteredAlerts

      columns.forEach (column) ->
        column.getDataItems().forEach (element, i) ->
          if i % 2
            setStyle element, background: '#F8F8F8'
        column.setHeight filteredAlerts.length * 23 + 100

      setStyle border, height: filteredAlerts.length * 23  + 210
      resizeCallback()



  append [header, border]

if module.dynamic
  unsubscribers = [
    table.onChanged module.reload
  ]
  module.onUnload -> unsubscribers.forEach (unsubscribe) -> unsubscribe()
