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

import flash.external.ExternalInterface;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;

private class Socket extends flash.net.Socket {
	public var id(default,null) : UInt;
	public function new( id : UInt ) {
		super();
		this.id = id;
	}
}

@:require(flash)
@:keep
class FlashSocketBridge {

	#if jabber_flashsocketbridge_standalone
	static function main() {
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		var cm = new flash.ui.ContextMenu();
		cm.hideBuiltInItems();
		flash.Lib.current.contextMenu = cm;
		var ctx = flash.Lib.current.loaderInfo.parameters.ctx;
		var fsb = new FlashSocketBridge( ctx );
		fsb.init();
	}
	#end

	var ctx : String;
	var sockets : Map<Int,Socket>;
	
	//var outputInterval : Int;
	//var queue : Array<{id:Int,data:String}>;
	//var timer : haxe.Timer;
	
	public function new( ?ctx : String, outputInterval : Int = 1 ) {
		this.ctx = ( ctx != null ) ? ctx : "jabber.net.SocketConnection_flashsocketbridge";
		//this.outputInterval = outputInterval;
	}
	
	public function init() {
		if( !ExternalInterface.available )
			throw "External interface not available";
		sockets = new Map();
		ExternalInterface.addCallback( "createSocket", createSocket );
		ExternalInterface.addCallback( "destroySocket", destroySocket );
		ExternalInterface.addCallback( "connect", connect );
		ExternalInterface.addCallback( "disconnect", disconnect );
		ExternalInterface.addCallback( "send", send );
		//ExternalInterface.addCallback( "destroy", destroy );
		ExternalInterface.addCallback( "destroyAll", destroyAll );
		//queue = new Array();
		//timer = new haxe.Timer( outputInterval );
		//timer.run = onTimer;
	}
	
	function createSocket( ___secure : Bool, __legacy__ : Bool, timeout : Int = -1 ) : Int {
		var id = Lambda.count( sockets );
		var s = new Socket( id );
		#if flash10
		if( timeout != -1 ) s.timeout = timeout*1000;
		#end
		sockets.set( id, s );
		s.addEventListener( Event.CONNECT, sockConnectHandler );
		s.addEventListener( Event.CLOSE, sockDisconnectHandler );
		s.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		s.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		s.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		return id;
	}
	
	function destroySocket( id : Int ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		if( s.connected ) s.close();
		sockets.remove( s.id );
		s = null;
		return true;
	}
	
	function destroyAll() {
		for( s in sockets ) {
			s.close();
			s = null;
		}
		sockets = new Map();
	}
	
	function connect( id : Int, host : String, port : Int, ?timeout : Int = -1 ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		if( timeout > 0 )
			s.timeout = timeout;
		s.connect( host, port );
		return true;
	}
	
	function disconnect( id : Int ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		s.close();
		return true;
	}
	
	function send( id : Int, data : String ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		s.writeUTFBytes( data ); 
		s.flush();
		return true;
	}
	
	function sockConnectHandler( e : Event ) {
		//trace(e);
		ExternalInterface.call( ctx+".handleConnect", e.target.id );
	}

	function sockDisconnectHandler( e : Event ) {
		//trace(e);
		ExternalInterface.call( ctx+".handleDisconnect", e.target.id, null );
	}
	
	function sockErrorHandler( e : Event ) {
		//trace(e);
		ExternalInterface.call( ctx+".handleDisconnect", e.target.id, e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		//trace(e);
		//ExternalInterface.call( ctx+".handleData", e.target.id, e.target.readUTFBytes( e.bytesLoaded ) );
		//trace(e.bytesLoaded );
		/*
		var s : Socket = e.target;
		var pos = 0;
		var len = 256;
		while( pos < e.bytesLoaded ) {
			//pos += len;
			if( pos+len > e.bytesLoaded ) len = Std.int( e.bytesLoaded-pos );
			trace(pos+":"+len+":"+e.bytesLoaded);
			var buf = new flash.utils.ByteArray();
			s.readBytes( buf, pos, len );
			pos += len;
			var t = buf.toString();
			trace(t);
			queue.push( { id : s.id, data : t } );
		}
		*/
		/*
		var pos = 0;
		var len = 4096;
		var s : Socket = e.target;
		var data = e.target.readUTFBytes( e.bytesLoaded );
		while( pos < e.bytesLoaded ) {
			if( pos+len > e.bytesLoaded ) len = Std.int( e.bytesLoaded-pos );
			var t = data.substr( pos, len );
			queue.push( { id : e.target.id, data : t } );
			pos += len;
		}
		*/
		ExternalInterface.call( ctx+".handleData", e.target.id, e.target.readUTFBytes( e.bytesLoaded ) );
		//queue.push( { id : e.target.id, data : e.target.readUTFBytes( e.bytesLoaded ) } );
	}

	/*
	function fl( f : String, p0 : Dynamic, p1 : Dynamic, p2 : Dynamic ) {
		ExternalInterface.call( ctx+"."+f, e.target.id );
	}
	*/
	
	/* 
	function onTimer() {
		if( queue.length > 0 ) {
			var n = queue.shift();
			ExternalInterface.call( ctx+".handleData", n.id, n.data );
		}
	}
	*/

}
