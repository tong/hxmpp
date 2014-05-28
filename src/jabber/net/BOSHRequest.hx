/*
 * Copyright (c) disktree.net
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

#if (cpp||neko)

#if cpp
import  cpp.vm.Thread;
#elseif java
import java.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end
import haxe.ds.StringMap;
import haxe.io.Bytes;
import sys.net.Socket;
import sys.net.Host;

using StringTools;

/**
	Non-blocking bosh/http request.
*/
@:require(sys)
class BOSHRequest {

	//static var HTTP_HEADER = ~/HTTP\/1\.1 ([0-9][0-9][0-9]) (.+)/;

//	public static var pending(default,null) : Null<Int>;

	/*
	//TODO we have to close/reopen a socket on stream restart
	static var cachedSockets = new StringMap<Socket>();

	public static function cleanup() {
		for( s in cachedSockets ) {
			try s.close() catch(e:Dynamic) {}
		}
		cachedSockets = new StringMap();
	}
	*/

	public inline function new() {}

	public function request( ip : String, port : Int, path : String, data : String,
							 onData : String->Void, onError : String->Void ) {
		
//		pending = (pending == null) ? 1 : pending+1;
		
		var t = Thread.create( send );
		t.sendMessage( Thread.current() );
		t.sendMessage( ip );
		t.sendMessage( port );
		//t.sendMessage( host );
		t.sendMessage( path );
		t.sendMessage( data );
		t.sendMessage( onData );
		t.sendMessage( onError );
		//var r : String = 
		Thread.readMessage( true );
//		pending--;
	}

	static function send() {

		var main : Thread = Thread.readMessage( true );
		var ip : String = Thread.readMessage( true );
		var port : Int = Thread.readMessage( true );
		//var host : String = Thread.readMessage( true );
		var path : String = Thread.readMessage( true );
		var data : String = Thread.readMessage( true );
		var _onData : String->Void = Thread.readMessage( true );
		var _onError : String->Void = Thread.readMessage( true );

		/*
		var s : Socket = null;
		var sockId = '$ip:$port';
		if( cachedSockets.exists( sockId ) ) {
			s = cachedSockets.get( sockId );
			trace("cACHED socket!!!!!!!! ");
			if( data.indexOf( 'xmpp:restart="true"' ) != -1 ) {
				trace("rESTART");
				try s.close() catch(e:Dynamic) { trace('failed to close socket:'+e); }
				s = new Socket();
				s.connect( new Host( ip ), port );
				cachedSockets.set( sockId, s );
			}
			Sys.sleep(0.1);

		} else {
			s = new Socket();
			s.connect( new Host( ip ), port );
			cachedSockets.set( sockId, s );
		}
		*/

		var s = new Socket();
		s.connect( new Host( ip ), port );

		var out = s.output;
		out.writeString( 'POST $path HTTP/1.1\n' );
		out.writeString( 'Host: $ip\n' );
		out.writeString( 'Content-Length: ${data.length}\n' );
		out.writeString( 'Accept: */*\n' );
		out.writeString( 'Content-Type: application/xml\n' );
		out.writeString( '\n' );
		out.writeString( data );
		out.flush();


//Origin: http://localhost
//User-Agent: HXMPP BOSH client
//Referer: http://localhost/lib/hxmpp/examples/bosh/
//Connection: keep-alive
//Accept-Language: en-US,en;q=0.8
//Accept-Encoding: gzip,deflate,sdch

		var HTTP_HEADER = ~/HTTP\/1\.1 ([0-9][0-9][0-9]) (.+)/;
		var line = s.input.readLine();
		//trace(line);
		if( !HTTP_HEADER.match( line ) ) {
			s.close();
			return;
		}
		var statusCode = Std.parseInt( HTTP_HEADER.matched(1) );
		//trace(statusCode);
		switch statusCode {
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
			_onError( HTTP_HEADER.matched(2) );
		default:
			_onError( HTTP_HEADER.matched(2) );
		}

		try s.close() catch( e : Dynamic ) {
			#if jabber_debug trace(e); #end
		}
		s = null;

		//main.sendMessage( 0 );

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
}

/*
#else

#if js
import js.html.XMLHttpRequest;
#end

class BOSHRequest {

	public dynamic function onData( data : String ) {}
	public dynamic function onError( info : String ) {}

	public function new( host : String, port : Int, path : String ) {
		
		var b = new StringBuf();
		b.add( "http" );
		if( secure ) b.add( "s" );
		b.add( "://" );
		b.add( path );
		this.url = b.toString();
	}

	public function send( data : String ) {

		#if js
		var r = new XMLHttpRequest();
		//TODO if( crossOrigin ) r.withCredentials = true;
		r.open( "POST", path, true );
		r.onreadystatechange = function(e){
			//trace(e+":"+r.readyState);
			if( r.readyState != 4 )
				return;
			var s = r.status;
			if( s != null && s >= 200 && s < 400 )
				onData( r.responseText );
			else
				onError( "http error: "+r.status );
		}
		r.send( data );

		#elseif sys

		var t = Thread

		#end
	}

}

#end
*/

#end
