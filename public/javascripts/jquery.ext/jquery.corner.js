// JRC (jquery-round-corners)
// www.meerbox.nl
		
(function($){
	
	var Num = function(i) { return parseInt(i,10) || 0; };
		
	// get lowest number from array
	var asNum = function(a, b) { return a-b; };
	var getMin = function(a) {
		var b = a.concat();
		return b.sort(asNum)[0];
	};
	
	// get CSS value as integer
	var getBorderWidth = function(elm,p) {
		var w = elm.css('border'+p+'Width');
		if ($.browser.msie) {
			if (w == 'thin') w = 2;
			if (w == 'medium' && !(elm.css('border'+p+'Style') == 'none')) w = 4;
			if (w == 'thick') w = 6;
		}
		return Num(w);
	};
	
	var rotationSteps = function(r_type,a,b,c,d) {
		if (r_type == 'tl') return a;
		if (r_type == 'tr') return b;
		if (r_type == 'bl') return c;
		if (r_type == 'br') return d;
	};
	
	// draw the round corner in Canvas object
	var drawCorner = function(canvas,radius,r_type,bg_color,border_width,border_color,corner_effect) {
		
		var steps,curve_to;
		
		// change rgba(1,2,3,0.9) to rgb(1,2,3)
		var reg = /^rgba\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)$/;   
		var bits = reg.exec(bg_color);
		if (bits) {
			var channels = [Num(bits[1]),Num(bits[2]),Num(bits[3])];
			bg_color = 'rgb('+channels[0]+', '+channels[1]+', '+channels[2]+')';
		} 
	
		border_width = Num(border_width);
		
		var ctx = canvas.getContext('2d');
		
		if (radius == 1 || corner_effect == 'notch') {
			
			if (border_width > 0 && radius > 1) {
				ctx.fillStyle = border_color;
				ctx.fillRect(0,0,radius,radius);
				ctx.fillStyle = bg_color;
				steps = rotationSteps(r_type,[0-border_width,0-border_width],[border_width,0-border_width],[0-border_width,border_width],[border_width,border_width]);
				ctx.fillRect(steps[0],steps[1],radius,radius);
			} else {
				ctx.fillStyle = bg_color;
				ctx.fillRect(0,0,radius,radius);
			}
			return canvas;
		} else if (corner_effect == 'bevel') {
			steps = rotationSteps(r_type,[0,0,0,radius,radius,0,0,0],[0,0,radius,radius,radius,0,0,0],[0,0,radius,radius,0,radius,0,0],[radius,radius,radius,0,0,radius,radius,radius]);
			ctx.fillStyle = bg_color;
			ctx.beginPath();
			ctx.moveTo(steps[0],steps[1]);
			ctx.lineTo(steps[2], steps[3]);
			ctx.lineTo(steps[4], steps[5]);
			ctx.lineTo(steps[6], steps[7]);
			ctx.fill(); 
			if (border_width > 0 && border_width < radius) {
				ctx.strokeStyle = border_color;
	        	ctx.lineWidth = border_width;
    			ctx.beginPath();
				steps = rotationSteps(r_type,[0,radius,radius,0],[0,0,radius,radius],[radius,radius,0,0],[0,radius,radius,0]);
    			ctx.moveTo(steps[0],steps[1]);
				ctx.lineTo(steps[2],steps[3]);
    			ctx.stroke();
			}
			return canvas;
		}

		steps = rotationSteps(r_type,
					[0,0,radius,0,radius,0,0,radius,0,0],
					[radius,0,radius,radius,radius,0,0,0,0,0],
					[0,radius,radius,radius,0,radius,0,0,0,radius],
					[radius,radius,radius,0,radius,0,0,radius,radius,radius]);
         
		ctx.fillStyle = bg_color;
    	ctx.beginPath();
     	ctx.moveTo(steps[0],steps[1]); 
     	ctx.lineTo(steps[2], steps[3]);
    	if(r_type == 'br') ctx.bezierCurveTo(steps[4], steps[5], radius, radius, steps[6], steps[7]);
    	else ctx.bezierCurveTo(steps[4], steps[5], 0, 0, steps[6], steps[7]);
		ctx.lineTo(steps[8], steps[9]);
        ctx.fill(); 
         
        // draw border
        if (border_width > 0 && border_width < radius) {
	        
	        // offset caused by border
	        var offset = border_width/2; 
	        
			steps = rotationSteps(r_type,
				[radius-offset,offset,radius-offset,offset,offset,radius-offset],
				[radius-offset,radius-offset,radius-offset,offset,offset,offset],
				[radius-offset,radius-offset,offset,radius-offset,offset,offset,offset,radius-offset],
				[radius-offset,offset,radius-offset,offset,offset,radius-offset,radius-offset,radius-offset]	
			);

			curve_to = rotationSteps(r_type,[0,0],[0,0],[0,0],[radius, radius]);

	        ctx.strokeStyle = border_color;
	        ctx.lineWidth = border_width;
    		ctx.beginPath();
    		// go to corner to begin curve
     		ctx.moveTo(steps[0], steps[1]); 
     		// curve from righttop to leftbottom (for the tl canvas)
    		ctx.bezierCurveTo(steps[2], steps[3], curve_to[0], curve_to[1], steps[4], steps[5]); 
			ctx.stroke();
	        
	    }
	    
	    return canvas;
	    
	};
	
	// create and append canvas element to parent
	var createCanvas = function(p,radius) {
		
		var elm = document.createElement('canvas');
		elm.setAttribute("height", radius);
		elm.setAttribute("width", radius); 
	    elm.style.display = "block";
		elm.style.position = "absolute";
		elm.className = "jrCorner";
		
		appendToParent(p,elm);
		
		if (!can_sp) { // no native canvas support
			if (typeof G_vmlCanvasManager == "object") { // use excanvas
				elm = G_vmlCanvasManager.initElement(elm);
			} else if (typeof G_vmlCMjrc == "object") { // use the stipped down version of excanvas
				elm = G_vmlCMjrc.i(elm);
			} else {
				 throw Error('Could not find excanvas');
			}
		}
		return elm;
	};
	
	var appendToParent = function(p,elm) {
		if (p.is("table")) {
			p.children("tbody").children("tr:first").children("td:first").append(elm); 
			p.css('display','block'); // only firefox seems to need this
		} else if(p.is("td")) {
			if (p.children(".JrcTdContainer").length === 0) {
				// only is msie you can absolute position a element inside a table cell, so we need a wrapper
				p.html('<div class="JrcTdContainer" style="padding:0px;position:relative;margin:-1px;zoom:1;">'+p.html()+'</div>');
				p.css('zoom','1');
				if ($.browser.msie && typeof document.body.style.maxHeight == "undefined") { //  msie6 only
					p.children(".JrcTdContainer").get(0).style.setExpression("height","this.parentNode.offsetHeight"); 
				}
				
			} 
			p.children(".JrcTdContainer").append(elm); 
			
		} else {
			p.append(elm); 
		}

	};
	
	var can_sp = typeof document.createElement('canvas').getContext == "function";
	
	var _corner = function(options) {
		
		if (options == "destroy") {
			return this.each(function() {
				var p, elm = $(this);
				if (elm.is(".jrcRounded")) {
					if (elm.is("table")) p = elm.children("tbody").children("tr:first").children("td:first");
					else if (elm.is("td")) p = elm.children(".JrcTdContainer");
					else p = elm;
					p.children(".jrCorner").remove();
					elm.unbind('mouseleave.jrc').unbind('mouseenter.jrc').removeClass('jrcRounded');
					if (elm.is("td")) elm.html(elm.children(".JrcTdContainer").html());
				}
			});
		}
	
		// nothing to do, so return || no msie or native canvas support
		if (this.length==0 || !(can_sp || $.browser.msie)) {
			return this;
		}
			
		// interpret the (string) argument
   		var o = (options || "").toLowerCase();
   		var radius = Num((o.match(/(\d+)px/)||[])[1]) || "auto"; // corner width
   		var bg_arg = ((o.match(/(#[0-9a-f]+)/)||[])[1]) || "auto";  // strip color
   		var re = /round|bevel|notch|bite|cool|sharp|slide|jut|curl|tear|fray|wicked|sculpt|long|dog3|dog2|dog/; // Corner Effects
    	var fx = ((o.match(re)||['round'])[0]);
    	var hover = /hover/.test(o);
    	var hiddenparent_arg = o.match("hiddenparent");
    	
   		var edges = { T:0, B:1 };
    	var opts = {
        	tl:  /top|tl/.test(o),       
        	tr:  /top|tr/.test(o),
        	bl:  /bottom|bl/.test(o),    
        	br:  /bottom|br/.test(o)
    	};
    	
    	if ( !opts.tl && !opts.tr && !opts.bl && !opts.br) opts = { tl:1, tr:1, bl:1, br:1 };
    	
    	// some stuff needed for the callback function
       	var arl = this.length;
       	var argl = arguments.length;
       	var cb = arguments[1];
       	var al = this;
       	
		return this.each(function(ll) {

			var elm = $(this),rbg=null,bg,s,b,pr;
					
			// no background color of the parent is set ...
			if (bg_arg == "auto") { 
				s = elm.siblings(".jrcRounded:eq(0)");
				if (s.length > 0) { // sibling already has the real background color stored?
					b = s.data("rbg.jrc");
					if (typeof b == "string") {
						rbg = b;
					}
				}
			}
			
			if (hiddenparent_arg || rbg === null) {
				
				// temporary show hidden parent (wm.morgun) + search for background color
				var current_p = elm.parent(), hidden_parents = new Array(),a = 0;
				while( (typeof current_p == 'object') && !current_p.is("html")) {
					
					if (hiddenparent_arg && current_p.css('display') == 'none') {
						hidden_parents.push({
							originalcss: {display: current_p.css('display'), visibility: current_p.css('visibility')},
							elm: current_p
						});
						current_p.css({display: 'block', visibility: 'hidden'});
					}
					
					if (rbg === null && current_p.css('background-color') != "transparent" && current_p.css('background-color') != "rgba(0, 0, 0, 0)") {
						rbg = current_p.css('background-color');
					}
					
					current_p = current_p.parent();
	
				}
				
				if (rbg === null) rbg = "#ffffff";
			}
			
			// store the parent background color
			if (bg_arg == "auto") {
				bg = rbg;
				elm.data("rbg.jrc",rbg);
			} else {
				bg = bg_arg;
			}
			
			// hover (optional argument - for a alterative to #roundedelement:hover)
			if (hover) {
				
				var new_options = options.replace(/hover/i, "");
				
				elm.bind("mouseenter.jrc", function(){
					elm.addClass('jrcHover');
					elm.corner(new_options);
				});
				elm.bind("mouseleave.jrc", function(){
					elm.removeClass('jrcHover');
					elm.corner(new_options);
				});
				
			}
			
	   		// msie6 rendering bugs :(
			if ($.browser.msie && typeof document.body.style.maxHeight == "undefined") {
				if (elm.css('display') == 'inline') { elm.css('zoom','1'); }
				if (elm.css('height') == 'auto') {elm.height(elm.height());}
			 	if (elm.width()%2 != 0) { elm.width(elm.width()+1); }
			 	if (elm.height()%2 != 0) { elm.height(elm.height()+1); }
			 	if (elm.css('lineHeight') != 'normal' && elm.height() < elm.css('lineHeight')) {
				 	elm.css('lineHeight', elm.height());
				}
				if (elm.css('lineHeight') == 'normal' && elm.css('display') != 'inline') elm.css('lineHeight','1'); // dont ask
			}
			
			// if element is hidden we cant get the size..
			if (elm.css('display') == 'none') {
				var originalvisibility = elm.css('visibility');
				elm.css({display: 'block', visibility: 'hidden'});
				var ishidden = true;
			} else {
				var ishiddden = false;
			}
			
			// get height/width
			var arr = [elm.get(0).offsetHeight,elm.get(0).offsetWidth];
			if (elm.height() != 0) arr[arr.length] = elm.height();
			if (elm.width() != 0) arr[arr.length] = elm.width();
			var widthheight_smallest = getMin(arr);

			// restore css
			if (ishidden) elm.css({display:'none',visibility:originalvisibility});
			
			//  restore css of hidden parents
			if (typeof hidden_parents != "undefined") {
				for (var i = 0; i < hidden_parents.length; i++) {
					hidden_parents[i].elm.css(hidden_parents[i].originalcss);
				}
			}
			
			// the size of the corner is not defined...
			if (radius == "auto") {
				radius = widthheight_smallest/2;
				if (radius > 10) radius = 10; 
			}

			// the size of the corner can't be to high
			if (radius > widthheight_smallest/2) radius = widthheight_smallest/2;
			
			radius = Math.floor(radius);
			
			// some css thats required in order to position the canvas elements
			if (elm.css('position') == 'static' && !elm.is("td")) { 
				elm.css('position','relative'); 
			// only needed for ie6 and (ie7 in Quirks mode) , CSS1Compat == Strict mode
			} else if (elm.css('position') == 'fixed' && $.browser.msie && !(document.compatMode == 'CSS1Compat' && typeof document.body.style.maxHeight != "undefined")) { 
				elm.css('position','absolute');
			}
			elm.css('overflow','visible'); // not always need (for example when rounded element has no border, but also in some other cases)
			
			// get border width
			var border_t = getBorderWidth(elm, 'Top');
			var border_r = getBorderWidth(elm, 'Right');
			var border_b = getBorderWidth(elm, 'Bottom');
			var border_l = getBorderWidth(elm, 'Left');
			
			// get the lowest borderwidth of the corners in use
			var bordersWidth = new Array();
			if (opts.tl || opts.tr) bordersWidth.push(border_t);
			if (opts.br || opts.tr) bordersWidth.push(border_r);
			if (opts.br || opts.bl) bordersWidth.push(border_b);
			if (opts.bl || opts.tl) bordersWidth.push(border_l);
			
			var borderswidth_smallest = getMin(bordersWidth);
			
			var p_top = 0-border_t;
			var p_right = 0-border_r;
			var p_bottom = 0-border_b;
			var p_left = 0-border_l;
			
			// pr is the parent of where the canvas elements are placed
			if (elm.is("table")) pr = elm.children("tbody").children("tr:first").children("td:first");
			else if (elm.is("td")) pr = elm.children(".JrcTdContainer");
			else pr = elm;
	
			// draw Corners in canvas elements (createCanvas also appends it to parent)
			if (opts.tl) { 
				pr.children(".jrcTL").remove();
				var tl = drawCorner(createCanvas(elm,radius),radius,'tl',bg,borderswidth_smallest,elm.css('borderTopColor'),fx); 
				$(tl).css({left:p_left,top:p_top}).addClass('jrcTL');
			}
			if (opts.tr) { 
				pr.children(".jrcTR").remove();
				var tr = drawCorner(createCanvas(elm,radius),radius,'tr',bg,borderswidth_smallest,elm.css('borderTopColor'),fx); 
				$(tr).css({right:p_right,top:p_top}).addClass('jrcTR'); 
			}
			if (opts.bl) { 
				pr.children(".jrcBL").remove();
				var bl = drawCorner(createCanvas(elm,radius),radius,'bl',bg,borderswidth_smallest,elm.css('borderBottomColor'),fx);
				$(bl).css({left:p_left,bottom:p_bottom}).addClass('jrcBL');  
			}
			if (opts.br) { 
				pr.children(".jrcBR").remove();
				var br = drawCorner(createCanvas(elm,radius),radius,'br',bg,borderswidth_smallest,elm.css('borderBottomColor'),fx); 
				$(br).css({right:p_right,bottom:p_bottom}).addClass('jrcBR');
			}
			
			elm.addClass('jrcRounded');
			
			// callback function (is called when the last element is rounded)
			if (ll === arl-1 && argl == 2 && typeof cb == "function") cb(al); 
				
   		});  
	};
	
	$.fn.corner = _corner;
	
})(jQuery);
