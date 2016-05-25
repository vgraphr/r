{createElement: E, createClass: C} = require './react'
{Gauge} = require './gauges'

options =
  lines: 12
  angle: 0.15
  lineWidth: 0.44
  pointer:
    length: 0.9
    strokeWidth: 0.035
    color: '#000000'
  limitMax: 'false'
  colorStart: '#6FADCF'
  colorStop: '#8FC0DA'
  strokeColor: '#E0E0E0'
  generateGradient: true

closeStyle =
  cursor: 'pointer'

valueStyle =
  fontSize: 15
  color: 'black'
  textAlign: 'center'
  margin: 5

selectStyle =
  width: '100%'
  margin: '5px 0'

module.exports = C
  displayName: 'gauge'
  getInitialState: ->
    gauge: null
    value: 0
  componentWillUpdate: ->
    # {gauge, value} = @state
    # gauge?.set value
  onTypeChanged: (type) ->
    @setState value: 900 + Math.round (Math.random() * 1000)
    {gauge, value} = @state
    gauge?.set value
  componentDidMount: ->
    return if @state.gauge
    target = @refs.canvas
    gauge = new Gauge(target).setOptions options
    gauge.maxValue = 3000
    gauge.animationSpeed = 32
    @setState {gauge}
    setTimeout (=> @onTypeChanged @state.dataType), 10
  render: ->
    {dataType, onClose} = @props
    {value} = @state
    E 'div', null,
      E 'div', style: closeStyle, onClick: onClose, 'close'
      E 'select', style: selectStyle, onChange: ((e) => @onTypeChanged e.target.value),
        ['Info', 'Warning', 'High', 'Disaster', 'No Effect', 'Service Affect', 'Transaction Affect'].map (x) ->
          E 'option', null, x
      E 'select', style: selectStyle, onChange: ((e) => @onTypeChanged e.target.value),
        ['۱۰ دقیقه گذشته', 'بازه زمانی مشخص شده'].map (x) ->
          E 'option', null, x
      E 'canvas', ref: 'canvas', style: width: '100%', height: '100%'
      E 'div', style: valueStyle, value