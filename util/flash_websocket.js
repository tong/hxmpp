
// WebSocket glue for flash

var swf;
var ws;

function close() {
	ws.close();
}

function write(t) {
	ws.send(t);
}

function initWebSocket( url ) {
	ws = new WebSocket( url );
	ws.onopen = function(){ swf.onopen() };
	ws.onclose = function(){ swf.onclose() };
	ws.onerror = function(){ swf.onerror() };
	ws.onmessage = function(e){ swf.onmessage(e) };
	return true;
}

var i = 0;
function init(id) {
	swf = document.getElementById( id );
	if( swf.init() ) swf.start();
	else {
		i++;
		if( i > 100 )
			return; // failed to initialize flash
		window.setTimeout( "init", 10 );
	}
}
