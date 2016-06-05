{extend} = require './utils'

exports.tableStyle =
  display: 'block'
  width: '100%'

exports.columnStyle =
  position: 'absolute'
  height: 200
  background: 'white'
  borderLeft: '1px dashed #EEE'
  borderRight: '1px dashed #EEE'

exports.borderStyle = 
  position: 'absolute'
  left: -1
  right: -1
  height: '100%'
  transition: 'border 0.15s'
  borderLeft: '1px solid transparent'
  borderRight: '1px solid transparent'

exports.cellStyle =
  background: 'white'
  display: 'inline-block'
  height: 40
  fontSize: 11

exports.headerStyle = extend {}, exports.cellStyle,
  borderTop: '1px solid #DDD'
  borderBottom: '1px solid #DDD'
  fontSize: 20
  position: 'absolute'
  color: '#888'
  left: 0
  right: 0

exports.headerSpanStyle =
  position: 'absolute'
  left: 30
  right: 10
  lineHeight: 40
  overflow: 'hidden'
  color: '#888'
  transition: '0.15s'

exports.headerBottomBorderStyle = 
  position: 'absolute'
  bottom: -1
  left: 0
  right: 0
  background: '#5BC0DE'
  transition: '0.15s'
  height: 0

exports.headerUpButtonStyle =
  position: 'absolute'
  left: 10
  fontSize: 11
  cursor: 'pointer'
  top: 10
  class: 'fa fa-caret-up'

exports.headerDownButtonStyle =
  position: 'absolute'
  left: 10
  fontSize: 11
  cursor: 'pointer'
  bottom: 10
  class: 'fa fa-caret-down'

exports.headerHoverSpanStyle =
  color: '#5BC0DE'

exports.headerHoverBottomBorderStyle =
  height: 2

exports.borderHoverColor = '1px solid #5BC0DE'
