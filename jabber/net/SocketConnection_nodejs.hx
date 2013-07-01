/*
 * Copyright (c), disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber.net;

#if (js&&nodejs)

import js.Node;
import haxe.io.Bytes;

class SocketConnection_nodejs extends SocketConnectionBase_js {

	public var bufSize(default,null) : Int;
	public var maxBufSize(default,null) : Int;
	public var timeout(default,null) : Int;
	//public var credentials : NodeCredDetails;

	//var cleartext : Dynamic;

	public function new( host : String = "localhost", port : Int = 5222, secure : Bool = false,
						 ?bufSize : Int, ?maxBufSize : Int, timeout : Int = 10 ) {
		super( host, secure );
		this.port = port;
		this.bufSize = bufSize;
		this.maxBufSize = maxBufSize;
		this.timeout = timeout;
	}

	public override function connect() {
		createConnection();
		socket.on( NodeC.EVENT_STREAM_END, handleClose );
		socket.on( NodeC.EVENT_STREAM_ERROR, handleError );
		socket.on( NodeC.EVENT_STREAM_DATA, handleData ); // here? not in read ?
	}

	public override function disconnect() {
		try socket.end() catch( e : Dynamic ) {
			onDisconnect( e );
		}
	}

	public override function setSecure() {
		//TODO 'setSecure' got removed from nodejs 0.4+
		trace("_____SET SECURE__________TODO");
		/*
		socket.removeAllListeners( 'data' );
		socket.removeAllListeners( 'drain' );
		socket.removeAllListeners( 'close' );
		socket.on( 'secureConnect', function(){ trace("SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"); } );
		
		if( credentials == null ) credentials = cast {};
		trace(".......");
		var ctx = jabber.util.StartTLS.run( socket, credentials, true, function() {
			trace(">>>>>>>>>>>>>");
		});
		*/
		//secured = true;
		//__onSecured( null );
		// hmm? TypeError: Object #<a Stream> has no method 'setSecure' ??????????
		//socket.on( Node.STREAM_SECURE, sockSecureHandler );
		//trace( socket.getPeerCertificate() );
		//socket.setSecure(  );
	}

	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.write( t );
		return true;
	}

	public override function writeBytes( t : Bytes ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.write( t.getData() ); 
		return true;
	}

	public override function read( ?yes : Bool = true ) : Bool {
		if( !yes )
			socket.removeListener( NodeC.EVENT_STREAM_DATA, handleData );
		return true;
	}

	function createConnection() {
		//if( credentials == null ) credentials = cast {};
		//socket = Node.tls.connect( port, host, credentials, sockConnectHandler );
		//socket = Node.net.connect( port, host, sockConnectHandler );
		socket = Node.net.connect( port, host );
		socket.setEncoding( NodeC.UTF8 );
		socket.on( NodeC.EVENT_STREAM_CONNECT, handleConnect );
		/*
		socket = Node.net.createConnection( port, host );
		socket.setEncoding( Node.UTF8 );
		//socket = Node.tls.connect( port, host, null, sockConnectHandler );
		socket.on( Node.STREAM_CONNECT, sockConnectHandler );
		*/
	}

	/*
	function handleConnect() {
		connected = true;
		onConnect();
	}

	function handleClose() {
		connected = false;
		onDisconnect(null);
	}
	*/

	function handleError( e : String ) {
		connected = false;
		onDisconnect( e );
	}

	/*
	function handleSecure() {
		secured = true;
		onSecured( null );
	}
	*/

	function handleData( t : String ) {
		/*
		var s = buf+t;
		if( s.length > maxBufSize )
			throw "max socket buffer size reached ["+maxBufSize+"]";
		var r = __onData( Bytes.ofString( s ), 0, s.length );
		buf = ( r == 0 ) ? s : "";
		*/
		onString( t );
	}

}

#end
