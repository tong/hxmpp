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

import chrome.Socket;
import haxe.io.Bytes;
import jabber.util.ArrayBufferUtil;

/**
	Google chrome socket connection.
*/
class SocketConnection_cra extends jabber.StreamConnection {
	
	public var port(default,null) : Int;
	public var socketId(default,null): Int;
	
	public function new( host : String = "localhost", port : Int = 5222 ) {
		super( host, false );
		this.port = port;
	}
	
	public override function connect() {
		Socket.create( 'tcp', null, function(i){
			if( i.socketId > 0 ) {
				socketId = i.socketId;
				Socket.connect( i.socketId, host, port, handleConnect );
			} else {
				__onDisconnect( 'unable to create socket' );
			}
		});
	}
	
	public override function disconnect() {
		Socket.disconnect( socketId );
		Socket.destroy( socketId );
		connected = false;
	}

	public override inline function read( ?yes : Bool = true ) : Bool {
		_read();
		return true;
	}
	
	public override function write( t : String ) : Bool {
		Socket.write( socketId, ArrayBufferUtil.toArrayBuffer( t ), function(info){
			//trace(info);
		});
		return true;
	}
	
	function _read() {
		Socket.read( socketId, null, function(i:ReadInfo) {
			if( i.resultCode > 0 ) {
				__onData( Bytes.ofString( ArrayBufferUtil.toString( i.data ) ) ); //TODO
				_read();
			}
		});
	}
	
	function handleConnect( status : Int ) {
		//trace( "socket status "+status, "debug" );
		if( status == 0 ) {
			connected = true;
			__onConnect();
		} else {
			//TODO (what?)
			#if jabber_debug trace("TODO"); #end
		}
	}

}
