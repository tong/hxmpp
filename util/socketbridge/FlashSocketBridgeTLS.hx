/*
 *	This file is part of HXMPP.
 *	Copyright (c)2010 http://www.disktree.net
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
	
	public function new( ?ctx : String ) {
		this.ctx = ( ctx != null ) ? ctx : "jabber.SocketConnection";
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
	}
	
	function createSocket( secure : Bool = true, legacy : Bool = false ) : Int {
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
		ExternalInterface.call( ctx+".handleError", e.target.id, e.type );
	}
	
	function sockDataHandler( e : SecureSocketEvent ) {
		if( e.rawData == null ) return; // ?
		ExternalInterface.call( ctx+".handleData", e.target.id, e.rawData.toString() );
	}

}
