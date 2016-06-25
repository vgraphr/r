{extend} = require './utils'

exports.tableStyle =
  display: 'block'
  width: '100%'

exports.columnStyle =
  position: 'absolute'
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
  overflow: 'hidden'

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

exports.columnDataStyle =
  position: 'absolute'
  top: 50
  left: 0
  right: 10
  overflow: 'hidden'
  transition: '0.15s'
  marginTop: 0

exports.columnChangeStyle =
  position: 'absolute'
  top: 40
  left: -1
  right: -1
  class: 'fa fa-angle-down'
  textAlign: 'center'
  overflow: 'hidden'
  background: '#BBB'
  color: 'white'
  zIndex: 10
  cursor: 'pointer'
  transition: '0.15s'
  height: 0
  lineHeight: 0
  opacity: 0

exports.columnChangeListStyle =
  position: 'absolute'
  minWidth: 170
  top: 50
  background: 'white'
  boxShadow: 'rgba(0, 0, 0, 0.2) 0px 16px 32px 0px'
  zIndex: 9999
  transition: '0.15s'
  opacity: 0
  visibility: 'hidden'

exports.columnChangeBackStyle = extend {}, exports.columnChangeStyle,
  class: 'fa fa-angle-up'
  background: 'white'
  color: 'black'
  height: 10
  lineHeight: 10
  opacity: 1

exports.columnDeleteStyle =
  background: '#D9534F'
  color: 'white'
  position: 'absolute'
  bottom: -35
  left: 0
  right: 0
  height: 35
  lineHeight: 35
  textAlign: 'center'
  borderRadius: '0 0 5px 5px'
  cursor: 'pointer'

exports.columnListItemStyle =
  padding: '5px 15px 5px 80px'
  color: '#888'
  cursor: 'pointer'

exports.columnSearchStyle = 
  position: 'absolute'
  top: 40
  left: -1
  right: -1
  textAlign: 'center'
  overflow: 'hidden'
  background: 'white'
  zIndex: 10
  transition: '0.15s'
  height: 0
  lineHeight: 0
  borderBottom: '1px solid #5BC0DE'
  opacity: 0

exports.columnSearchboxStyle =
  border: '1px solid #DDD'
  position: 'absolute'
  width: '90%'
  top: 5
  bottom: 5
  left: '5%'
  right: '5%'
