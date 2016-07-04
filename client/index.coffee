{addPageCSS, addPageStyle, setStyle, destroy} = require './utils'

if module.dynamic
  prevOnerror = window.onerror
  window.onerror = ->
    prevOnerror?.apply window, arguments
    # document.body.innerText = JSON.stringify [].slice.call arguments
    # document.body.style.background = 'red'

if module.hot
  elements = document.body.children
  while elements.length
    destroy elements[0]

else
  addPageCSS 'font-awesome/css/font-awesome.css'
  addPageCSS 'iransans/css/iransans.css'
  addPageStyle "
  * {
    font-family: 'iransans';
    box-sizing: border-box;
    border: 0;
    outline: 0;
    padding: 0;
    margin: 0;
    position: relative;
    direction: rtl;
    -webkit-user-select: none; /* Chrome/Safari */        
    -moz-user-select: none; /* Firefox */
    -ms-user-select: none; /* IE10+ */
    -o-user-select: none;
    user-select: none;
  }
  body {
    height: 100%;
    overflow-x: hidden;
  }
  "
  document.title = 'رصد'
  do ->
    `
    var w = window, 
        d = w.document;

    if( w.onfocusin === undefined ){
        d.addEventListener('focus'    ,addPolyfill    ,true);
        d.addEventListener('blur'     ,addPolyfill    ,true);
        d.addEventListener('focusin'  ,removePolyfill ,true);
        d.addEventListener('focusout' ,removePolyfill ,true);
    }  
    function addPolyfill(e){
        var type = e.type === 'focus' ? 'focusin' : 'focusout';
        var event = new CustomEvent(type, { bubbles:true, cancelable:false });
        event.c1Generated = true;
        e.target.dispatchEvent( event );
    }
    function removePolyfill(e){
        if(!e.c1Generated){ // focus after focusin, so chrome will the first time trigger tow times focusin
            d.removeEventListener('focus'    ,addPolyfill    ,true);
            d.removeEventListener('blur'     ,addPolyfill    ,true);
            d.removeEventListener('focusin'  ,removePolyfill ,true);
            d.removeEventListener('focusout' ,removePolyfill ,true);
        }
        setTimeout(function(){
            d.removeEventListener('focusin'  ,removePolyfill ,true);
            d.removeEventListener('focusout' ,removePolyfill ,true);
        });
    }
    `
  window.performance ?= {}
  performance.now ?= -> +new Date()

page = require './page'
service = require './service'
state = require './state'

page()
['alerts'].forEach (key) ->
  service.keepFresh key, (data) ->
    state[key].set data

if module.dynamic
  unsubscribers = [
    page.onChanged module.reload
  ]
  module.onUnload -> unsubscribers.forEach (unsubscribe) -> unsubscribe()