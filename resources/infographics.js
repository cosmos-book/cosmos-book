function r(f){/in/.test(document.readyState)?setTimeout('r('+f+')',9):f()}

// Defaults for infographics examples
var h = 1250;
var w = 1909;
var mid = {'x': w/2,'y':h/2};
var files_to_load = 0;

var colours = {
	'red': ['#f04031','#f05948','#f68d69','#f9aa8f','#fee7dd'],
	'orange': ['#f6881f','#f9a04a','#fbb675','#fdcc9c','#ffe6d4'],
	'yellow': ['#ffcb06','#ffde00','#fff200','#fff79a','#fffcd5'],
	'yellowgreen': ['#b6c727','#cbd658','#dce57d','#e8eeae','#f2f6d5'],
	'green': ['#02a24b','#0ab26b','#67c18d','#9bd4ae','#e4f2e7'],
	'turquoise': ['#57b7aa','#89d0c8','#a8dbd5','#c5e6e1','#e3f3f2'],
	'other':['#5cb6ac','#83c4bb','','','#eaf5f5'],
	'blue': ['#00a2d3','#00b9e4','#48c7e9','#8fd7ed','#e1f4fe'],
	'lilac': ['#4f4c9a','#6e69b0','#8a84bf','#aaa5d1','#e8e7f2'],
	'purple': ['#662d8f','#7c52a1','#7d71b4','#af99c8','#e9e2ef'],
	'rose': ['#b72268','#c2567e','#cd7d94','#dba4b3','#f3e5e9'],
	'success':'#f04031',
	'fail':'#ffcb06'
}

// Make a donut/ring shape
// x,y = centre coordinates
// r = radius of inner circle
// R = radius of outer circle
function donut(x, y, r, R) {
	var y1 = y+R;
	var y2 = y+r;
	var path = 'M'+x+' '+y1+ 'A'+R+' '+R+' 0 1 1 '+(x+0.001)+' '+y1; // Outer circle
	path += 'M'+x+' '+y2+ 'A'+r+' '+r+' 0 1 0 '+(x-0.001)+' '+y2;    // Inner Circle
	return path;
};

// Some useful functions
function scaleCanvas(s){
	h *= s;
	w *= s;
	mid.x *= s;
	mid.y *= s;
}
function loadFILE(file,fn,attrs,t){

	if(!attrs) attrs = {};
	attrs['_file'] = file;
	console.log('loadFile',t);
	$.ajax({
		type: "GET",
		url: file,
		dataType: t,
		success: function(data) {
			files_to_load++;
			if(typeof fn==="function") fn.call((attrs['this'] ? attrs['this'] : this),data,attrs);
		},
		error: function (request, status, error) {
			console.log('error loading '+file)
			console.log(request.responseText);
			if(typeof attrs.error==="function") attrs.error.call((attrs['this'] ? attrs['this'] : this),data,attrs);
		}
	});
}

function loadJSON(file,fn,attrs,t){
	if(!attrs) attrs = {};
	fetch(file,{})
	.then(response => response.json())
	.then(data => {
		if(typeof fn==="function"){
			fn.call(attrs['this']||this,data,attrs);
		}
	});
	//loadFILE(file,fn,attrs,"json");
}
function loadCSV(file,fn,attrs,t){ loadFILE(file,fn,attrs,"text"); }
function loadDAT(file,fn,attrs,t){ loadFILE(file,fn,attrs,"text"); }

function Fixed2JSON(data,format,start){

	if(typeof start!=="number") start = 1;

	if(typeof data==="string") data = data.split(/[\n\r]/);

	var newdata = new Array();
	var tmp = "";

	// Work out the format of each field
	for(var f = 0; f < format.length; f++){
		if(format[f].format){
			format[f].typ = format[f].format[0];
			format[f].len = parseFloat(format[f].format.substr(1));
		}
	}

	// Parse each line
	for(var i = start; i < data.length; i++){
		datum = {};
		idx = 0;
		for(var j = 0; j < format.length; j++){
			if(format[j]){
				tmp = data[i].substr(idx,parseInt(format[j].len))

				if(format[j].typ=="F"){
					if(tmp=="infinity" || tmp=="Inf") datum[format[j].name] = Number.POSITIVE_INFINITY;
					else datum[format[j].name] = parseFloat(tmp.replace(/[^0-9\+\-\.Ee]/,""));
				}else if(format[j].typ=="I"){
					if(tmp=="infinity" || tmp=="Inf") datum[format[j].name] = Number.POSITIVE_INFINITY;
					else datum[format[j].name] = parseInt(tmp.replace(/ /,""));
				}else if(format[j].format=="D"){
					datum[format[j].name] = new Date(tmp);
				}else if(format[j].format=="B"){
					if(tmp=="1" || tmp=="true" || tmp=="Y") datum[format[j].name] = true;
					else if(tmp=="0" || tmp=="false" || tmp=="N") datum[format[j].name] = false;
					else datum[format[j].name] = null;
				}else{
					datum[format[j].name] = (tmp[0]=='"' && tmp[tmp.length-1]=='"') ? tmp.substring(1,tmp.length-1) : tmp;
					datum[format[j].name] = datum[format[j].name].replace(/ +$/,'');	// Remove trailing spaces
				}
				idx += parseInt(format[j].len);
			}else datum[j] = null;
		}
		newdata.push(datum);
	}

	return newdata;
}

function CSV2JSON(data,format,start,end){

	if(typeof start!=="number") start = 1;
	var delim = ",";

	if(typeof data==="string"){
		data = data.replace(/\r/,'');
		data = data.split(/[\n]/);
	}
	if(typeof end!=="number") end = data.length;

	if(data[0].indexOf("\t") > 0) delim = /\t/;

	var line,datum;
	var newdata = new Array();
	for(var i = start; i < end; i++){
		line = data[i].split(delim);
		datum = {};
		for(var j=0; j < line.length; j++){
			if(format[j]){
				line[j] = line[j].replace(/(^\"|\"$)/g,"");
				if(format[j].format=="number"){
					if(line[j]!=""){
						if(line[j]=="infinity" || line[j]=="Inf") datum[format[j].name] = Number.POSITIVE_INFINITY;
						else datum[format[j].name] = parseFloat(line[j]);
					}
				}else if(format[j].format=="eval"){
					if(line[j]!="") datum[format[j].name] = eval(line[j]);
				}else if(format[j].format=="date"){
					if(line[j]) datum[format[j].name] = new Date(line[j].replace(/^"/,"").replace(/"$/,""));
					else datum[format[j].name] = null;
				}else if(format[j].format=="boolean"){
					if(line[j]=="1" || line[j]=="true" || line[j]=="Y") datum[format[j].name] = true;
					else if(line[j]=="0" || line[j]=="false" || line[j]=="N") datum[format[j].name] = false;
					else datum[format[j].name] = null;
				}else{
					datum[format[j].name] = (line[j][0]=='"' && line[j][line[j].length-1]=='"') ? line[j].substring(1,line[j].length-1) : line[j];
				}
			}else{
				datum[j] = (line[j][0]=='"' && line[j][line[j].length-1]=='"') ? line[j].substring(1,line[j].length-1) : line[j];
			}
		}
		newdata.push(datum);
	}
	return newdata;
}


function capitaliseFirstLetter(string){
	return string.charAt(0).toUpperCase() + string.slice(1);
}
function parseHTML(txt){
	var div = document.createElement("div");
	div.innerHTML = txt;
	return div.innerHTML;
}
function savesvg(n){
	var canvas_ = document.getElementById((typeof n==="string" ? n : "canvas"));
	var text = (new XMLSerializer()).serializeToString(canvas_);
	var encodedText = encodeURIComponent(text);
	open("data:image/svg+xml," + encodedText);
}


// Add commas every 10^3
function addCommas(nStr) {
	nStr += '';
	var x = nStr.split('.');
	var x1 = x[0];
	var x2 = x.length > 1 ? '.' + x[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + ',' + '$2');
	}
	return x1 + x2;
}

// Get the URL query string and parse it
function queryString() {
	var p = {length:0};
	var q = location.search;
	var val,key,bits;
	if(q && q != '#'){
		// remove the leading ? and trailing &
		q = q.replace(/^\?/,'').replace(/\&$/,'');
		bits = q.split('&');
		for(var i = 0; i < bits.length; i++){
			key = bits[i].split('=')[0];
			val = bits[i].split('=')[1];
			// convert floats
			if(/^-?[0-9.]+$/.test(val)) val = parseFloat(val);
			if(val == "true") val = true;
			if(val == "false") val = false;
			if(/^\?[0-9\.]+$/.test(val)) val = parseFloat(val);	// convert floats
			if(!p[key]){
				p.length++;
				if(typeof val==="string") val = val.replace(/%20/,' ')
				p[key] = val;
			}else{
				if(typeof p[key]==="string"){
					var old = p[key];
					p[key] = new Array();
					p[key].push(old);
				}
				p[key].push(val);
			}
		}
	}
	return p;
};

// Function to update the history
// qs = query string
// fn = call back function
function addHistory(qs,fn,a){
	if(!!(window.history && history.pushState)){
		history.pushState({},"Guide","?"+qs);
	}
	if(typeof fn==="function") fn.call(this,a)
}

// Make a tooltip providing the selector and a callback function to add content
// tooltip({
//     'elements':$('.selector'),
//     'html':function(){}
// )
function tooltip(data){

	var existinghtml = "";

	function show(el,text){


		if(!text) return;
		var l = parseInt($(el).offset().left);
		var t = parseInt($(el).offset().top);
		var dx = ($(el).attr('r')) ? $(el).attr('r')*2 : ($(el).attr('d') ? Raphael.pathBBox($(el).attr('d')).width : parseInt($(el).outerWidth()));
		var dy = ($(el).attr('r')) ? $(el).attr('r')*2 : ($(el).attr('d') ? Raphael.pathBBox($(el).attr('d')).height : parseInt($(el).outerHeight()));
		var inner = ($('.innerbox').length==1) ? $('.innerbox') : ($('#content').length==1 ? $('#content') : $('#holder'));

		if($('.tooltip').length == 0){
			$('body').append('<div class="tooltip"><div class="tooltip_padd"><div class="tooltip_inner">'+text+'<\/div><a href="" class="tooltip_close button">close</a><\/div><\/div>');
			$('.tooltip_close').on('click',function(e){ e.preventDefault(); e.stopPropagation(); closeTooltip(); });
		}else $('.tooltip_inner').html(text);

		var fs = parseInt($('.tooltip').css('font-size'));
		var x = l+dx;
		var y = t+dy/2;
		var c = "right";

		if(x+$('.tooltip').width()+fs*2 > inner.width()){
			x = l-$('.tooltip').width();
			if(x < 0) x = 0;
			c = "left";
		}
		if(y+$('.tooltip').height()+fs*2 > inner.offset().top+inner.height()){
			y = t-$('.tooltip').height()+dy/2;
			if(y < 0) y = 0;
			c += " bottom";
		}
		$('.tooltip').css({'left':x,'top':y}).removeClass('right').removeClass('left').removeClass('bottom').addClass(c);

	}
	function closeTooltip(){
		existinghtml = "";
		$('.tooltip').remove();
		$('body').removeClass('hastooltip');
	}

	var event = 'click' || data.event;
	data.elements.on(event,{data:data},function(e){
		e.preventDefault();
		e.stopPropagation();

		var newhtml = e.data.data.html.call(this,{data:data});
		if(newhtml!=existinghtml){
			show(this,newhtml);
			$('body').addClass('hastooltip');
			existinghtml = newhtml;
		}else{
			if($('.tooltip').is(':visible')){
				$('.tooltip_close').trigger('click');
				existinghtml = "";
			}
		}
		if(typeof e.data.data.added==="function") e.data.data.added.call(this,{data:data});
	})
}

// Function to get the relative path of the data file
function getDataPath(el){
	var url = "";
	if($(el).attr('data')){
		url = $(el).attr('data');
	}else if($(el).attr('href')){
		if($(el).attr('href').indexOf('blob/master/') > 0){
			url = $(el).attr('href').substr($(el).attr('href').indexOf('blob/master/')+12)
		}else{
			url = $(el).attr('href');
		}
	}
	if(location.href.indexOf('cosmos-book.github.io') > 0){
		var path = location.href.substring(location.href.indexOf('cosmos-book.github.io')+22,location.href.lastIndexOf('/')+1);
		if(url.lastIndexOf(path)>=0) url = url.substr(url.lastIndexOf(path)+path.length);
	}
	return url;
}

function Toggler(toggles){
	this.toggles = (toggles && toggles.toggles ? toggles.toggles : {});
	this.callback = (toggles && typeof toggles.click==="function" ? toggles.click : '');

	return this;
}

Toggler.prototype.val = function(id){
	return $('input[name='+id+']:checked').val();
}

// Build a toggle button
// Inputs
//   el       = jQuery element to add this to (it should have a length==1)
//   id       = The unique ID to use
//   toggle.a = { "value": "a", "id": "uniqueid_a", "checked": true, "label": "Left label" }
//   toggle.b = { "value": "b", "id": "uniqueid_b", "checked": false, "label": "Right label" }
Toggler.prototype.create = function(el,id,toggles){

	if(!el || el.length !=1 || typeof el.append!=="function") return this;
	if(!toggles || !toggles['on'] || !toggles['off']) return this;
	if((typeof id!=="string") && (typeof toggles[0]!=="object") && (typeof toggles[1]!=="object")) return this;
	// Remove any existing version of this toggle
	el.find('toggler').remove();

	if(!toggles['off'].id) toggles['off'].id = id+'_off';
	if(!toggles['on'].id) toggles['on'].id = id+'_on';

	this.toggles[id] = { 'html':'', 'states':{}};
	this.toggles[id].states = toggles;

	var lc = '<label class="toggle-label';
	var html = "";
	html = '<form><div class="toggleinput toggler'+(toggles['off'].checked ? '' : ' checked')+'">'+lc+'1" for="'+toggles['off'].id+'">'+(toggles['off'].label ? toggles['off'].label : '')+'</label>';
	html += '<div class="toggle-bg">';
	html += '	<input id="'+toggles['off'].id+'" type="radio" '+(toggles['off'].checked ? 'checked="checked" ' : '')+'name="'+id+'" value="off">';
	html += '	<input id="'+toggles['on'].id+'" type="radio" '+(toggles['on'].checked ? 'checked="checked" ' : '')+'name="'+id+'" value="on">';
	html += '	<span class="switch"></span>';
	html += '</div>';
	html += ''+lc+'2" for="'+toggles['on'].id+'">'+(toggles['on'].label ? toggles['on'].label : '')+'</label></div></form>';

	this.toggles[id].html = html;

	el.append(html);

	var _obj = this;

	el.on('click','.toggler',{id:id,me:this},function(e){
		var input = $(this).find('input:checked');
		if(input.attr('value')=="on"){
			$(this).addClass('checked');
			e.data.me.toggles[e.data.id].states['on'].checked = true;
			e.data.me.toggles[e.data.id].states['off'].checked = false;
		}else{
			$(this).removeClass('checked');
			e.data.me.toggles[e.data.id].states['on'].checked = false;
			e.data.me.toggles[e.data.id].states['off'].checked = true;
		}
		if(typeof _obj.callback==="function") _obj.callback.call();
	});

	return this;
}

Toggler.prototype.toggle = function(id){
	var t = this.toggles[id];
	if(!t) return this;
	if(t.states['off'].checked) $('#'+t.states['on'].id).trigger('click').closest('.toggler').trigger('click');
	else $('#'+t.states['off'].id).trigger('click').closest('.toggler').trigger('click');
	return this;
}

Toggler.prototype.change = function(id,v){
	var t = this.toggles[id];
	if(!t) return this;
	if(v=='on' && $('#'+t.states['on'].id).length>0) $('#'+t.states['on'].id).trigger('click').closest('.toggler').trigger('click');
	if(v=='off' && $('#'+t.states['off'].id).length>0) $('#'+t.states['off'].id).trigger('click').closest('.toggler').trigger('click');
	return this;
}

// Make a log10 function if it doesn't exist
if(!Math.log10 || typeof Math.log10!=="function"){ Math.log10 = function(v) { return Math.log(v)/2.302585092994046; }; }
