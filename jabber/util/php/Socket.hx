package jabber.util.php;

import php.net.Host;

/**
	Extended version of php.net.Socket to be able to specify 'tls' as transport for secure connections.
*/
class Socket extends php.net.Socket {

	public override function connect( host : Host, port : Int ) {
		var errs = null;
		var errn = null;
		var r = untyped __call__( 'stream_socket_client', 'tls://'+host._ip+':'+port, errn, errs );
		php.net.Socket.checkError( r, errn, errs );
		__s = cast r;
		assignHandler();
	}
	
}
