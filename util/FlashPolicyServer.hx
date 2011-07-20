/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package;

#if nodejs
import js.Node;
#elseif neko
import neko.vm.Thread;
import neko.net.Host;
import neko.net.Socket;
#elseif cpp
import cpp.vm.Thread;
import cpp.net.Host;
import cpp.net.Socket;
#elseif (air&&flash)
import flash.utils.ByteArray;
import flash.events.ProgressEvent;
import flash.events.ServerSocketConnectEvent;
import flash.net.Socket;
import flash.net.ServerSocket;
#elseif (air&&js)
import air.ByteArray;
import air.ProgressEvent;
import air.ServerSocketConnectEvent;
import air.Socket;
import air.ServerSocket;
#end

private typedef AllowedDomain = {
	var domain : String;
	var ports : Array<Int>;
}

/**
	A standalone flash policy server (neko,cpp,nodejs,air).
*/
class FlashPolicyServer {
	
	public static inline var PORT = 843;
	
	public static var domains = new Array<AllowedDomain>;
	public static var allowAll = false;
	
	#if nodejs
	static var s : js.Server;
	#elseif (neko||cpp)
	static var s : Socket;
	#elseif air
	static var s : ServerSocket;
	#end
	
	public static function start( host : String ) {
		#if nodejs
		s = Node.net.createServer( function(s:Stream) {
			s.setEncoding( Node.UTF8 );
			s.addListener( Node.EVENT_STREAM_DATA, function(data:String) {
				if( data.length == 23 && data.substr(0,22) == "<policy-file-request/>" ) {
					s.write( getXml() );
					trace( getXml() );
				}
			});
		});
		s.listen( PORT, host );
		#elseif (neko||cpp)
		var s = new Socket();
		s.bind( new Host( host ), PORT );
		s.listen( 10 );
		var t = Thread.create( runServer );
		t.sendMessage( s );
		#elseif air
		s = new ServerSocket(); 
		s.bind( PORT, host );
		s.addEventListener( ServerSocketConnectEvent.CONNECT, onConnect );
		s.listen();
		#end
	}
	
	public static function stop() {
		s.close();
	}
	
	public static function getXml() : String {
		var t = "<cross-domain-policy>";
		if( allowAll ) t += '<allow-access-from domain="*" to-ports="*"/>';
		else {
			for( d in domains ) {
				var ports = "";
				for( p in d.ports ) ports += p+",";
				ports = ports.substr( 0, ports.length-1 );
				t += '<allow-access-from domain="'+d.domain+'" to-ports="'+ports+'"/>';
			}
		}
		return t+"</cross-domain-policy>"+String.fromCharCode(0);
	}
	
	#if (neko||cpp)
	
	static function runServer() {
		var s : Socket = Thread.readMessage( true );
		while( true ) {
			var c = s.accept();
			var d : String = null;
			try d = c.input.read( 23 ).toString() catch( e : Dynamic ) {
				return;
			}
			if( d.substr( 0, 22 ) == "<policy-file-request/>" ) {
				c.write( getXml() );
			}
			try c.close() catch(e:Dynamic) {}
		}
	}
	
	#elseif air
	
	static function onConnect( e : ServerSocketConnectEvent ) {
		var c = e.socket;
		c.addEventListener( ProgressEvent.SOCKET_DATA, function( e : ProgressEvent ){
			if( e.bytesLoaded != 23 ) {
				try c.close() catch(e:Dynamic) {}
				return;
			}
			var ba = new ByteArray();
			try c.readBytes( ba, 0, e.bytesLoaded ) catch( e : Dynamic ) {
				trace( e );
				try c.close() catch(e:Dynamic) {}
				return;
			}
			if( ba.readUTFBytes( 22 ) != "<policy-file-request/>" ) {
				try c.close() catch(e:Dynamic) {}
				return;
			}
			var t = getXml();
			try {
				c.writeUTFBytes( t );
				c.flush();
				c.close();
			} catch( e : Dynamic ) {}
		});
	}
	
	#end
	
}
