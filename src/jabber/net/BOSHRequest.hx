/*
 * Copyright (c), disktree
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

import haxe.io.Bytes;
import sys.net.Socket;
import sys.net.Host;
import #if cpp cpp.vm.Thread #elseif neko neko.vm.Thread #end;

using StringTools;

/**
	Non-blocking bosh/http request
	//TODO use a single socket connection to transfer all packets
*/
@:require(cpp||neko)
class BOSHRequest {

	static var pending = 0;

	public inline function new() {}

	/**
	*/
	public function request( host : String, port : Int, path : String, data : String,
							 onData : String->Void, onError : String->Void ) {
		
		pending++;
		var t = Thread.create( _request );
		t.sendMessage( Thread.current() );
		t.sendMessage( host );
		t.sendMessage( port );
		t.sendMessage( path );
		t.sendMessage( data );
		t.sendMessage( onData );
		t.sendMessage( onError );
		//var r : String = 
		Thread.readMessage( true );
		pending--;
	}

	function _request() {
		var main : Thread = Thread.readMessage( true );
		var host : String = Thread.readMessage( true );
		var port : Int = Thread.readMessage( true );
		var path : String = Thread.readMessage( true );
		var data : String = Thread.readMessage( true );
		var _onData : String->Void = Thread.readMessage( true );
		var _onError : String->Void = Thread.readMessage( true );
		//Sys.sleep(1);
		var s = new Socket();
		s.connect( new Host( host ), port );
		var t = 'POST $path HTTP/1.1
Host: $host
Content-Length: ${data.length}
Accept: */*
Content-Type: application/xml

$data';
		//trace(t);
		s.write(t);

//Origin: http://localhost
//User-Agent: HXMPP BOSH client
//Referer: http://localhost/lib/hxmpp/examples/bosh/
//Connection: keep-alive
//Accept-Language: en-US,en;q=0.8
//Accept-Encoding: gzip,deflate,sdch

		var exp = ~/HTTP\/1\.1 ([0-9][0-9][0-9]) (.+)/;
		var line = s.input.readLine();
		//trace(line);
		if( !exp.match( line ) ) {
			s.close();
			return;
		}
		var statusCode = Std.parseInt( exp.matched(1) );
		//trace(statusCode);
		switch( statusCode ) {
		case 200:
			var len : Null<Int> = null;
			while( true ) {
				line = s.input.readLine();
				//trace(line);
				if( line.startsWith( 'Content-Length' ) )
					len = Std.parseInt( line.substr(15).trim() );
				else if( line == '' )
					break;
			}
			var data = Bytes.alloc( len );
			s.input.readBytes( data, 0, len );
			_onData( data.toString() );
		case 404:
			_onError( exp.matched(2) );
		default:
			_onError( exp.matched(2) );
		}
		try s.close() catch( e : Dynamic ) {
			#if jabber_debug trace(e); #end
		}

	//	main.sendMessage( null );

		/*
		var r = new haxe.Http( 'http://localhost/http-bind' );
		r.setHeader( 'Host', 'localhost' );
		r.setHeader( 'Content-type', 'application/xml' );
		r.setHeader( 'Accept', '* /*' );
		r.setHeader( 'Content-Length', Std.string( data.length ) );
		r.setHeader( 'Connection', 'keep-alive' );
		r.setHeader( 'Origin', 'http://localhost' );
		r.setHeader( 'User-Agent', 'hxmpp-neko' );
		r.setHeader( 'Accept-Encoding', 'gzip,deflate,sdch' );
		r.setHeader( 'Accept-Language', 'gen-US,en;q=0.8' );
		//r.onStatus = handleHTTPStatus;
		r.onError = function(e){
			trace(e);
			_onError(e);
		}
		r.onData = function(d){
			trace(d);
			_onData(d); 
		}
		r.setPostData( data );
		r.request( true );
		*/
	}

	public static inline function createRequest( host : String, port : Int, path : String, data : String,
										 		 onData : String->Void, onError : String->Void ) : BOSHRequest {
		var r = new BOSHRequest();
		r.request( host, port, path, data, onData, onError );
		return r;
	}

}
