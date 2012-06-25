/*
 * Copyright (c) 2012, tong, disktree.net
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
import tls.controller.SecureSocket;
import tls.event.SecureSocketEvent;
import tls.valueobject.SecurityOptionsVO;

private class Socket extends SecureSocket {
	public var id(default,null) : UInt;
	public var secure(default,null) : Bool;
	public var legacy(default,null) : Bool;
	public function new( id : UInt, secure : Bool, legacy : Bool ) {
		super();
		this.id = id;
		this.secure = secure;
		this.legacy = legacy;
	}
}

class FlashSocketBridgeTLS {
	
	var ctx : String;
	var sockets : IntHash<Socket>;
	
	var outputInterval : Int;
	var queue : Array<{id:Int,data:String}>;
	var timer : haxe.Timer;
	
	public function new( ?ctx : String,  outputInterval : Int = 1 ) {
		this.ctx = ( ctx != null ) ? ctx : "jabber.SocketConnection";
		this.outputInterval = outputInterval;
	}
	
	public function init() {
		if( !ExternalInterface.available )
			throw "External interface not available";
		sockets = new IntHash();
		ExternalInterface.addCallback( "createSocket", createSocket );
		ExternalInterface.addCallback( "destroySocket", destroySocket );
		ExternalInterface.addCallback( "connect", connect );
		ExternalInterface.addCallback( "disconnect", disconnect );
		ExternalInterface.addCallback( "setSecure", setSecure );
		ExternalInterface.addCallback( "send", send );
		//ExternalInterface.addCallback( "destroy", destroy );
		ExternalInterface.addCallback( "destroyAll", destroyAll );
		queue = new Array();
		timer = new haxe.Timer( outputInterval );
		timer.run = onTimer;
	}
	
	function createSocket( secure : Bool = true, legacy : Bool = false, timeout : Int ) : Int {
		var id = Lambda.count( sockets );
		var s = new Socket( id, secure, legacy );
		sockets.set( id, s );
		s.addEventListener( SecureSocketEvent.ON_CONNECT, sockConnectHandler );
		s.addEventListener( SecureSocketEvent.ON_SECURE_CHANNEL_ESTABLISHED, sockSecuredHandler );
		s.addEventListener( SecureSocketEvent.ON_CLOSE, sockDisconnectHandler );
		s.addEventListener( SecureSocketEvent.ON_ERROR, sockErrorHandler );
		s.addEventListener( SecureSocketEvent.ON_PROCESSED_DATA, sockDataHandler );
		return id;
	}
	
	function destroySocket( id : Int ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		if( s.isConnected() ) s.close();
		sockets.remove( s.id );
		s = null;
		return true;
	}
	
	function destroyAll() {
		for( s in sockets ) {
			s.close();
			s = null;
		}
		sockets = new IntHash();
	}
	
	function connect( id : Int, host : String, port : Int,
					  ?timeout : Int = -1 ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
	//	#if flash10
	//	if( timeout > 0 ) s.timeout = timeout;
	//	#end
		s.connect( host, port );
		return true;
	}
	
	function disconnect( id : Int ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		try {
			s.close();
		} catch( e : Dynamic ) {
			trace(e);
			return false;	
		}
		return true;
	}
	
	function send( id : Int, data : String ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		s.sendString( data ); 
		return true;
	}
	
	function setSecure( id : Int ) {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		s.startSecureSupport( SecurityOptionsVO.getDefaultOptions( SecurityOptionsVO.SECURITY_TYPE_TLS ) );
		return true;
	}
	
	function sockConnectHandler( e : SecureSocketEvent ) {
		var s = e.target;
		if( s.secure && s.legacy )
			s.startSecureSupport( SecurityOptionsVO.getDefaultOptions( SecurityOptionsVO.SECURITY_TYPE_TLS ) );
		else
			ExternalInterface.call( ctx+".handleConnect", e.target.id );
	}

	function sockSecuredHandler( e : SecureSocketEvent ) {
		var s = e.target;
		if( s.secure && s.legacy )
			ExternalInterface.call( ctx+".handleConnect", s.id );
		else
			ExternalInterface.call( ctx+".handleSecure", s.id );
	}
	
	function sockDisconnectHandler( e : SecureSocketEvent ) {
		ExternalInterface.call( ctx+".handleDisconnect", e.target.id );
	}
	
	function sockErrorHandler( e : SecureSocketEvent ) {
		ExternalInterface.call( ctx+".handleDisconnect", e.target.id, e.type );
	}
	
	function sockDataHandler( e : SecureSocketEvent ) {
		if( e.rawData == null )
			return; // ?
		queue.push( { id : e.target.id, data : e.rawData.toString() } );
	}
	
	function onTimer() {
		if( queue.length > 0 ) {
			var n = queue.shift();
			ExternalInterface.call( ctx+".handleData", n.id, n.data );
		}
	}
	
}
