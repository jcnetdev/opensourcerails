/* ---- Compressing ./public/javascripts/libraries/control.rating.js ----- */
/**
 * @author Ryan Johnson <ryan@livepipe.net>
 * @copyright 2007 LivePipe LLC
 * @package Control.Rating
 * @license MIT
 * @url http://livepipe.net/projects/control_rating/
 * @version 1.0.1
 */

if(typeof(Control) == 'undefined')
	Control = {};
Control.Rating = Class.create();
Object.extend(Control.Rating,{
	instances: [],
	findByElementId: function(id){
		return Control.Rating.instances.find(function(instance){
			return (instance.container.id && instance.container.id == id);
		});
	}
});
Object.extend(Control.Rating.prototype,{
	container: false,
	value: false,
	options: {},
	initialize: function(container,options){
		Control.Rating.instances.push(this);
		this.value = false;
		this.links = [];
		this.container = $(container);
		this.container.update('');
		this.options = {
			min: 1,
			max: 5,
			rated: false,
			input: false,
			reverse: false,
			capture: true,
			multiple: false,
			classNames: {
				off: 'rating_off',
				half: 'rating_half',
				on: 'rating_on',
				selected: 'rating_selected'
			},
			updateUrl: false,
			updateParameterName: 'value',
			afterChange: Prototype.emptyFunction
		};
		Object.extend(this.options,options || {});
		if(this.options.value){
			this.value = this.options.value;
			delete this.options.value;
		}
		if(this.options.input){
			this.options.input = $(this.options.input);
			this.options.input.observe('change',function(input){
				this.setValueFromInput(input);
			}.bind(this,this.options.input));
			this.setValueFromInput(this.options.input,true);
		}
		var range = $R(this.options.min,this.options.max);
		(this.options.reverse ? $A(range).reverse() : range).each(function(i){
			var link = this.buildLink(i);
			this.container.appendChild(link);
			this.links.push(link);
		}.bind(this));
		this.setValue(this.value || this.options.min - 1,false,true);
	},
	buildLink: function(rating){
		var link = $(document.createElement('a'));
		link.value = rating;
		if(this.options.multiple || (!this.options.rated && !this.options.multiple)){
			link.href = '';
			link.onmouseover = this.mouseOver.bind(this,link);
			link.onmouseout = this.mouseOut.bind(this,link);
			link.onclick = this.click.bindAsEventListener(this,link);
		}else{
			link.style.cursor = 'default';
			link.observe('click',function(event){
				Event.stop(event);
				return false;
			}.bindAsEventListener(this));
		}
		link.addClassName(this.options.classNames.off);
		return link;
	},
	disable: function(){
		this.links.each(function(link){
			link.onmouseover = Prototype.emptyFunction;
			link.onmouseout = Prototype.emptyFunction;
			link.onclick = Prototype.emptyFunction;
			link.observe('click',function(event){
				Event.stop(event);
				return false;
			}.bindAsEventListener(this));
			link.style.cursor = 'default';
		}.bind(this));
	},
	setValueFromInput: function(input,prevent_callbacks){
		this.setValue((input.options ? input.options[input.options.selectedIndex].value : input.value),true,prevent_callbacks);
	},
	setValue: function(value,force_selected,prevent_callbacks){
		this.value = value;
		if(this.options.input){
			if(this.options.input.options){
				$A(this.options.input.options).each(function(option,i){
					if(option.value == this.value){
						this.options.input.options.selectedIndex = i;
						throw $break;
					}
				}.bind(this));
			}else
				this.options.input.value = this.value;
		}
		this.render(this.value,force_selected);
		if(!prevent_callbacks){
			if(this.options.updateUrl){
				var params = {};
				params[this.options.updateParameterName] = this.value;
				new Ajax.Request(this.options.updateUrl,{
					parameters: params
				});
			}
			this.notify('afterChange',this.value);
		}
	},
	render: function(rating,force_selected){
		(this.options.reverse ? this.links.reverse() : this.links).each(function(link,i){
			if(link.value <= Math.ceil(rating)){
				link.className = this.options.classNames[link.value <= rating ? 'on' : 'half'];
				if(this.options.rated || force_selected)
					link.addClassName(this.options.classNames.selected);
			}else
				link.className = this.options.classNames.off;
		}.bind(this));
	},
	mouseOver: function(link){
		this.render(link.value,true);
	},
	mouseOut: function(link){
		this.render(this.value);
	},
	click: function(event,link){
		this.options.rated = true;
		this.setValue((link.value ? link.value : link),true);
		if(!this.options.multiple)
			this.disable();
		if(this.options.capture){
			Event.stop(event);
			return false;
		}
	},
	notify: function(event_name){
		try{
			if(this.options[event_name])
				return [this.options[event_name].apply(this.options[event_name],$A(arguments).slice(1))];
		}catch(e){
			if(e != $break)
				throw e;
			else
				return false;
		}
	}
});
if(typeof(Object.Event) != 'undefined')
	Object.Event.extend(Control.Rating);

/* ---- Compressing ./public/javascripts/libraries/dragscrollable.js ----- */
var DragScrollable = Class.create();
DragScrollable.prototype = {
  initialize: function(element) {
    this.element = $(element);
    this.active = false;
    this.scrolling = false;

    // this.element.style.cursor = 'pointer';

    this.eventMouseDown = this.startScroll.bindAsEventListener(this);
    this.eventMouseUp   = this.endScroll.bindAsEventListener(this);
    this.eventMouseMove = this.scroll.bindAsEventListener(this);
    
    this.element.title = "Drag Image to Scroll"
    Event.observe(this.element, 'mousedown', this.eventMouseDown);
  },
  destroy: function() {
    Event.stopObserving(this.element, 'mousedown', this.eventMouseDown);
    Event.stopObserving(document, 'mouseup', this.eventMouseUp);
    Event.stopObserving(document, 'mousemove', this.eventMouseMove);
  },
  startScroll: function(event) {
    this.startX = Event.pointerX(event);
    this.startY = Event.pointerY(event);
    if (Event.isLeftClick(event) &&
        (this.startX < this.element.offsetLeft + this.element.clientWidth) &&
        (this.startY < this.element.offsetTop + this.element.clientHeight)) {
      this.element.style.cursor = 'move';
      Event.observe(document, 'mouseup', this.eventMouseUp);
      Event.observe(document, 'mousemove', this.eventMouseMove);
      this.active = true;
      Event.stop(event);
    }
  },
  endScroll: function(event) {
    // this.element.style.cursor = 'pointer';
    this.active = false;
    Event.stopObserving(document, 'mouseup', this.eventMouseUp);
    Event.stopObserving(document, 'mousemove', this.eventMouseMove);
    Event.stop(event);
  },
  scroll: function(event) {
    if (this.active) {
      this.element.scrollTop += (this.startY - Event.pointerY(event));
      this.element.scrollLeft += (this.startX - Event.pointerX(event));
      this.startX = Event.pointerX(event);
      this.startY = Event.pointerY(event);
    }
    Event.stop(event);
  }
}

/* ---- Compressing ./public/javascripts/libraries/firebugx.js ----- */

if (!("console" in window) || !("firebug" in console))
{
    var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
    "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];

    window.console = {};
    for (var i = 0; i < names.length; ++i)
        window.console[names[i]] = function() {}
}

/* ---- Compressing ./public/javascripts/libraries/keyboard_shortcut.js ----- */
/**
 * http://www.openjs.com/scripts/events/keyboard_shortcuts/
 * Version : 2.01.B
 * By Binny V A
 * License : BSD
 */
shortcut = {
	'all_shortcuts':{},//All the shortcuts are stored in this array
	'add': function(shortcut_combination,callback,opt) {
		//Provide a set of default options
		var default_options = {
			'type':'keydown',
			'propagate':false,
			'disable_in_input':false,
			'target':document,
			'keycode':false
		}
		if(!opt) opt = default_options;
		else {
			for(var dfo in default_options) {
				if(typeof opt[dfo] == 'undefined') opt[dfo] = default_options[dfo];
			}
		}

		var ele = opt.target
		if(typeof opt.target == 'string') ele = document.getElementById(opt.target);
		var ths = this;
		shortcut_combination = shortcut_combination.toLowerCase();

		//The function to be called at keypress
		var func = function(e) {
			e = e || window.event;
			
			if(opt['disable_in_input']) { //Don't enable shortcut keys in Input, Textarea fields
				var element;
				if(e.target) element=e.target;
				else if(e.srcElement) element=e.srcElement;
				if(element.nodeType==3) element=element.parentNode;

				if(element.tagName == 'INPUT' || element.tagName == 'TEXTAREA') return;
			}
	
			//Find Which key is pressed
			if (e.keyCode) code = e.keyCode;
			else if (e.which) code = e.which;
			var character = String.fromCharCode(code);
			
			if(code == 188) character=","; //If the user presses , when the type is onkeydown
			if(code == 190) character="."; //If the user presses , when the type is onkeydown

			var keys = shortcut_combination.split("+");
			//Key Pressed - counts the number of valid keypresses - if it is same as the number of keys, the shortcut function is invoked
			var kp = 0;
			
			//Work around for stupid Shift key bug created by using lowercase - as a result the shift+num combination was broken
			var shift_nums = {
				"`":"~",
				"1":"!",
				"2":"@",
				"3":"#",
				"4":"$",
				"5":"%",
				"6":"^",
				"7":"&",
				"8":"*",
				"9":"(",
				"0":")",
				"-":"_",
				"=":"+",
				";":":",
				"'":"\"",
				",":"<",
				".":">",
				"/":"?",
				"\\":"|"
			}
			//Special Keys - and their codes
			var special_keys = {
				'esc':27,
				'escape':27,
				'tab':9,
				'space':32,
				'return':13,
				'enter':13,
				'backspace':8,
	
				'scrolllock':145,
				'scroll_lock':145,
				'scroll':145,
				'capslock':20,
				'caps_lock':20,
				'caps':20,
				'numlock':144,
				'num_lock':144,
				'num':144,
				
				'pause':19,
				'break':19,
				
				'insert':45,
				'home':36,
				'delete':46,
				'end':35,
				
				'pageup':33,
				'page_up':33,
				'pu':33,
	
				'pagedown':34,
				'page_down':34,
				'pd':34,
	
				'left':37,
				'up':38,
				'right':39,
				'down':40,
	
				'f1':112,
				'f2':113,
				'f3':114,
				'f4':115,
				'f5':116,
				'f6':117,
				'f7':118,
				'f8':119,
				'f9':120,
				'f10':121,
				'f11':122,
				'f12':123
			}
	
			var modifiers = { 
				shift: { wanted:false, pressed:false},
				ctrl : { wanted:false, pressed:false},
				alt  : { wanted:false, pressed:false},
				meta : { wanted:false, pressed:false}	//Meta is Mac specific
			};
                        
			if(e.ctrlKey)	modifiers.ctrl.pressed = true;
			if(e.shiftKey)	modifiers.shift.pressed = true;
			if(e.altKey)	modifiers.alt.pressed = true;
			if(e.metaKey)   modifiers.meta.pressed = true;
                        
			for(var i=0; k=keys[i],i<keys.length; i++) {
				//Modifiers
				if(k == 'ctrl' || k == 'control') {
					kp++;
					modifiers.ctrl.wanted = true;

				} else if(k == 'shift') {
					kp++;
					modifiers.shift.wanted = true;

				} else if(k == 'alt') {
					kp++;
					modifiers.alt.wanted = true;
				} else if(k == 'meta') {
					kp++;
					modifiers.meta.wanted = true;
				} else if(k.length > 1) { //If it is a special key
					if(special_keys[k] == code) kp++;
					
				} else if(opt['keycode']) {
					if(opt['keycode'] == code) kp++;

				} else { //The special keys did not match
					if(character == k) kp++;
					else {
						if(shift_nums[character] && e.shiftKey) { //Stupid Shift key bug created by using lowercase
							character = shift_nums[character]; 
							if(character == k) kp++;
						}
					}
				}
			}
			
			if(kp == keys.length && 
						modifiers.ctrl.pressed == modifiers.ctrl.wanted &&
						modifiers.shift.pressed == modifiers.shift.wanted &&
						modifiers.alt.pressed == modifiers.alt.wanted &&
						modifiers.meta.pressed == modifiers.meta.wanted) {
				callback(e);
	
				if(!opt['propagate']) { //Stop the event
					//e.cancelBubble is supported by IE - this will kill the bubbling process.
					e.cancelBubble = true;
					e.returnValue = false;
	
					//e.stopPropagation works in Firefox.
					if (e.stopPropagation) {
						e.stopPropagation();
						e.preventDefault();
					}
					return false;
				}
			}
		}
		this.all_shortcuts[shortcut_combination] = {
			'callback':func, 
			'target':ele, 
			'event': opt['type']
		};
		//Attach the function with the event
		if(ele.addEventListener) ele.addEventListener(opt['type'], func, false);
		else if(ele.attachEvent) ele.attachEvent('on'+opt['type'], func);
		else ele['on'+opt['type']] = func;
	},

	//Remove the shortcut - just specify the shortcut and I will remove the binding
	'remove':function(shortcut_combination) {
		shortcut_combination = shortcut_combination.toLowerCase();
		var binding = this.all_shortcuts[shortcut_combination];
		delete(this.all_shortcuts[shortcut_combination])
		if(!binding) return;
		var type = binding['event'];
		var ele = binding['target'];
		var callback = binding['callback'];

		if(ele.detachEvent) ele.detachEvent('on'+type, callback);
		else if(ele.removeEventListener) ele.removeEventListener(type, callback, false);
		else ele['on'+type] = false;
	}
}

/* ---- Compressing ./public/javascripts/libraries/webtoolkit.js ----- */
/**
*
*  URL encode / decode
*  http://www.webtoolkit.info/
*
**/

var Url = {

	// public method for url encoding
	encode : function (string) {
		return escape(this._utf8_encode(string));
	},

	// public method for url decoding
	decode : function (string) {
		return this._utf8_decode(unescape(string));
	},

	// private method for UTF-8 encoding
	_utf8_encode : function (string) {
		string = string.replace(/\r\n/g,"\n");
		var utftext = "";

		for (var n = 0; n < string.length; n++) {

			var c = string.charCodeAt(n);

			if (c < 128) {
				utftext += String.fromCharCode(c);
			}
			else if((c > 127) && (c < 2048)) {
				utftext += String.fromCharCode((c >> 6) | 192);
				utftext += String.fromCharCode((c & 63) | 128);
			}
			else {
				utftext += String.fromCharCode((c >> 12) | 224);
				utftext += String.fromCharCode(((c >> 6) & 63) | 128);
				utftext += String.fromCharCode((c & 63) | 128);
			}

		}

		return utftext;
	},

	// private method for UTF-8 decoding
	_utf8_decode : function (utftext) {
		var string = "";
		var i = 0;
		var c = c1 = c2 = 0;

		while ( i < utftext.length ) {

			c = utftext.charCodeAt(i);

			if (c < 128) {
				string += String.fromCharCode(c);
				i++;
			}
			else if((c > 191) && (c < 224)) {
				c2 = utftext.charCodeAt(i+1);
				string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
				i += 2;
			}
			else {
				c2 = utftext.charCodeAt(i+1);
				c3 = utftext.charCodeAt(i+2);
				string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
				i += 3;
			}

		}

		return string;
	}

}

