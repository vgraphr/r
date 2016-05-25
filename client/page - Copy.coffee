{createElement: E, createClass: C} = require './react'
{extend, toPersian} = require './utils'
gauge = require './gauge'
data = require './data'

gaugeStyle =
  backgroundColor: 'lightblue'
  color: '#3B7DB6'
  border: '1px solid #3B7DB6'
  padding: '4px 15px'
  fontSize: 13
  height: 226

addStyle = extend {}, gaugeStyle,
  cursor: 'pointer'
  lineHeight: "#{gaugeStyle.height}px"
  textAlign: 'center'
  fontSize: 20

module.exports = C
  displayName: 'Page'
  getInitialState: ->
    gauges: []
    s0: 0
    s1: 0
  addGauge: ->
    {gauges} = @state
    gauges.push dataType: 'Info'
    @setState {gauges}
  removeGauge: (gauge) ->
    {gauges} = @state
    gauges.splice gauges.indexOf(gauge), 1
    @setState {gauges}
  componentDidMount: ->
    modal = $('
      <div id="modal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
              <h4 class="modal-title">Modal title</h4>
            </div>
            <div class="modal-body">
              <div id="chart"></div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
              <button type="button" class="btn btn-primary">Save changes</button>
            </div>
          </div>
        </div>
      </div>
    ')
    $(document.body).append(modal)
    modal.modal()
    setTimeout (->
      $('#chart').highcharts 'StockChart',
        title: text: 'Data by minute'
        subtitle: text: 'Using ordinal X axis'
        xAxis: gapGridLineWidth: 0
        rangeSelector :
          buttons : [{
            type : 'hour'
            count : 1
            text : '1h'
          }, {
            type : 'day'
            count : 1
            text : '1D'
          }, {
            type : 'all'
            count : 1
            text : 'All'
          }]
          selected : 1,
          inputEnabled : false
        series : [{
          name : 'Data'
          type: 'area'
          data : data
          gapSize: 5
          tooltip: valueDecimals: 2
          fillColor :
            linearGradient :
              x1: 0
              y1: 0
              x2: 0
              y2: 1
            stops : [
              [0, Highcharts.getOptions().colors[0]]
              [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
            ]
          threshold: null
        }]
      modal.modal('hide')
    ), 0
  render: ->
    {gauges, s0, s1} = @state
    E 'div', className: 'col-md-6 col-md-offset-3', style: marginTop: 50,
      E 'div', className: 'row', style: marginBottom: 20,
        E 'div', className: 'col-md-3', style: padding: 1,
          E 'div', style: addStyle, onClick: @addGauge, 'Add Gauge'
        gauges.map (g) =>
          E 'div', className: 'col-md-3', style: padding: 1,
            E 'div', style: gaugeStyle,
              E gauge, dataType: g.dataType, onClose: => @removeGauge g
      E 'div', className: 'row',
        E 'label', null, 'بازه زمانی انتخابی'
        E 'nav', null,
          E 'ul', className: 'pagination',
            ['۱ دقیقه', '۱۰ دقیقه', '۱ ساعت', '۱۲ ساعت', '۲۴ ساعت', '۱ هفته', '۱۰ روز', '۳۰ روز'].map (x, i) =>
              E 'li', className: (if s0 is i then 'active'), onClick: (=> @setState s0: i), E 'a', style: cursor: 'pointer', x
      E 'div', className: 'row',
        E 'label', null, 'تعداد نمایش در یک صفحه'
        E 'nav', null,
          E 'ul', className: 'pagination',
            [5, 10, 15, 20, 30, 50].map (x, i) =>
              E 'li', className: (if s1 is i then 'active'), onClick: (=> @setState s1: i), E 'a', style: cursor: 'pointer', toPersian x
      E 'div', className: 'row',
        E 'table', className: 'table table-hover',
          E 'thead', null,
            E 'tr', null,
              E 'th', null, 'کد'
              E 'th', null, 'نام'
              E 'th', null, 'منبع'
              E 'th', null, 'ساعت و تاریخ شروغ'
              E 'th', null, 'ساعت و تاریخ پایان'
              E 'th', null, 'وضعیت'
              E 'th', null, 'اولویت'
              E 'th', null, 'تاثیر'
              E 'th', null, 'پشتیبانی توسط:'
              E 'th', null, 'تعداد تکرار در بازه زمانی مشخص'
              E 'th', null, 'تکرار اخطار با کد:'
              E 'th', null, 'Ack'
            E 'tbody', null,
              [1..100].reduce ((arr) ->
                arr.push E 'tr', onClick: (-> $('#modal').modal('show')), style: cursor: 'pointer',
                  E 'th', null, 1
                  E 'td', null, 'Mark'
                  E 'td', null, 'Otto'
                  E 'td', null, '۱۳۷۲/۱۰/۵'
                  E 'td', null, '۱۳۷۲/۱۰/۵'
                  E 'td', null, 'Problem'
                  E 'td', null, '۱'
                  E 'td', null, 'زیاد'
                  E 'td', null, 'درستی'
                  E 'td', null, '۵'
                  E 'td', null, 1
                  E 'td', null, null
                arr.push E 'tr', onClick: (-> $('#modal').modal('show')), style: cursor: 'pointer',
                  E 'th', null, 2
                  E 'td', null, 'Jacob'
                  E 'td', null, 'Thornton'
                  E 'td', null, '۱۳۷۲/۱۰/۵'
                  E 'td', null, '۱۳۷۲/۱۰/۵'
                  E 'td', null, 'Ok'
                  E 'td', null, '۲'
                  E 'td', null, 'زیاد'
                  E 'td', null, 'قیومی'
                  E 'td', null, '۱۰'
                  E 'td', null, 2
                  E 'td', null, null
                arr.push E 'tr', onClick: (-> $('#modal').modal('show')), style: cursor: 'pointer',
                  E 'th', null, 3
                  E 'td', null, 'Larry'
                  E 'td', null, 'the Bird'
                  E 'td', null, '۱۳۷۲/۱۰/۵'
                  E 'td', null, '۱۳۷۲/۱۰/۵'
                  E 'td', null, 'Problem'
                  E 'td', null, '۴'
                  E 'td', null, 'کم'
                  E 'td', null, 'سریع'
                  E 'td', null, '۱۵'
                  E 'td', null, 3
                  E 'td', null, null
                arr
              ), []
      # E 'div', id: 'modal', className: 'modal fade in',
      #   E 'div', className: 'modal-dialog modal-lg',
      #     E 'div', className: 'modal-content',
      #       E 'div', className: 'modal-header',
      #         E 'button', className: 'close'
      #         E 'h4', className: 'modal-title', 'Modal Title'
      #       E 'div', className: 'modal-body',
      #         E 'div', id: 'chart'
      #       E 'div', className: 'modal-footer',
      #         E 'button', className: 'btn btn-default', onClick: (-> $('#modal').modal('hide')), 'close'
      #         E 'button', className: 'btn btn-primary', onClick: (-> $('#modal').modal('hide')), 'Save changes'

if module.dynamic
  module.onUnload gauge.onChanged module.reload
