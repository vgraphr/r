{createElement: E, createClass: C} = require './react'
state = require './state'
service = require './service'
{extend} = require './utils'

thStyle =
  background: 'white'
  borderTop: '1px solid #DCE9F9'
  color: '#888'
  cursor: 'default'
  height: 40
  position: 'relative'
  transition: '0.3s'
  borderBottom: '2px solid #555'
thMouseOver = (e) ->
  elem = e.target
  while elem.tagName.toLowerCase() isnt 'th'
    elem = elem.parentNode
  elem.style.color = '#5BC0DE'
  elem.style.borderBottom = '2px solid #5BC0DE'
thMouseOut = (e) ->
  elem = e.target
  while elem.tagName.toLowerCase() isnt 'th'
    elem = elem.parentNode
  elem.style.color = '#888'
  elem.style.borderBottom = '2px solid #555'

module.exports = C
  displayName: 'Page'
  getInitialState: ->
    alerts: [
      {id: 1, name: 'خطای 1', condition: 'OK', priority: 1}
      {id: 1, name: 'خطای 2', condition: 'Problem', priority: 4}
      {id: 1, name: 'خطای 3', condition: 'Problem', priority: 7}
    ]
  componentWillMount: ->
    @offAlerts = state.alerts.onChanged (alerts) => @setState alerts:
      [
        {id: 1, name: 'خطای 1', condition: 'OK', priority: 1}
        {id: 1, name: 'خطای 2', condition: 'Problem', priority: 4}
        {id: 1, name: 'خطای 3', condition: 'Problem', priority: 7}
      ].concat alerts
  componentWillUnmount: ->
    @offAlerts()
  render: ->
    E 'div', null,
      E 'img', src: '/assets/header.png', style: width: '100%'
      E 'div', className: 'col-md-10 col-md-offset-1', position: 'relative', style: padding: 20,
        E 'img', src: '/assets/gauges.png', style: height: 80
        E 'div', style: position: 'absolute', left: 20, bottom: 40,
          E 'i', className: 'fa fa-times-circle', style: cursor: 'pointer', fontSize: 23, float: 'left', color: '#888'
          E 'input', value: '۹۴/۱۲/۰۳ — ۲۳:۱۲:۱۱', style: margin: '0 10px', textAlign: 'center', color: '#888', float: 'left', width: 135, height: 25, background: '#EEE', border: '1px solid #DDD', borderRadius: 3
          E 'span', style: lineHeight: '25px', float: 'left', color: '#888', 'تا'
          E 'input', value: '۹۴/۱۲/۰۳ — ۲۳:۱۲:۱۱', style: margin: '0 10px', textAlign: 'center', color: '#888', float: 'left', width: 135, height: 25, background: '#EEE', border: '1px solid #DDD', borderRadius: 3
          E 'i', className: 'fa fa-calendar', style: cursor: 'pointer', fontSize: 23, float: 'left', color: '#888'
      E 'div', className: 'col-md-10 col-md-offset-1',
        E 'table', className: 'table', style: borderCollapse: 'separate',
          E 'thead', null,
            E 'tr', null,
              E 'th', onMouseOver: thMouseOver, onMouseOut: thMouseOut, style: (extend {border: '1px solid #DCE9F9'}, thStyle, borderTopRightRadius: 5, cursor: 'pointer'),
                E 'i', className: 'fa fa-search', style: border: 0
              ['شناسه', 'نام', 'منبع', 'شروع', 'پایان', 'وضعیت', 'اولویت', 'مقدار', 'نوع', 'واحد پشتیبانی', 'تکرار'].map (name, i, arr) ->
                E 'th', onMouseOver: thMouseOver, onMouseOut: thMouseOut, style: (if i < arr.length - 1 then thStyle else extend {}, thStyle, borderLeft:  '1px solid #DCE9F9', borderTopLeftRadius: 5) , name,
                  E 'i', className: 'fa fa-caret-up', style: cursor: 'pointer', position: 'absolute', top: 8, left: 7
                  E 'i', className: 'fa fa-caret-down', style: cursor: 'pointer', position: 'absolute', bottom: 8, left: 7
            E 'tbody', null,
              @state.alerts.map (alert, i) ->
                if alert.startTime
                  date = new Date alert.startTime
                  day = date.getDate()
                  month = date.getMonth() + 1
                  year = date.getFullYear()
                  hours = date.getHours()
                  minutes = date.getMinutes()
                  seconds = date.getSeconds()
                E 'tr', style: cursor: 'pointer', background: (if i % 2 then 'rgb(246,248,249)' else 'white'),
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px solid #DCE9F9'
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', alert.id
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', alert.name
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', alert.resourceName
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', width: 150,
                    if alert.startTime then [
                      E 'span', null, "#{day}/#{month}/#{year}"
                      E 'span', style: float: 'left', paddingLeft: 25, "#{hours}:#{minutes}:#{seconds}"
                    ]
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', alert.endTime
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', color: (if alert.condition is 'OK' then '#5CB85C' else if alert.condition is 'Problem' then '#D9534F'), alert.condition
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', [1..alert.priority].map ->
                    E 'span', style: display: 'block', float: 'right', width: 3, height: 17, margin: 1, borderRadius: 10, background: if alert.priority > 5 then '#D9534F' else if alert.priority < 3 then '#5CB85C' else '#F0AD4E'
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', alert.actualValue
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', alert.alertKind
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', alert.supportUnit
                  E 'td', style: fontSize: 12, fontWeight: 'bold', borderRight: '1px dashed #DCE9F9', padding: '3px 10px', borderLeft: '1px solid #DCE9F9', alert.repeat
